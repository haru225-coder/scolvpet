// Locus models reverse-engineered from the authority phenotype table.
//
// Discipline: authority-table probabilities always win when a cross is listed.
// Models only fill gaps and must pass golden tests against all table rows before
// being trusted (see locus_model_test.go).
//
// Poly = 3 independent bi-allelic loci with complete dominance; non-recessive
// parents are modeled as heterozygotes (matches the Excel table construction).
// Chocolate = b (chocolate) × d (dilute) × Ds (spotting).
package geneticcore

import (
	"fmt"
	"sort"
	"strings"
)

// PredictionBasisLocusModel marks results filled by the Mendelian locus model
// rather than a direct authority-table row.
const PredictionBasisLocusModel = "locus_model"

// rat is a non-negative rational probability (num/den in lowest terms).
type rat struct {
	num int64
	den int64
}

func rInt(n int64) rat { return reduceRat(n, 1) }

func reduceRat(n, d int64) rat {
	if d < 0 {
		n, d = -n, -d
	}
	if d == 0 {
		return rat{0, 1}
	}
	if n == 0 {
		return rat{0, 1}
	}
	g := gcd64(abs64(n), d)
	return rat{n / g, d / g}
}

// zero-value rat has den==0; treat as 0/1 so map[key].add(x) works.
func (a rat) norm() rat {
	if a.den == 0 {
		return rat{0, 1}
	}
	return a
}

func (a rat) add(b rat) rat {
	a, b = a.norm(), b.norm()
	return reduceRat(a.num*b.den+b.num*a.den, a.den*b.den)
}
func (a rat) mul(b rat) rat {
	a, b = a.norm(), b.norm()
	return reduceRat(a.num*b.num, a.den*b.den)
}
func (a rat) float() float64 {
	a = a.norm()
	return float64(a.num) / float64(a.den)
}
func (a rat) fraction() string {
	a = a.norm()
	if a.den == 1 {
		return fmt.Sprintf("%d", a.num)
	}
	return fmt.Sprintf("%d/%d", a.num, a.den)
}

func gcd64(a, b int64) int64 {
	for b != 0 {
		a, b = b, a%b
	}
	if a < 0 {
		return -a
	}
	return a
}

func abs64(v int64) int64 {
	if v < 0 {
		return -v
	}
	return v
}

// ---- poly: recessive bits (cinnamon, yellow, black) ----

// polyPhenotypeBits maps table phenotype → (cinnamon, yellow, black) recessive flags.
var polyPhenotypeBits = map[string][3]bool{
	"火波利":  {false, false, false},
	"肉桂波利": {true, false, false},
	"黄波利":  {false, true, false},
	"黑波利":  {false, false, true},
	"蜜波利":  {true, true, false},
	"鸽灰波利": {true, false, true},
	"黑黄波利": {false, true, true},
	"黑蜜波利": {true, true, true},
}

var polyBitsPhenotype = func() map[[3]bool]string {
	m := make(map[[3]bool]string, len(polyPhenotypeBits))
	for name, bits := range polyPhenotypeBits {
		m[bits] = name
	}
	return m
}()

// ---- chocolate genotypes (allele pairs as two-char strings) ----

// chocolateParentGenotype is (b-locus, d-locus, spot-locus).
// spot "--" means no spotting alleles in the simplified table model.
type chocolateParentGenotype struct {
	b, d, s string
}

// Canonical chocolate parent labels used by the model (aliases fold here).
var chocolateParentGenotypeByLabel = map[string]chocolateParentGenotype{
	"普通黑熊":  {b: "BB", d: "DD", s: "--"},
	"携巧黑熊":  {b: "Bb", d: "DD", s: "--"},
	"巧克力":   {b: "bb", d: "Dd", s: "--"},
	"普通鸽灰":  {b: "BB", d: "dd", s: "--"},
	"携巧鸽灰":  {b: "Bb", d: "dd", s: "--"},
	"香槟色":   {b: "bb", d: "dd", s: "--"},
	"普通黑显斑": {b: "BB", d: "DD", s: "Ss"},
	"携巧黑显斑": {b: "Bb", d: "DD", s: "Ss"},
	"巧克力显斑": {b: "bb", d: "DD", s: "Ss"},
}

// NormalizePhenotypeLabel folds synonyms so table lookup / model share one key.
// series is poly | chocolate (already resolved).
func NormalizePhenotypeLabel(series, raw string) string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return raw
	}
	switch series {
	case "chocolate":
		switch raw {
		case "巧克力色":
			return "巧克力"
		case "巧显斑":
			return "巧克力显斑"
		case "鸽灰":
			return "普通鸽灰"
		case "黑显斑":
			return "普通黑显斑"
		case "黑熊":
			return "普通黑熊"
		}
	}
	return raw
}

// PhenotypeLabelAliases returns the input plus known synonyms (for table key search).
func PhenotypeLabelAliases(series, raw string) []string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return nil
	}
	canon := NormalizePhenotypeLabel(series, raw)
	set := map[string]struct{}{raw: {}, canon: {}}
	if series == "chocolate" {
		switch canon {
		case "巧克力":
			set["巧克力色"] = struct{}{}
			set["巧克力"] = struct{}{}
		case "巧克力显斑":
			set["巧显斑"] = struct{}{}
			set["巧克力显斑"] = struct{}{}
		case "普通鸽灰":
			set["鸽灰"] = struct{}{}
			set["普通鸽灰"] = struct{}{}
		case "普通黑显斑":
			set["黑显斑"] = struct{}{}
			set["普通黑显斑"] = struct{}{}
		case "普通黑熊":
			set["黑熊"] = struct{}{}
			set["普通黑熊"] = struct{}{}
		}
	}
	out := make([]string, 0, len(set))
	for k := range set {
		if k != "" {
			out = append(out, k)
		}
	}
	sort.Strings(out)
	return out
}

func phenotypeInSeriesOrAlias(ser PhenotypeSeries, name string) bool {
	if phenotypeInSeries(ser, name) {
		return true
	}
	for _, a := range PhenotypeLabelAliases(ser.Code, name) {
		if phenotypeInSeries(ser, a) {
			return true
		}
	}
	// model-known labels even if not listed (defensive)
	if ser.Code == "poly" {
		_, ok := polyPhenotypeBits[NormalizePhenotypeLabel(ser.Code, name)]
		return ok
	}
	if ser.Code == "chocolate" {
		_, ok := chocolateParentGenotypeByLabel[NormalizePhenotypeLabel(ser.Code, name)]
		return ok
	}
	return false
}

// SimulateLocusModel predicts offspring phenotype distribution from the Mendelian model.
// Returns false when either parent is not in the model catalog.
func SimulateLocusModel(series, sirePhenotype, damPhenotype string) (outcomes []PhenotypeOutcome, ok bool) {
	outcomes, _, ok = SimulateLocusModelDetailed(series, sirePhenotype, damPhenotype, "", "")
	return outcomes, ok
}

// SimulateLocusModelDetailed returns phenotype buckets + flat genotype list (for multi-gen).
func SimulateLocusModelDetailed(series, sirePhenotype, damPhenotype, sireKey, damKey string) (outcomes []PhenotypeOutcome, flat []GenotypeSlice, ok bool) {
	series = strings.TrimSpace(series)
	slices, ok := simulateGenotypeSlices(series, sirePhenotype, damPhenotype, sireKey, damKey)
	if !ok {
		return nil, nil, false
	}
	outcomes = collapseGenotypeSlices(slices)
	flat = sortGenotypeSlices(slices)
	return outcomes, flat, true
}

// enrichOutcomesWithGenotypes attaches model genotype splits under table phenotype probs.
// Phenotype margins stay as provided; genotype probs are scaled to each phenotype bucket.
func enrichOutcomesWithGenotypes(series, sirePh, damPh, sireKey, damKey string, outcomes []PhenotypeOutcome) ([]PhenotypeOutcome, []GenotypeSlice) {
	slices, ok := simulateGenotypeSlices(series, sirePh, damPh, sireKey, damKey)
	if !ok {
		return outcomes, nil
	}
	byPheno := map[string][]GenotypeSlice{}
	phenoModelP := map[string]float64{}
	for _, s := range slices {
		byPheno[s.Phenotype] = append(byPheno[s.Phenotype], s)
		phenoModelP[s.Phenotype] += s.Probability
	}
	var flat []GenotypeSlice
	for i := range outcomes {
		ph := outcomes[i].Phenotype
		// fold chocolate synonyms on table side
		modelPh := ph
		if series == "chocolate" {
			switch ph {
			case "巧克力色":
				modelPh = "巧克力"
			case "巧显斑":
				modelPh = "巧克力显斑"
			}
		}
		group := byPheno[modelPh]
		if len(group) == 0 {
			// try exact
			group = byPheno[ph]
		}
		modelP := phenoModelP[modelPh]
		if modelP <= 0 {
			modelP = phenoModelP[ph]
		}
		if len(group) == 0 || modelP <= 0 {
			continue
		}
		scaled := make([]GenotypeSlice, 0, len(group))
		for _, g := range group {
			gg := g
			gg.Probability = g.Probability / modelP * outcomes[i].Probability
			gg.Fraction = approxFraction(gg.Probability)
			scaled = append(scaled, gg)
		}
		sortGenotypeSlicesInPlace(scaled)
		outcomes[i].GenotypeBreakdown = scaled
		outcomes[i].CarrierSummary = carrierSummary(scaled)
		flat = append(flat, scaled...)
	}
	return outcomes, sortGenotypeSlices(flat)
}

func simulateGenotypeSlices(series, sirePhenotype, damPhenotype, sireKey, damKey string) ([]GenotypeSlice, bool) {
	series = strings.TrimSpace(series)
	switch series {
	case "poly":
		return simulatePolyGenotypes(sirePhenotype, damPhenotype, sireKey, damKey)
	case "chocolate":
		return simulateChocolateGenotypes(sirePhenotype, damPhenotype, sireKey, damKey)
	default:
		return nil, false
	}
}

func polyParentGenoFromPhenotype(label string) ([3]string, bool) {
	bits, ok := polyPhenotypeBits[NormalizePhenotypeLabel("poly", label)]
	if !ok {
		return [3]string{}, false
	}
	parentGeno := func(recessive bool) string {
		if recessive {
			return "aa"
		}
		return "Aa"
	}
	return [3]string{parentGeno(bits[0]), parentGeno(bits[1]), parentGeno(bits[2])}, true
}

func parsePolyGenotypeKey(key string) ([3]string, bool) {
	// c=Aa|y=Aa|k=aa
	parts := strings.Split(key, "|")
	m := map[string]string{}
	for _, p := range parts {
		kv := strings.SplitN(p, "=", 2)
		if len(kv) != 2 {
			return [3]string{}, false
		}
		m[strings.TrimSpace(kv[0])] = strings.TrimSpace(kv[1])
	}
	c, y, k := m["c"], m["y"], m["k"]
	if c == "" || y == "" || k == "" {
		return [3]string{}, false
	}
	norm := func(raw string) (string, bool) {
		raw = strings.ReplaceAll(raw, "/", "")
		if raw != "AA" && raw != "Aa" && raw != "aA" && raw != "aa" {
			return "", false
		}
		if raw == "aA" {
			raw = "Aa"
		}
		return raw, true
	}
	c, ok1 := norm(c)
	y, ok2 := norm(y)
	k, ok3 := norm(k)
	if !ok1 || !ok2 || !ok3 {
		return [3]string{}, false
	}
	return [3]string{c, y, k}, true
}

func formatPolyGenotypeKey(g [3]string) string {
	return "c=" + g[0] + "|y=" + g[1] + "|k=" + g[2]
}

func simulatePolyGenotypes(sirePh, damPh, sireKey, damKey string) ([]GenotypeSlice, bool) {
	var sireG, damG [3]string
	var ok bool
	if sireKey != "" {
		sireG, ok = parsePolyGenotypeKey(sireKey)
		if !ok {
			return nil, false
		}
	} else {
		sireG, ok = polyParentGenoFromPhenotype(sirePh)
		if !ok {
			return nil, false
		}
	}
	if damKey != "" {
		damG, ok = parsePolyGenotypeKey(damKey)
		if !ok {
			return nil, false
		}
	} else {
		damG, ok = polyParentGenoFromPhenotype(damPh)
		if !ok {
			return nil, false
		}
	}

	// Per-locus genotype distribution of offspring (AA/Aa/aa)
	locusDist := make([]map[string]rat, 3)
	for i := 0; i < 3; i++ {
		locusDist[i] = map[string]rat{}
		for _, a := range sireG[i] {
			for _, b := range damG[i] {
				chars := []byte{byte(a), byte(b)}
				// stable: A before a
				if chars[0] > chars[1] {
					// want dominant first if present
				}
				// normalize pair: AA, Aa, aa
				var pair string
				switch {
				case a == 'A' && b == 'A':
					pair = "AA"
				case a == 'a' && b == 'a':
					pair = "aa"
				default:
					pair = "Aa"
				}
				locusDist[i][pair] = locusDist[i][pair].add(reduceRat(1, 4))
			}
		}
	}

	var out []GenotypeSlice
	for c, p0 := range locusDist[0] {
		for y, p1 := range locusDist[1] {
			for k, p2 := range locusDist[2] {
				p := p0.mul(p1).mul(p2)
				if p.num == 0 {
					continue
				}
				g := [3]string{c, y, k}
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
				out = append(out, GenotypeSlice{
					Key:          formatPolyGenotypeKey(g),
					Alleles:      map[string]string{"c": c, "y": y, "k": k},
					Probability:  p.float(),
					Fraction:     p.fraction(),
					Phenotype:    ph,
					DisplayLabel: display,
					CarrierTags:  tags,
				})
			}
		}
	}
	return out, true
}

func parseChocolateGenotypeKey(key string) (chocolateParentGenotype, bool) {
	// b=Bb|d=DD|s=--
	parts := strings.Split(key, "|")
	m := map[string]string{}
	for _, p := range parts {
		kv := strings.SplitN(p, "=", 2)
		if len(kv) != 2 {
			return chocolateParentGenotype{}, false
		}
		m[strings.TrimSpace(kv[0])] = strings.TrimSpace(kv[1])
	}
	b, d, s := m["b"], m["d"], m["s"]
	if b == "" || d == "" || s == "" {
		return chocolateParentGenotype{}, false
	}
	normPair := func(raw string, dom, rec byte) (string, bool) {
		raw = strings.ReplaceAll(raw, "/", "")
		switch raw {
		case string([]byte{dom, dom}):
			return raw, true
		case string([]byte{rec, rec}):
			return raw, true
		case string([]byte{dom, rec}), string([]byte{rec, dom}):
			return string([]byte{dom, rec}), true
		case "--":
			return "--", true
		case "Ss", "sS":
			return "Ss", true
		case "SS", "ss":
			return raw, true
		default:
			return "", false
		}
	}
	bn, ok1 := normPair(b, 'B', 'b')
	dn, ok2 := normPair(d, 'D', 'd')
	if !ok1 || !ok2 {
		return chocolateParentGenotype{}, false
	}
	sn := s
	switch s {
	case "--", "SS", "ss", "Ss", "sS":
		if s == "sS" {
			sn = "Ss"
		}
	default:
		return chocolateParentGenotype{}, false
	}
	return chocolateParentGenotype{b: bn, d: dn, s: sn}, true
}

func formatChocolateGenotypeKey(g chocolateParentGenotype) string {
	return "b=" + g.b + "|d=" + g.d + "|s=" + g.s
}

// PhenotypeFromGenotypeKey returns a display phenotype for a genotype key.
func PhenotypeFromGenotypeKey(series, key string) (string, bool) {
	series = strings.TrimSpace(series)
	key = strings.TrimSpace(key)
	switch series {
	case "poly":
		g, ok := parsePolyGenotypeKey(key)
		if !ok {
			return "", false
		}
		rec := [3]bool{g[0] == "aa", g[1] == "aa", g[2] == "aa"}
		ph, ok := polyBitsPhenotype[rec]
		return ph, ok
	case "chocolate":
		g, ok := parseChocolateGenotypeKey(key)
		if !ok {
			return "", false
		}
		// Prefer parent catalog labels when exact match.
		for label, pg := range chocolateParentGenotypeByLabel {
			if pg == g {
				return label, true
			}
		}
		return chocolateOffspringPhenotype(g.b, g.d, g.s), true
	default:
		return "", false
	}
}

func simulateChocolateGenotypes(sirePh, damPh, sireKey, damKey string) ([]GenotypeSlice, bool) {
	var sg, dg chocolateParentGenotype
	var ok bool
	if sireKey != "" {
		sg, ok = parseChocolateGenotypeKey(sireKey)
		if !ok {
			return nil, false
		}
	} else {
		sg, ok = chocolateParentGenotypeByLabel[NormalizePhenotypeLabel("chocolate", sirePh)]
		if !ok {
			return nil, false
		}
	}
	if damKey != "" {
		dg, ok = parseChocolateGenotypeKey(damKey)
		if !ok {
			return nil, false
		}
	} else {
		dg, ok = chocolateParentGenotypeByLabel[NormalizePhenotypeLabel("chocolate", damPh)]
		if !ok {
			return nil, false
		}
	}

	crossLocus := func(g1, g2 string) map[string]rat {
		out := map[string]rat{}
		for _, a := range g1 {
			for _, b := range g2 {
				chars := []byte{byte(a), byte(b)}
				if chars[0] < chars[1] {
					chars[0], chars[1] = chars[1], chars[0]
				}
				k := string(chars)
				out[k] = out[k].add(reduceRat(1, 4))
			}
		}
		return out
	}

	bs := crossLocus(sg.b, dg.b)
	ds := crossLocus(sg.d, dg.d)
	var ss map[string]rat
	if sg.s == "--" && dg.s == "--" {
		ss = map[string]rat{"--": rInt(1)}
	} else {
		ss = crossLocus(sg.s, dg.s)
	}

	// Normalize allele keys to BB/Bb/bb (reverse-sort may yield bB).
	normBD := func(k string, dom, rec byte) string {
		hasDom := strings.ContainsRune(k, rune(dom))
		hasRec := strings.ContainsRune(k, rune(rec))
		switch {
		case hasDom && hasRec:
			return string([]byte{dom, rec})
		case hasRec && !hasDom:
			return string([]byte{rec, rec})
		case hasDom && !hasRec:
			return string([]byte{dom, dom})
		default:
			return k
		}
	}
	normS := func(k string) string {
		if k == "--" || k == string([]byte{'-', '-'}) {
			return "--"
		}
		hasS := strings.Contains(k, "S")
		hasSmall := strings.Contains(k, "s")
		hasDash := strings.Contains(k, "-")
		switch {
		case hasS && hasSmall:
			return "Ss"
		case hasS && hasDash:
			return "Ss" // S vs null → treat as hetero-like for labeling
		case hasSmall && hasDash:
			return "ss"
		case hasS && !hasSmall:
			return "SS"
		case hasSmall && !hasS:
			return "ss"
		default:
			return k
		}
	}

	var out []GenotypeSlice
	for bk, bp := range bs {
		for dk, dp := range ds {
			for sk, sp := range ss {
				p := bp.mul(dp).mul(sp)
				if p.num == 0 {
					continue
				}
				bn := normBD(bk, 'B', 'b')
				dn := normBD(dk, 'D', 'd')
				sn := normS(sk)
				// offspring phenotype collapse (table vocabulary)
				ph := chocolateOffspringPhenotype(bn, dn, sn)
				tags := []string{}
				if bn == "Bb" {
					tags = append(tags, "携巧")
				}
				if dn == "Dd" {
					tags = append(tags, "携稀释")
				}
				if sn == "Ss" {
					tags = append(tags, "显斑杂合")
				}
				display := ph
				// Prefer catalog parent names when genotype matches a named class.
				g := chocolateParentGenotype{b: bn, d: dn, s: sn}
				for label, pg := range chocolateParentGenotypeByLabel {
					if pg == g {
						display = label
						break
					}
				}
				if display == ph && len(tags) > 0 {
					display = ph + "（" + strings.Join(tags, "·") + "）"
				}
				out = append(out, GenotypeSlice{
					Key:          formatChocolateGenotypeKey(g),
					Alleles:      map[string]string{"b": bn, "d": dn, "s": sn},
					Probability:  p.float(),
					Fraction:     p.fraction(),
					Phenotype:    ph,
					DisplayLabel: display,
					CarrierTags:  tags,
				})
			}
		}
	}
	return out, true
}

func chocolateOffspringPhenotype(bKey, dKey, sKey string) string {
	choc := bKey == "bb"
	dil := dKey == "dd"
	spot := strings.Contains(sKey, "S")
	if spot {
		if choc {
			return "巧克力显斑"
		}
		return "黑显斑"
	}
	if choc {
		if dil {
			return "香槟色"
		}
		return "巧克力"
	}
	if dil {
		return "鸽灰"
	}
	return "黑熊"
}

func collapseGenotypeSlices(slices []GenotypeSlice) []PhenotypeOutcome {
	type acc struct {
		p     float64
		items []GenotypeSlice
	}
	by := map[string]*acc{}
	for _, s := range slices {
		a := by[s.Phenotype]
		if a == nil {
			a = &acc{}
			by[s.Phenotype] = a
		}
		a.p += s.Probability
		a.items = append(a.items, s)
	}
	out := make([]PhenotypeOutcome, 0, len(by))
	for ph, a := range by {
		if a.p <= 0 {
			continue
		}
		sortGenotypeSlicesInPlace(a.items)
		out = append(out, PhenotypeOutcome{
			Phenotype:         ph,
			Probability:       a.p,
			Fraction:          approxFraction(a.p),
			CarrierSummary:    carrierSummary(a.items),
			GenotypeBreakdown: a.items,
		})
	}
	sortPhenotypeOutcomes(out)
	return out
}

// rescaleGenotypeBreakdowns keeps within-phenotype genotype splits proportional
// after phenotype probabilities change (e.g. history calibration).
func rescaleGenotypeBreakdowns(outcomes []PhenotypeOutcome) {
	for i := range outcomes {
		parts := outcomes[i].GenotypeBreakdown
		if len(parts) == 0 {
			continue
		}
		var sum float64
		for _, g := range parts {
			sum += g.Probability
		}
		if sum <= 0 {
			continue
		}
		target := outcomes[i].Probability
		for j := range parts {
			parts[j].Probability = parts[j].Probability / sum * target
			parts[j].Fraction = approxFraction(parts[j].Probability)
		}
		sortGenotypeSlicesInPlace(parts)
		outcomes[i].GenotypeBreakdown = parts
		outcomes[i].CarrierSummary = carrierSummary(parts)
	}
}

func flattenGenotypeOutcomes(outcomes []PhenotypeOutcome) []GenotypeSlice {
	var flat []GenotypeSlice
	for _, o := range outcomes {
		flat = append(flat, o.GenotypeBreakdown...)
	}
	return sortGenotypeSlices(flat)
}

func carrierSummary(slices []GenotypeSlice) string {
	if len(slices) == 0 {
		return ""
	}
	// Prefer 携巧 for chocolate; any carrier tag with highest mass
	tagMass := map[string]float64{}
	var total float64
	for _, s := range slices {
		total += s.Probability
		for _, t := range s.CarrierTags {
			tagMass[t] += s.Probability
		}
	}
	if total <= 0 {
		return ""
	}
	// stable preference order
	prefer := []string{"携巧", "携稀释", "显斑杂合", "携肉桂", "携黄", "携黑"}
	var parts []string
	for _, tag := range prefer {
		m, ok := tagMass[tag]
		if !ok || m <= 0 {
			continue
		}
		share := m / total
		if share >= 0.999 {
			parts = append(parts, "全部为"+tag)
		} else {
			parts = append(parts, fmt.Sprintf("约 %s 为%s", approxFraction(share), tag))
		}
	}
	if len(parts) == 0 {
		// pure class
		if len(slices) == 1 {
			return "基因型较单纯（" + slices[0].DisplayLabel + "）"
		}
		return ""
	}
	return "其中" + strings.Join(parts, "，")
}

func approxFraction(p float64) string {
	if p <= 0 {
		return "0"
	}
	if p >= 0.999 {
		return "1"
	}
	for _, den := range []int64{2, 3, 4, 5, 6, 8, 16, 32, 64} {
		num := int64(p*float64(den) + 0.5)
		if num <= 0 {
			continue
		}
		if absFloat(float64(num)/float64(den)-p) < 1e-6 {
			r := reduceRat(num, den)
			return r.fraction()
		}
	}
	return fmt.Sprintf("%.4f", p)
}

func sortGenotypeSlices(in []GenotypeSlice) []GenotypeSlice {
	out := append([]GenotypeSlice(nil), in...)
	sortGenotypeSlicesInPlace(out)
	return out
}

func sortGenotypeSlicesInPlace(out []GenotypeSlice) {
	sort.SliceStable(out, func(i, j int) bool {
		if out[i].Probability == out[j].Probability {
			return out[i].Key < out[j].Key
		}
		return out[i].Probability > out[j].Probability
	})
}

// ModelKnownPhenotypes lists labels the locus model can take as parents.
// Prefer authority catalog names (including synonyms) so UI pickers cover 14 chocolate labels → 105 pairs.
func ModelKnownPhenotypes(series string) []string {
	if ser, ok := seriesByCode[series]; ok && len(ser.Phenotypes) > 0 {
		var out []string
		for _, p := range ser.Phenotypes {
			if _, ok := SimulateLocusModel(series, p, p); ok {
				out = append(out, p)
			}
		}
		if len(out) > 0 {
			sort.Strings(out)
			return out
		}
	}
	switch series {
	case "poly":
		out := make([]string, 0, len(polyPhenotypeBits))
		for k := range polyPhenotypeBits {
			out = append(out, k)
		}
		sort.Strings(out)
		return out
	case "chocolate":
		out := make([]string, 0, len(chocolateParentGenotypeByLabel))
		for k := range chocolateParentGenotypeByLabel {
			out = append(out, k)
		}
		sort.Strings(out)
		return out
	default:
		return nil
	}
}

// EnumerateModelCrosses returns all unordered parent pairs the model can simulate.
// Chocolate catalog (14 labels incl. synonyms) → 14×15/2 = 105 pairs.
func EnumerateModelCrosses(series string) []PhenotypeCross {
	if _, err := loadPhenotypeTable(); err != nil {
		return nil
	}
	labels := ModelKnownPhenotypes(series)
	if len(labels) == 0 {
		return nil
	}
	serName := series
	if s, ok := seriesByCode[series]; ok {
		serName = s.Name
	}
	var out []PhenotypeCross
	for i := 0; i < len(labels); i++ {
		for j := i; j < len(labels); j++ {
			a, b := normalizeParentPair(labels[i], labels[j])
			outcomes, ok := SimulateLocusModel(series, a, b)
			if !ok || len(outcomes) == 0 {
				continue
			}
			sum := 0.0
			for _, o := range outcomes {
				sum += o.Probability
			}
			out = append(out, PhenotypeCross{
				Series:         series,
				SeriesName:     serName,
				ParentA:        a,
				ParentB:        b,
				Outcomes:       outcomes,
				ProbabilitySum: sum,
			})
		}
	}
	return out
}
