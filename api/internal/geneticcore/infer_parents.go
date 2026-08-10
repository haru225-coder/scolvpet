// Parent genotype inference from litter phenotype counts (step ④).
//
// Locus model = likelihood; mild Dirichlet-style prior favors catalog defaults
// for stated parent phenotypes. Does not override authority-table forward probs.
package geneticcore

import (
	"fmt"
	"math"
	"sort"
	"strings"
)

const (
	// PredictionBasisParentPosterior marks reverse-inference results.
	PredictionBasisParentPosterior = "parent_genotype_posterior"

	// parentGenotypePriorMass is pseudo-count on the catalog-default genotype.
	parentGenotypePriorMass = 8.0
	// parentGenotypeAltMass is pseudo-count on phenotype-compatible alternatives.
	parentGenotypeAltMass = 1.0
)

// ParentGenotypeHypothesis is one joint (sire, dam) genotype explanation.
type ParentGenotypeHypothesis struct {
	SireKey       string  `json:"sire_genotype_key"`
	DamKey        string  `json:"dam_genotype_key"`
	SireDisplay   string  `json:"sire_display"`
	DamDisplay    string  `json:"dam_display"`
	Probability   float64 `json:"probability"`
	LogLikelihood float64 `json:"log_likelihood"`
	Prior         float64 `json:"prior"`
}

// ParentGenotypeMarginal is a per-parent genotype posterior mass.
type ParentGenotypeMarginal struct {
	Key          string   `json:"key"`
	DisplayLabel string   `json:"display_label"`
	Probability  float64  `json:"probability"`
	CarrierTags  []string `json:"carrier_tags,omitempty"`
}

// InferParentGenotypesRequest is the reverse-inference input.
type InferParentGenotypesRequest struct {
	Series          string
	SirePhenotype   string
	DamPhenotype    string
	SireGenotypeKey string
	DamGenotypeKey  string
	OffspringCounts map[string]int
	MaxHypotheses   int
}

// InferParentGenotypesResult is the API-facing reverse-inference payload.
type InferParentGenotypesResult struct {
	Series          string                     `json:"series"`
	SeriesName      string                     `json:"series_name"`
	SirePhenotype   string                     `json:"sire_phenotype"`
	DamPhenotype    string                     `json:"dam_phenotype"`
	PupCount        int                        `json:"pup_count"`
	Hypotheses      []ParentGenotypeHypothesis `json:"hypotheses"`
	SireMarginal    []ParentGenotypeMarginal   `json:"sire_marginal"`
	DamMarginal     []ParentGenotypeMarginal   `json:"dam_marginal"`
	Notes           string                     `json:"notes"`
	PredictionBasis string                     `json:"prediction_basis"`
}

type parentCandidate struct {
	key     string
	display string
	prior   float64
	tags    []string
}

type scoredPair struct {
	sire, dam parentCandidate
	ll        float64
	prior     float64
	post      float64
}

// InferParentGenotypes ranks parent genotype pairs given offspring phenotype counts.
func InferParentGenotypes(req InferParentGenotypesRequest) (InferParentGenotypesResult, error) {
	if _, err := loadPhenotypeTable(); err != nil {
		return InferParentGenotypesResult{}, err
	}
	series, err := ResolveSeriesCode(req.Series)
	if err != nil {
		return InferParentGenotypesResult{}, err
	}
	ser := seriesByCode[series]
	sirePh := strings.TrimSpace(req.SirePhenotype)
	damPh := strings.TrimSpace(req.DamPhenotype)
	sireKey := strings.TrimSpace(req.SireGenotypeKey)
	damKey := strings.TrimSpace(req.DamGenotypeKey)

	if sireKey == "" && sirePh == "" {
		return InferParentGenotypesResult{}, fmt.Errorf("需要公的表型或基因型 key")
	}
	if damKey == "" && damPh == "" {
		return InferParentGenotypesResult{}, fmt.Errorf("需要母的表型或基因型 key")
	}
	if sirePh == "" {
		if ph, ok := PhenotypeFromGenotypeKey(series, sireKey); ok {
			sirePh = ph
		}
	}
	if damPh == "" {
		if ph, ok := PhenotypeFromGenotypeKey(series, damKey); ok {
			damPh = ph
		}
	}

	counts, pupCount := normalizeOffspringCounts(series, req.OffspringCounts)
	if pupCount == 0 {
		return InferParentGenotypesResult{}, fmt.Errorf("需要至少一只后代的表型计数")
	}

	sireCands, err := candidateParentGenotypes(series, sirePh, sireKey)
	if err != nil {
		return InferParentGenotypesResult{}, err
	}
	damCands, err := candidateParentGenotypes(series, damPh, damKey)
	if err != nil {
		return InferParentGenotypesResult{}, err
	}

	var rows []scoredPair
	maxLog := -math.MaxFloat64
	for _, s := range sireCands {
		for _, d := range damCands {
			probs, ok := phenotypeProbMap(series, s.key, d.key, sirePh, damPh)
			if !ok {
				continue
			}
			ll := multinomialLogLikelihood(counts, probs)
			if math.IsInf(ll, -1) {
				continue
			}
			pr := s.prior * d.prior
			if pr <= 0 {
				continue
			}
			rows = append(rows, scoredPair{sire: s, dam: d, ll: ll, prior: pr})
			lp := ll + math.Log(pr)
			if lp > maxLog {
				maxLog = lp
			}
		}
	}
	if len(rows) == 0 {
		return InferParentGenotypesResult{}, fmt.Errorf("在给定亲本表型下无法解释该窝次计数（似然全为 0）")
	}

	var sum float64
	for i := range rows {
		rows[i].post = math.Exp(rows[i].ll + math.Log(rows[i].prior) - maxLog)
		sum += rows[i].post
	}
	if sum <= 0 {
		return InferParentGenotypesResult{}, fmt.Errorf("后验归一化失败")
	}
	for i := range rows {
		rows[i].post /= sum
	}
	sort.SliceStable(rows, func(i, j int) bool {
		if rows[i].post == rows[j].post {
			return rows[i].ll > rows[j].ll
		}
		return rows[i].post > rows[j].post
	})

	maxH := req.MaxHypotheses
	if maxH <= 0 {
		maxH = 12
	}
	if maxH > len(rows) {
		maxH = len(rows)
	}
	hyp := make([]ParentGenotypeHypothesis, 0, maxH)
	for i := 0; i < maxH; i++ {
		r := rows[i]
		hyp = append(hyp, ParentGenotypeHypothesis{
			SireKey:       r.sire.key,
			DamKey:        r.dam.key,
			SireDisplay:   r.sire.display,
			DamDisplay:    r.dam.display,
			Probability:   r.post,
			LogLikelihood: r.ll,
			Prior:         r.prior,
		})
	}

	notes := "亲本基因型后验：位点模型作似然，目录默认基因型作弱先验；不改权威表正向概率。"
	notes += fmt.Sprintf(" 本窝 %d 只计入似然。", pupCount)
	if sireKey != "" || damKey != "" {
		notes += " 已固定至少一方基因型。"
	}

	return InferParentGenotypesResult{
		Series:          series,
		SeriesName:      ser.Name,
		SirePhenotype:   sirePh,
		DamPhenotype:    damPh,
		PupCount:        pupCount,
		Hypotheses:      hyp,
		SireMarginal:    marginalizeParentSide(rows, true),
		DamMarginal:     marginalizeParentSide(rows, false),
		Notes:           notes,
		PredictionBasis: PredictionBasisParentPosterior,
	}, nil
}

func candidateParentGenotypes(series, phenotype, fixedKey string) ([]parentCandidate, error) {
	if fixedKey != "" {
		ph, ok := PhenotypeFromGenotypeKey(series, fixedKey)
		if !ok {
			return nil, fmt.Errorf("无法解析基因型 key %q", fixedKey)
		}
		display := ph
		tags := carrierTagsFromKey(series, fixedKey)
		if len(tags) > 0 {
			display = ph + "（" + strings.Join(tags, "·") + "）"
		}
		return []parentCandidate{{key: fixedKey, display: display, prior: 1, tags: tags}}, nil
	}
	phenotype = strings.TrimSpace(phenotype)
	if phenotype == "" {
		return nil, fmt.Errorf("亲本表型为空")
	}

	if series == "chocolate" {
		if g, ok := chocolateParentGenotypeByLabel[NormalizePhenotypeLabel(series, phenotype)]; ok {
			return expandChocolateCandidates(phenotype, formatChocolateGenotypeKey(g)), nil
		}
	}
	if series == "poly" {
		if g, ok := polyParentGenoFromPhenotype(phenotype); ok {
			return expandPolyCandidates(phenotype, formatPolyGenotypeKey(g)), nil
		}
	}

	want := foldInferPhenotype(series, phenotype)
	var out []parentCandidate
	for _, c := range enumerateSeriesGenotypes(series) {
		if foldInferPhenotype(series, c.displayPhenotype) == want ||
			c.display == phenotype ||
			NormalizePhenotypeLabel(series, c.display) == NormalizePhenotypeLabel(series, phenotype) {
			out = append(out, parentCandidate{
				key: c.key, display: c.display, prior: parentGenotypeAltMass, tags: c.tags,
			})
		}
	}
	if len(out) == 0 {
		return nil, fmt.Errorf("表型 %q 没有可反推的基因型候选", phenotype)
	}
	return out, nil
}

func expandChocolateCandidates(phenotype, defaultKey string) []parentCandidate {
	base, ok := parseChocolateGenotypeKey(defaultKey)
	if !ok {
		return []parentCandidate{{key: defaultKey, display: phenotype, prior: parentGenotypePriorMass}}
	}
	type combo struct{ b, d, s string }
	variants := []combo{{base.b, base.d, base.s}}
	ph := chocolateOffspringPhenotype(base.b, base.d, base.s)
	normPh := NormalizePhenotypeLabel("chocolate", phenotype)

	addB := func(bs []string, d, s string) {
		for _, b := range bs {
			variants = append(variants, combo{b, d, s})
		}
	}
	if ph == "黑熊" || normPh == "普通黑熊" || phenotype == "黑熊" || phenotype == "携巧黑熊" {
		addB([]string{"BB", "Bb"}, base.d, base.s)
	}
	if ph == "鸽灰" || normPh == "普通鸽灰" || phenotype == "鸽灰" || phenotype == "携巧鸽灰" {
		addB([]string{"BB", "Bb"}, "dd", base.s)
	}
	if ph == "黑显斑" || normPh == "普通黑显斑" || phenotype == "黑显斑" || phenotype == "携巧黑显斑" {
		for _, s := range []string{"Ss", "SS"} {
			addB([]string{"BB", "Bb"}, base.d, s)
		}
	}
	if ph == "巧克力" || phenotype == "巧克力" || phenotype == "巧克力色" {
		for _, d := range []string{"DD", "Dd"} {
			variants = append(variants, combo{"bb", d, base.s})
		}
	}

	seen := map[string]struct{}{}
	var out []parentCandidate
	for _, v := range variants {
		g := chocolateParentGenotype{b: v.b, d: v.d, s: v.s}
		key := formatChocolateGenotypeKey(g)
		if _, dup := seen[key]; dup {
			continue
		}
		seen[key] = struct{}{}
		tags := []string{}
		if v.b == "Bb" {
			tags = append(tags, "携巧")
		}
		if v.d == "Dd" {
			tags = append(tags, "携稀释")
		}
		if v.s == "Ss" {
			tags = append(tags, "显斑杂合")
		}
		display := phenotype
		for label, pg := range chocolateParentGenotypeByLabel {
			if pg == g {
				display = label
				break
			}
		}
		if display == phenotype && len(tags) > 0 {
			display = phenotype + "（" + strings.Join(tags, "·") + "）"
		}
		prior := parentGenotypeAltMass
		if key == defaultKey {
			prior = parentGenotypePriorMass
		}
		out = append(out, parentCandidate{key: key, display: display, prior: prior, tags: tags})
	}
	return out
}

func expandPolyCandidates(phenotype, defaultKey string) []parentCandidate {
	base, ok := parsePolyGenotypeKey(defaultKey)
	if !ok {
		return []parentCandidate{{key: defaultKey, display: phenotype, prior: parentGenotypePriorMass}}
	}
	var expanded [][3]string
	var walk func(idx int, cur [3]string)
	walk = func(idx int, cur [3]string) {
		if idx == 3 {
			expanded = append(expanded, cur)
			return
		}
		if base[idx] == "aa" {
			cur[idx] = "aa"
			walk(idx+1, cur)
			return
		}
		for _, v := range []string{"AA", "Aa"} {
			cur[idx] = v
			walk(idx+1, cur)
		}
	}
	walk(0, [3]string{})

	seen := map[string]struct{}{}
	var out []parentCandidate
	for _, g := range expanded {
		key := formatPolyGenotypeKey(g)
		if _, dup := seen[key]; dup {
			continue
		}
		seen[key] = struct{}{}
		rec := [3]bool{g[0] == "aa", g[1] == "aa", g[2] == "aa"}
		ph := polyBitsPhenotype[rec]
		tags := []string{}
		if g[0] == "Aa" {
			tags = append(tags, "携肉桂")
		}
		if g[1] == "Aa" {
			tags = append(tags, "携黄")
		}
		if g[2] == "Aa" {
			tags = append(tags, "携黑")
		}
		display := ph
		if len(tags) > 0 {
			display = ph + "（" + strings.Join(tags, "·") + "）"
		}
		prior := parentGenotypeAltMass
		if key == defaultKey {
			prior = parentGenotypePriorMass
		}
		out = append(out, parentCandidate{key: key, display: display, prior: prior, tags: tags})
	}
	return out
}

type genoEnum struct {
	key              string
	display          string
	displayPhenotype string
	tags             []string
}

func enumerateSeriesGenotypes(series string) []genoEnum {
	var out []genoEnum
	switch series {
	case "chocolate":
		for _, b := range []string{"BB", "Bb", "bb"} {
			for _, d := range []string{"DD", "Dd", "dd"} {
				for _, s := range []string{"--", "Ss", "SS", "ss"} {
					g := chocolateParentGenotype{b: b, d: d, s: s}
					key := formatChocolateGenotypeKey(g)
					ph := chocolateOffspringPhenotype(b, d, s)
					tags := []string{}
					if b == "Bb" {
						tags = append(tags, "携巧")
					}
					if d == "Dd" {
						tags = append(tags, "携稀释")
					}
					if s == "Ss" {
						tags = append(tags, "显斑杂合")
					}
					display := ph
					for label, pg := range chocolateParentGenotypeByLabel {
						if pg == g {
							display = label
							break
						}
					}
					out = append(out, genoEnum{key: key, display: display, displayPhenotype: ph, tags: tags})
				}
			}
		}
	case "poly":
		for _, c := range []string{"AA", "Aa", "aa"} {
			for _, y := range []string{"AA", "Aa", "aa"} {
				for _, k := range []string{"AA", "Aa", "aa"} {
					g := [3]string{c, y, k}
					key := formatPolyGenotypeKey(g)
					rec := [3]bool{c == "aa", y == "aa", k == "aa"}
					ph := polyBitsPhenotype[rec]
					tags := []string{}
					if c == "Aa" {
						tags = append(tags, "携肉桂")
					}
					if y == "Aa" {
						tags = append(tags, "携黄")
					}
					if k == "Aa" {
						tags = append(tags, "携黑")
					}
					display := ph
					if len(tags) > 0 {
						display = ph + "（" + strings.Join(tags, "·") + "）"
					}
					out = append(out, genoEnum{key: key, display: display, displayPhenotype: ph, tags: tags})
				}
			}
		}
	}
	return out
}

func carrierTagsFromKey(series, key string) []string {
	switch series {
	case "chocolate":
		g, ok := parseChocolateGenotypeKey(key)
		if !ok {
			return nil
		}
		var tags []string
		if g.b == "Bb" {
			tags = append(tags, "携巧")
		}
		if g.d == "Dd" {
			tags = append(tags, "携稀释")
		}
		if g.s == "Ss" {
			tags = append(tags, "显斑杂合")
		}
		return tags
	case "poly":
		g, ok := parsePolyGenotypeKey(key)
		if !ok {
			return nil
		}
		var tags []string
		if g[0] == "Aa" {
			tags = append(tags, "携肉桂")
		}
		if g[1] == "Aa" {
			tags = append(tags, "携黄")
		}
		if g[2] == "Aa" {
			tags = append(tags, "携黑")
		}
		return tags
	}
	return nil
}

func phenotypeProbMap(series, sireKey, damKey, sirePh, damPh string) (map[string]float64, bool) {
	outcomes, _, ok := SimulateLocusModelDetailed(series, sirePh, damPh, sireKey, damKey)
	if !ok {
		return nil, false
	}
	// Canonical keys only (fold aliases) so likelihood matches normalized counts.
	out := map[string]float64{}
	for _, o := range outcomes {
		out[foldInferPhenotype(series, o.Phenotype)] += o.Probability
	}
	return out, true
}

func normalizeOffspringCounts(series string, raw map[string]int) (map[string]int, int) {
	out := map[string]int{}
	total := 0
	for k, c := range raw {
		if c <= 0 {
			continue
		}
		label := strings.TrimSpace(k)
		if label == "" {
			continue
		}
		canon := foldInferPhenotype(series, label)
		if series == "chocolate" {
			switch canon {
			case "普通黑熊":
				canon = "黑熊"
			case "普通鸽灰":
				canon = "鸽灰"
			case "普通黑显斑":
				canon = "黑显斑"
			}
		}
		out[canon] += c
		total += c
	}
	return out, total
}

func foldInferPhenotype(series, label string) string {
	label = strings.TrimSpace(label)
	if series == "chocolate" {
		switch label {
		case "巧克力色":
			return "巧克力"
		case "巧显斑":
			return "巧克力显斑"
		case "普通黑熊":
			return "黑熊"
		case "普通鸽灰":
			return "鸽灰"
		case "普通黑显斑":
			return "黑显斑"
		}
	}
	return label
}

func multinomialLogLikelihood(counts map[string]int, probs map[string]float64) float64 {
	n := 0
	for _, c := range counts {
		n += c
	}
	if n == 0 {
		return 0
	}
	ll := logFactorial(n)
	for ph, c := range counts {
		if c <= 0 {
			continue
		}
		p := probs[ph]
		if p <= 0 {
			return math.Inf(-1)
		}
		ll += float64(c)*math.Log(p) - logFactorial(c)
	}
	return ll
}

func logFactorial(n int) float64 {
	if n < 0 {
		return math.Inf(-1)
	}
	if n < 2 {
		return 0
	}
	if n <= 170 {
		var v float64
		for i := 2; i <= n; i++ {
			v += math.Log(float64(i))
		}
		return v
	}
	fn := float64(n)
	return fn*math.Log(fn) - fn + 0.5*math.Log(2*math.Pi*fn)
}

func marginalizeParentSide(rows []scoredPair, sireSide bool) []ParentGenotypeMarginal {
	type acc struct {
		p       float64
		display string
		tags    []string
	}
	mass := map[string]acc{}
	for _, r := range rows {
		c := r.dam
		if sireSide {
			c = r.sire
		}
		e := mass[c.key]
		e.p += r.post
		e.display = c.display
		e.tags = c.tags
		mass[c.key] = e
	}
	out := make([]ParentGenotypeMarginal, 0, len(mass))
	for k, e := range mass {
		out = append(out, ParentGenotypeMarginal{
			Key:          k,
			DisplayLabel: e.display,
			Probability:  e.p,
			CarrierTags:  e.tags,
		})
	}
	sort.SliceStable(out, func(i, j int) bool {
		if out[i].Probability == out[j].Probability {
			return out[i].Key < out[j].Key
		}
		return out[i].Probability > out[j].Probability
	})
	return out
}
