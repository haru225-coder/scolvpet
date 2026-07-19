// Package geneticcore — phenotype-table breeding simulator.
//
// 权威数据来源：金丝熊后代推算整理表（双重核验版）。
// 本表是繁殖推算的核心基准；查表结果优先于简化孟德尔模型。
package geneticcore

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"sort"
	"strings"
	"sync"
)

//go:embed data/syrian_phenotype_table_v1.json
var phenotypeTableJSON []byte

// PhenotypeTableID is the embedded authority document id.
const PhenotypeTableID = "syrian_phenotype_table_v1"

// PhenotypeSeries describes one catalog series (poly / chocolate).
type PhenotypeSeries struct {
	Code       string   `json:"code"`
	Name       string   `json:"name"`
	Phenotypes []string `json:"phenotypes"`
}

// PhenotypeOutcome is one offspring class from the authority table.
type PhenotypeOutcome struct {
	Phenotype   string  `json:"phenotype"`
	Probability float64 `json:"probability"`
	Fraction    string  `json:"fraction,omitempty"`
	Note        string  `json:"note,omitempty"`
}

// PhenotypeCross is one unordered parent pair with outcomes.
type PhenotypeCross struct {
	Series         string             `json:"series"`
	SeriesName     string             `json:"series_name"`
	ParentA        string             `json:"parent_a"`
	ParentB        string             `json:"parent_b"`
	Outcomes       []PhenotypeOutcome `json:"outcomes"`
	ProbabilitySum float64            `json:"probability_sum"`
}

// PhenotypeTableDocument is the on-disk authority document.
type PhenotypeTableDocument struct {
	ID      string            `json:"id"`
	Title   string            `json:"title"`
	Version string            `json:"version"`
	Source  string            `json:"source_file"`
	Notes   []string          `json:"notes"`
	Series  []PhenotypeSeries `json:"series"`
	Crosses []PhenotypeCross  `json:"crosses"`
}

// PhenotypeTableResult is the API-facing lookup result (maps into SimulationResult shape).
type PhenotypeTableResult struct {
	Mode               string             `json:"mode"`
	Series             string             `json:"series"`
	SeriesName         string             `json:"series_name"`
	Sire               string             `json:"sire_phenotype"`
	Dam                string             `json:"dam_phenotype"`
	Outcomes           []PhenotypeOutcome `json:"outcomes"`
	Notes              string             `json:"notes"`
	TableID            string             `json:"table_id"`
	Version            string             `json:"table_version"`
	PredictionBasis    string             `json:"prediction_basis"`
	HistoryLitterCount int                `json:"history_litter_count"`
	HistoryPupCount    int                `json:"history_pup_count"`
}

var (
	phenotypeTableOnce sync.Once
	phenotypeTableDoc  *PhenotypeTableDocument
	phenotypeTableErr  error
	// key: seriesCode + "\x00" + parentMin + "\x00" + parentMax
	phenotypeCrossIndex map[string]PhenotypeCross
	seriesByCode        map[string]PhenotypeSeries
	seriesNameToCode    map[string]string
)

func loadPhenotypeTable() (*PhenotypeTableDocument, error) {
	phenotypeTableOnce.Do(func() {
		var doc PhenotypeTableDocument
		if err := json.Unmarshal(phenotypeTableJSON, &doc); err != nil {
			phenotypeTableErr = fmt.Errorf("load phenotype table: %w", err)
			return
		}
		if doc.ID == "" || len(doc.Crosses) == 0 {
			phenotypeTableErr = fmt.Errorf("phenotype table empty or missing id")
			return
		}
		phenotypeCrossIndex = make(map[string]PhenotypeCross, len(doc.Crosses))
		seriesByCode = make(map[string]PhenotypeSeries, len(doc.Series))
		seriesNameToCode = make(map[string]string, len(doc.Series)*2)
		for _, s := range doc.Series {
			seriesByCode[s.Code] = s
			seriesNameToCode[s.Code] = s.Code
			seriesNameToCode[s.Name] = s.Code
			// common aliases
			if s.Code == "poly" {
				seriesNameToCode["波利"] = s.Code
				seriesNameToCode["poly"] = s.Code
			}
			if s.Code == "chocolate" {
				seriesNameToCode["巧克力"] = s.Code
				seriesNameToCode["巧克力色"] = s.Code
				seriesNameToCode["chocolate"] = s.Code
			}
		}
		for _, c := range doc.Crosses {
			a, b := normalizeParentPair(c.ParentA, c.ParentB)
			key := crossKey(c.Series, a, b)
			// keep first; table should be unique
			if _, exists := phenotypeCrossIndex[key]; !exists {
				// ensure parents stored in normalized order for response
				cc := c
				cc.ParentA, cc.ParentB = a, b
				phenotypeCrossIndex[key] = cc
			}
		}
		phenotypeTableDoc = &doc
	})
	return phenotypeTableDoc, phenotypeTableErr
}

func crossKey(series, a, b string) string {
	return series + "\x00" + a + "\x00" + b
}

func normalizeParentPair(a, b string) (string, string) {
	a = strings.TrimSpace(a)
	b = strings.TrimSpace(b)
	if a <= b {
		return a, b
	}
	return b, a
}

// ResolveSeriesCode maps code or Chinese name to series code.
func ResolveSeriesCode(raw string) (string, error) {
	if _, err := loadPhenotypeTable(); err != nil {
		return "", err
	}
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", fmt.Errorf("系列必填（poly / chocolate，或 波利系列 / 巧克力色系）")
	}
	if code, ok := seriesNameToCode[raw]; ok {
		return code, nil
	}
	// fuzzy contains
	for name, code := range seriesNameToCode {
		if strings.Contains(raw, name) || strings.Contains(name, raw) {
			return code, nil
		}
	}
	return "", fmt.Errorf("未知系列 %q", raw)
}

// PhenotypeTableMeta returns series catalog from the authority table.
func PhenotypeTableMeta() (PhenotypeTableDocument, error) {
	doc, err := loadPhenotypeTable()
	if err != nil {
		return PhenotypeTableDocument{}, err
	}
	return *doc, nil
}

// ListPhenotypeSeries returns series + phenotype lists.
func ListPhenotypeSeries() ([]PhenotypeSeries, error) {
	doc, err := loadPhenotypeTable()
	if err != nil {
		return nil, err
	}
	out := make([]PhenotypeSeries, len(doc.Series))
	copy(out, doc.Series)
	return out, nil
}

// SimulatePhenotypeTable looks up offspring probabilities from the authority table.
// Parent order is commutative (A×B == B×A).
func SimulatePhenotypeTable(seriesRaw, sirePhenotype, damPhenotype string) (PhenotypeTableResult, error) {
	doc, err := loadPhenotypeTable()
	if err != nil {
		return PhenotypeTableResult{}, err
	}
	series, err := ResolveSeriesCode(seriesRaw)
	if err != nil {
		return PhenotypeTableResult{}, err
	}
	sirePhenotype = strings.TrimSpace(sirePhenotype)
	damPhenotype = strings.TrimSpace(damPhenotype)
	if sirePhenotype == "" || damPhenotype == "" {
		return PhenotypeTableResult{}, fmt.Errorf("父母双方都需要表型")
	}
	// Validate phenotypes belong to series (allow any listed in series catalog).
	ser, ok := seriesByCode[series]
	if !ok {
		return PhenotypeTableResult{}, fmt.Errorf("未知系列代码 %s", series)
	}
	if !phenotypeInSeries(ser, sirePhenotype) {
		return PhenotypeTableResult{}, fmt.Errorf("表型 %q 不在系列 %s 中", sirePhenotype, ser.Name)
	}
	if !phenotypeInSeries(ser, damPhenotype) {
		return PhenotypeTableResult{}, fmt.Errorf("表型 %q 不在系列 %s 中", damPhenotype, ser.Name)
	}

	a, b := normalizeParentPair(sirePhenotype, damPhenotype)
	cross, ok := phenotypeCrossIndex[crossKey(series, a, b)]
	if !ok {
		return PhenotypeTableResult{}, fmt.Errorf(
			"核心表中无此配对：%s × %s（系列 %s）。空白表示原资料未收录，非生物学上不可能",
			sirePhenotype, damPhenotype, ser.Name,
		)
	}

	outcomes := make([]PhenotypeOutcome, len(cross.Outcomes))
	copy(outcomes, cross.Outcomes)
	sort.SliceStable(outcomes, func(i, j int) bool {
		if outcomes[i].Probability == outcomes[j].Probability {
			return outcomes[i].Phenotype < outcomes[j].Phenotype
		}
		return outcomes[i].Probability > outcomes[j].Probability
	})

	notes := strings.Join(doc.Notes, " ")
	notes = notes + " 数据源：" + doc.Title + "（" + doc.Version + "）。"

	return PhenotypeTableResult{
		Mode:            "phenotype_table",
		Series:          series,
		SeriesName:      ser.Name,
		Sire:            sirePhenotype,
		Dam:             damPhenotype,
		Outcomes:        outcomes,
		Notes:           notes,
		TableID:         doc.ID,
		Version:         doc.Version,
		PredictionBasis: PredictionBasisAuthorityTable,
	}, nil
}

func phenotypeInSeries(ser PhenotypeSeries, name string) bool {
	for _, p := range ser.Phenotypes {
		if p == name {
			return true
		}
	}
	return false
}

// ToSimulationResult adapts phenotype-table outcomes into the existing SimulationResult shape
// used by HTTP responses (genotype fields carry phenotype labels for compatibility).
func (r PhenotypeTableResult) ToSimulationResult() SimulationResult {
	sire := Genotype{
		"series":    r.Series,
		"phenotype": r.Sire,
	}
	dam := Genotype{
		"series":    r.Series,
		"phenotype": r.Dam,
	}
	outcomes := make([]Outcome, 0, len(r.Outcomes))
	for _, o := range r.Outcomes {
		weight := fractionToWeight(o.Fraction, o.Probability)
		outcomes = append(outcomes, Outcome{
			GenotypeKey:    "phenotype=" + o.Phenotype,
			Genotype:       map[string]string{"phenotype": o.Phenotype, "fraction": o.Fraction},
			PhenotypeLabel: o.Phenotype,
			Phenotype:      map[string]string{"label": o.Phenotype, "series": r.Series},
			Probability:    o.Probability,
			CountWeight:    weight,
		})
	}
	return SimulationResult{
		Sire:     sire,
		Dam:      dam,
		Outcomes: outcomes,
		Notes:    r.Notes,
	}
}

// fractionToWeight converts "3/16" → 3, fallback from probability*denominator.
func fractionToWeight(fraction string, p float64) int {
	fraction = strings.TrimSpace(fraction)
	if strings.Contains(fraction, "/") {
		parts := strings.Split(fraction, "/")
		if len(parts) == 2 {
			var num, den int
			if _, err := fmt.Sscanf(parts[0], "%d", &num); err == nil && num > 0 {
				if _, err := fmt.Sscanf(parts[1], "%d", &den); err == nil && den > 0 {
					return num
				}
			}
		}
	}
	// fallback: scale common denominators
	for _, den := range []int{32, 16, 8, 4, 2, 1} {
		w := int(p*float64(den) + 1e-9)
		if w > 0 && absFloat(float64(w)/float64(den)-p) < 1e-9 {
			return w
		}
	}
	if p <= 0 {
		return 1
	}
	return 1
}

func absFloat(v float64) float64 {
	if v < 0 {
		return -v
	}
	return v
}

// CorePhenotypeKeys used in hamster.phenotype JSON and variety_code encoding.
const (
	PhenotypeKeySeries  = "series"
	PhenotypeKeyLabel   = "label"
	PhenotypeKeySource  = "source"
	PhenotypeSourceCore = "core_table"
	// VarietyCode encoding: "poly|蜜波利" (series|label). Plain labels also accepted when unique.
	VarietyCodeSep = "|"
)

// EncodeVarietyCode builds variety_code from series + phenotype label.
func EncodeVarietyCode(series, label string) string {
	series = strings.TrimSpace(series)
	label = strings.TrimSpace(label)
	if series == "" {
		return label
	}
	return series + VarietyCodeSep + label
}

// DecodeVarietyCode parses "poly|蜜波利" or a bare phenotype label.
// Bare labels are resolved against the authority catalog when unambiguous.
func DecodeVarietyCode(raw string) (series, label string, ok bool) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", "", false
	}
	if strings.Contains(raw, VarietyCodeSep) {
		parts := strings.SplitN(raw, VarietyCodeSep, 2)
		s, l := strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1])
		if s == "" || l == "" {
			return "", "", false
		}
		if _, err := ResolveSeriesCode(s); err != nil {
			return "", "", false
		}
		return s, l, true
	}
	// Bare label: find unique series containing it.
	doc, err := loadPhenotypeTable()
	if err != nil {
		return "", "", false
	}
	var found string
	for _, ser := range doc.Series {
		for _, p := range ser.Phenotypes {
			if p == raw {
				if found != "" && found != ser.Code {
					return "", "", false // ambiguous
				}
				found = ser.Code
			}
		}
	}
	if found == "" {
		return "", "", false
	}
	return found, raw, true
}

// ValidateCorePhenotype checks series+label against the authority table.
func ValidateCorePhenotype(seriesRaw, label string) (seriesCode, phenotype string, err error) {
	seriesCode, err = ResolveSeriesCode(seriesRaw)
	if err != nil {
		return "", "", err
	}
	label = strings.TrimSpace(label)
	if label == "" {
		return "", "", fmt.Errorf("表型标签必填")
	}
	ser, ok := seriesByCode[seriesCode]
	if !ok {
		return "", "", fmt.Errorf("未知系列")
	}
	if !phenotypeInSeries(ser, label) {
		return "", "", fmt.Errorf("表型 %q 不在系列 %s 中", label, ser.Name)
	}
	return seriesCode, label, nil
}

// PhenotypeMapFromCore builds the structured phenotype JSON for hamster records.
func PhenotypeMapFromCore(series, label string) map[string]any {
	return map[string]any{
		PhenotypeKeySeries: series,
		PhenotypeKeyLabel:  label,
		PhenotypeKeySource: PhenotypeSourceCore,
	}
}

// FindCrossesForTarget lists crosses in a series that can produce the target phenotype,
// sorted by probability descending. Used for breeding planning.
func FindCrossesForTarget(seriesRaw, targetPhenotype string) ([]PhenotypeCross, error) {
	doc, err := loadPhenotypeTable()
	if err != nil {
		return nil, err
	}
	series, err := ResolveSeriesCode(seriesRaw)
	if err != nil {
		return nil, err
	}
	targetPhenotype = strings.TrimSpace(targetPhenotype)
	if targetPhenotype == "" {
		return nil, fmt.Errorf("目标表型必填")
	}
	type ranked struct {
		cross PhenotypeCross
		p     float64
	}
	var list []ranked
	for _, c := range doc.Crosses {
		if c.Series != series {
			continue
		}
		for _, o := range c.Outcomes {
			if o.Phenotype == targetPhenotype && o.Probability > 0 {
				list = append(list, ranked{cross: c, p: o.Probability})
				break
			}
		}
	}
	sort.Slice(list, func(i, j int) bool {
		if list[i].p == list[j].p {
			return list[i].cross.ParentA+list[i].cross.ParentB < list[j].cross.ParentA+list[j].cross.ParentB
		}
		return list[i].p > list[j].p
	})
	out := make([]PhenotypeCross, 0, len(list))
	for _, r := range list {
		out = append(out, r.cross)
	}
	return out, nil
}
