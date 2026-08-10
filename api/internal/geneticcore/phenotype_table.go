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

// GenotypeSlice is one Mendelian genotype class under a phenotype bucket.
// Used for carrier labels and multi-generation continuation (pass Key as parent).
type GenotypeSlice struct {
	Key          string            `json:"key"`
	Alleles      map[string]string `json:"alleles,omitempty"`
	Probability  float64           `json:"probability"`
	Fraction     string            `json:"fraction,omitempty"`
	Phenotype    string            `json:"phenotype"`
	DisplayLabel string            `json:"display_label"`
	CarrierTags  []string          `json:"carrier_tags,omitempty"`
}

// PhenotypeOutcome is one offspring class from the authority table.
type PhenotypeOutcome struct {
	Phenotype   string  `json:"phenotype"`
	Probability float64 `json:"probability"`
	Fraction    string  `json:"fraction,omitempty"`
	Note        string  `json:"note,omitempty"`
	// CarrierSummary is a short Chinese line, e.g. "其中约 2/3 为携巧（Bb）".
	CarrierSummary string `json:"carrier_summary,omitempty"`
	// GenotypeBreakdown splits this phenotype into underlying genotypes (model-derived).
	GenotypeBreakdown []GenotypeSlice `json:"genotype_breakdown,omitempty"`
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
	SireGenotypeKey    string             `json:"sire_genotype_key,omitempty"`
	DamGenotypeKey     string             `json:"dam_genotype_key,omitempty"`
	Outcomes           []PhenotypeOutcome `json:"outcomes"`
	// GenotypeOutcomes is a flat, probability-sorted list for multi-gen pickers.
	GenotypeOutcomes   []GenotypeSlice    `json:"genotype_outcomes,omitempty"`
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

// SimulatePhenotypeTable looks up offspring probabilities from the authority table,
// then falls back to the golden-tested locus model for catalog gaps.
// Parent order is commutative (A×B == B×A). Table rows always win over the model.
func SimulatePhenotypeTable(seriesRaw, sirePhenotype, damPhenotype string) (PhenotypeTableResult, error) {
	return SimulatePhenotypeTableExt(seriesRaw, sirePhenotype, damPhenotype, "", "")
}

// SimulatePhenotypeTableExt is SimulatePhenotypeTable plus optional exact parent genotype keys
// (from a previous result's genotype_breakdown[].key) for multi-generation continuation.
// When a genotype key is set, phenotype is optional for that parent (used only for display).
func SimulatePhenotypeTableExt(seriesRaw, sirePhenotype, damPhenotype, sireGenoKey, damGenoKey string) (PhenotypeTableResult, error) {
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
	sireGenoKey = strings.TrimSpace(sireGenoKey)
	damGenoKey = strings.TrimSpace(damGenoKey)

	// Resolve display phenotypes from genotype keys when omitted.
	if sirePhenotype == "" && sireGenoKey != "" {
		if ph, ok := PhenotypeFromGenotypeKey(series, sireGenoKey); ok {
			sirePhenotype = ph
		}
	}
	if damPhenotype == "" && damGenoKey != "" {
		if ph, ok := PhenotypeFromGenotypeKey(series, damGenoKey); ok {
			damPhenotype = ph
		}
	}
	if sirePhenotype == "" || damPhenotype == "" {
		return PhenotypeTableResult{}, fmt.Errorf("父母双方都需要表型（或可解析的基因型 key）")
	}
	ser, ok := seriesByCode[series]
	if !ok {
		return PhenotypeTableResult{}, fmt.Errorf("未知系列代码 %s", series)
	}
	if sireGenoKey == "" && !phenotypeInSeriesOrAlias(ser, sirePhenotype) {
		return PhenotypeTableResult{}, fmt.Errorf("表型 %q 不在系列 %s 中", sirePhenotype, ser.Name)
	}
	if damGenoKey == "" && !phenotypeInSeriesOrAlias(ser, damPhenotype) {
		return PhenotypeTableResult{}, fmt.Errorf("表型 %q 不在系列 %s 中", damPhenotype, ser.Name)
	}

	notes := strings.Join(doc.Notes, " ")
	notes = notes + " 数据源：" + doc.Title + "（" + doc.Version + "）。"

	// Exact genotype parents → always locus model (table has no genotype rows).
	if sireGenoKey != "" || damGenoKey != "" {
		outcomes, flat, ok := SimulateLocusModelDetailed(series, sirePhenotype, damPhenotype, sireGenoKey, damGenoKey)
		if !ok {
			return PhenotypeTableResult{}, fmt.Errorf("无法用给定基因型推算：sire=%q dam=%q", sireGenoKey, damGenoKey)
		}
		sortPhenotypeOutcomes(outcomes)
		notes = notes + " 亲本使用精确基因型续推（多代）；表型概率由位点模型给出。"
		return PhenotypeTableResult{
			Mode:             "phenotype_table",
			Series:           series,
			SeriesName:       ser.Name,
			Sire:             sirePhenotype,
			Dam:              damPhenotype,
			SireGenotypeKey:  sireGenoKey,
			DamGenotypeKey:   damGenoKey,
			Outcomes:         outcomes,
			GenotypeOutcomes: flat,
			Notes:            notes,
			TableID:          doc.ID,
			Version:          doc.Version,
			PredictionBasis:  PredictionBasisLocusModel,
		}, nil
	}

	// 1) Authority table (exact + synonym keys). Never override phenotype probs with the model.
	if cross, hit := lookupPhenotypeCross(series, sirePhenotype, damPhenotype); hit {
		outcomes := make([]PhenotypeOutcome, len(cross.Outcomes))
		copy(outcomes, cross.Outcomes)
		sortPhenotypeOutcomes(outcomes)
		// Attach genotype / carrier detail from model (probs scaled to table phenotype margins).
		outcomes, flat := enrichOutcomesWithGenotypes(series, sirePhenotype, damPhenotype, "", "", outcomes)
		return PhenotypeTableResult{
			Mode:             "phenotype_table",
			Series:           series,
			SeriesName:       ser.Name,
			Sire:             sirePhenotype,
			Dam:              damPhenotype,
			Outcomes:         outcomes,
			GenotypeOutcomes: flat,
			Notes:            notes,
			TableID:          doc.ID,
			Version:          doc.Version,
			PredictionBasis:  PredictionBasisAuthorityTable,
		}, nil
	}

	// 2) Locus model fill (golden-tested against all table rows).
	outcomes, flat, ok := SimulateLocusModelDetailed(series, sirePhenotype, damPhenotype, "", "")
	if !ok {
		return PhenotypeTableResult{}, fmt.Errorf(
			"核心表中无此配对：%s × %s（系列 %s），且位点模型无法推算",
			sirePhenotype, damPhenotype, ser.Name,
		)
	}
	sortPhenotypeOutcomes(outcomes)
	notes = notes + " 本配对不在权威表收录范围内，由位点模型推算（与表内 49 组 golden 一致）；表内已收录配对仍以表为准。"
	return PhenotypeTableResult{
		Mode:             "phenotype_table",
		Series:           series,
		SeriesName:       ser.Name,
		Sire:             sirePhenotype,
		Dam:              damPhenotype,
		Outcomes:         outcomes,
		GenotypeOutcomes: flat,
		Notes:            notes,
		TableID:          doc.ID,
		Version:          doc.Version,
		PredictionBasis:  PredictionBasisLocusModel,
	}, nil
}

func sortPhenotypeOutcomes(outcomes []PhenotypeOutcome) {
	sort.SliceStable(outcomes, func(i, j int) bool {
		if outcomes[i].Probability == outcomes[j].Probability {
			return outcomes[i].Phenotype < outcomes[j].Phenotype
		}
		return outcomes[i].Probability > outcomes[j].Probability
	})
}

// lookupPhenotypeCross finds an authority row, trying synonym labels for both parents.
func lookupPhenotypeCross(series, sire, dam string) (PhenotypeCross, bool) {
	for _, a := range PhenotypeLabelAliases(series, sire) {
		for _, b := range PhenotypeLabelAliases(series, dam) {
			pa, pb := normalizeParentPair(a, b)
			if cross, ok := phenotypeCrossIndex[crossKey(series, pa, pb)]; ok {
				return cross, true
			}
		}
	}
	return PhenotypeCross{}, false
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
		gmap := map[string]string{"phenotype": o.Phenotype, "fraction": o.Fraction}
		if o.CarrierSummary != "" {
			gmap["carrier_summary"] = o.CarrierSummary
		}
		// Prefer top genotype class key for professional row / multi-gen handoff.
		gkey := "phenotype=" + o.Phenotype
		if len(o.GenotypeBreakdown) > 0 {
			gkey = o.GenotypeBreakdown[0].Key
			gmap["top_genotype_key"] = o.GenotypeBreakdown[0].Key
			gmap["top_display_label"] = o.GenotypeBreakdown[0].DisplayLabel
		}
		outcomes = append(outcomes, Outcome{
			GenotypeKey:    gkey,
			Genotype:       gmap,
			PhenotypeLabel: o.Phenotype, // keep pure label for calibration / client keys
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
	if !phenotypeInSeriesOrAlias(ser, label) {
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
// Authority-table rows are preferred; locus-model pairs fill catalog gaps (e.g. chocolate 105).
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
	targetAliases := map[string]struct{}{}
	for _, a := range PhenotypeLabelAliases(series, targetPhenotype) {
		targetAliases[a] = struct{}{}
	}
	targetCanon := NormalizePhenotypeLabel(series, targetPhenotype)
	targetAliases[targetCanon] = struct{}{}

	type ranked struct {
		cross PhenotypeCross
		p     float64
	}
	seen := map[string]struct{}{}
	var list []ranked
	addCross := func(c PhenotypeCross) {
		a, b := normalizeParentPair(c.ParentA, c.ParentB)
		key := crossKey(series, NormalizePhenotypeLabel(series, a), NormalizePhenotypeLabel(series, b))
		if _, ok := seen[key]; ok {
			return
		}
		var p float64
		for _, o := range c.Outcomes {
			if _, hit := targetAliases[o.Phenotype]; hit {
				if o.Probability > p {
					p = o.Probability
				}
			}
			// model offspring may use canonical labels (黑熊) while target is 普通黑熊
			if NormalizePhenotypeLabel(series, o.Phenotype) == targetCanon || o.Phenotype == targetPhenotype {
				if o.Probability > p {
					p = o.Probability
				}
			}
		}
		if p <= 0 {
			return
		}
		seen[key] = struct{}{}
		cc := c
		cc.ParentA, cc.ParentB = a, b
		cc.Series = series
		list = append(list, ranked{cross: cc, p: p})
	}

	for _, c := range doc.Crosses {
		if c.Series != series {
			continue
		}
		addCross(c)
	}
	for _, c := range EnumerateModelCrosses(series) {
		addCross(c)
	}

	sort.SliceStable(list, func(i, j int) bool {
		if list[i].p == list[j].p {
			if list[i].cross.ParentA == list[j].cross.ParentA {
				return list[i].cross.ParentB < list[j].cross.ParentB
			}
			return list[i].cross.ParentA < list[j].cross.ParentA
		}
		return list[i].p > list[j].p
	})
	out := make([]PhenotypeCross, len(list))
	for i := range list {
		out[i] = list[i].cross
	}
	return out, nil
}
