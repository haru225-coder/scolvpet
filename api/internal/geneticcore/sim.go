// Package geneticcore implements a simplified Mendelian breeding simulator
// for Syrian hamster (mesocricetus_auratus) educational use (T-P1-06).
package geneticcore

import (
	"fmt"
	"sort"
	"strings"
)

// Locus is a bi-allelic locus with complete dominance (simplified).
type Locus struct {
	Code           string `json:"code"`
	Name           string `json:"name"`
	Dominant       string `json:"dominant_allele"`
	Recessive      string `json:"recessive_allele"`
	DominantLabel  string `json:"dominant_label"`
	RecessiveLabel string `json:"recessive_label"`
	Description    string `json:"description,omitempty"`
}

// DefaultLoci is a small educational catalog (not a full species genetics model).
var DefaultLoci = []Locus{
	{
		Code: "A", Name: "刺鼠色", Dominant: "A", Recessive: "a",
		DominantLabel: "刺鼠", RecessiveLabel: "黑",
		Description: "A 对 a 完全显性（简化）",
	},
	{
		Code: "B", Name: "黑/肉桂", Dominant: "B", Recessive: "b",
		DominantLabel: "黑系", RecessiveLabel: "肉桂",
		Description: "B 对 b 完全显性（简化）",
	},
	{
		Code: "C", Name: "色素", Dominant: "C", Recessive: "c",
		DominantLabel: "有色", RecessiveLabel: "白化",
		Description: "C 对 c 完全显性（简化）",
	},
}

// Genotype is locus code → allele pair string like "A/a".
type Genotype map[string]string

// Outcome is one simulated offspring class with probability.
type Outcome struct {
	GenotypeKey    string             `json:"genotype_key"`
	Genotype       map[string]string  `json:"genotype"`
	PhenotypeLabel string             `json:"phenotype_label"`
	Phenotype      map[string]string  `json:"phenotype"`
	Probability    float64            `json:"probability"`
	CountWeight    int                `json:"count_weight"`
}

// SimulationResult is the full Punnett multi-locus result.
type SimulationResult struct {
	Sire     Genotype  `json:"sire"`
	Dam      Genotype  `json:"dam"`
	Outcomes []Outcome `json:"outcomes"`
	Notes    string    `json:"notes"`
}

// NormalizeAllelePair validates and normalizes "A/a" or "Aa" into "A/a".
func NormalizeAllelePair(locus Locus, raw string) (string, error) {
	raw = strings.TrimSpace(raw)
	raw = strings.ReplaceAll(raw, " ", "")
	var a1, a2 string
	if strings.Contains(raw, "/") {
		parts := strings.Split(raw, "/")
		if len(parts) != 2 {
			return "", fmt.Errorf("位点 %s 基因型格式无效", locus.Code)
		}
		a1, a2 = parts[0], parts[1]
	} else if len([]rune(raw)) == 2 {
		runes := []rune(raw)
		a1, a2 = string(runes[0]), string(runes[1])
	} else {
		return "", fmt.Errorf("位点 %s 基因型格式无效", locus.Code)
	}
	valid := map[string]bool{locus.Dominant: true, locus.Recessive: true}
	if !valid[a1] || !valid[a2] {
		return "", fmt.Errorf("位点 %s 等位基因须为 %s 或 %s", locus.Code, locus.Dominant, locus.Recessive)
	}
	// Order: dominant first when heterozygous for stable keys.
	if a1 == locus.Recessive && a2 == locus.Dominant {
		a1, a2 = a2, a1
	}
	return a1 + "/" + a2, nil
}

// PhenotypeFor returns simplified phenotype labels for a genotype.
func PhenotypeFor(gt Genotype) (map[string]string, string) {
	labels := make(map[string]string)
	parts := make([]string, 0, len(DefaultLoci))
	for _, locus := range DefaultLoci {
		pair, ok := gt[locus.Code]
		if !ok || pair == "" {
			continue
		}
		normalized, err := NormalizeAllelePair(locus, pair)
		if err != nil {
			continue
		}
		alleles := strings.Split(normalized, "/")
		recessiveOnly := alleles[0] == locus.Recessive && alleles[1] == locus.Recessive
		if recessiveOnly {
			labels[locus.Code] = locus.RecessiveLabel
			parts = append(parts, locus.RecessiveLabel)
		} else {
			labels[locus.Code] = locus.DominantLabel
			parts = append(parts, locus.DominantLabel)
		}
	}
	if len(parts) == 0 {
		return labels, "未知表型"
	}
	return labels, strings.Join(parts, " · ")
}

// Simulate multi-locus independent assortment with complete dominance.
func Simulate(sire, dam Genotype) (SimulationResult, error) {
	sireN := Genotype{}
	damN := Genotype{}
	lociUsed := make([]Locus, 0, len(DefaultLoci))
	for _, locus := range DefaultLoci {
		sRaw, sOK := sire[locus.Code]
		dRaw, dOK := dam[locus.Code]
		if !sOK && !dOK {
			continue
		}
		if !sOK || !dOK {
			return SimulationResult{}, fmt.Errorf("位点 %s 父母双方都需要基因型", locus.Code)
		}
		sNorm, err := NormalizeAllelePair(locus, sRaw)
		if err != nil {
			return SimulationResult{}, err
		}
		dNorm, err := NormalizeAllelePair(locus, dRaw)
		if err != nil {
			return SimulationResult{}, err
		}
		sireN[locus.Code] = sNorm
		damN[locus.Code] = dNorm
		lociUsed = append(lociUsed, locus)
	}
	if len(lociUsed) == 0 {
		return SimulationResult{}, fmt.Errorf("至少需要一个共同位点")
	}

	// Start with one empty combination weight 1.
	type combo struct {
		gt     map[string]string
		weight int
	}
	combos := []combo{{gt: map[string]string{}, weight: 1}}
	for _, locus := range lociUsed {
		sAlleles := strings.Split(sireN[locus.Code], "/")
		dAlleles := strings.Split(damN[locus.Code], "/")
		next := make([]combo, 0, len(combos)*4)
		for _, c := range combos {
			for _, sa := range sAlleles {
				for _, da := range dAlleles {
					pair, err := NormalizeAllelePair(locus, sa+"/"+da)
					if err != nil {
						return SimulationResult{}, err
					}
					ng := copyMap(c.gt)
					ng[locus.Code] = pair
					next = append(next, combo{gt: ng, weight: c.weight})
				}
			}
		}
		combos = next
	}

	total := 0
	for _, c := range combos {
		total += c.weight
	}
	// Merge identical genotype keys.
	merged := map[string]*Outcome{}
	for _, c := range combos {
		key := genotypeKey(c.gt)
		if existing, ok := merged[key]; ok {
			existing.CountWeight += c.weight
			continue
		}
		pheno, label := PhenotypeFor(c.gt)
		merged[key] = &Outcome{
			GenotypeKey:    key,
			Genotype:       c.gt,
			PhenotypeLabel: label,
			Phenotype:      pheno,
			CountWeight:    c.weight,
		}
	}
	outcomes := make([]Outcome, 0, len(merged))
	for _, o := range merged {
		o.Probability = float64(o.CountWeight) / float64(total)
		outcomes = append(outcomes, *o)
	}
	sort.Slice(outcomes, func(i, j int) bool {
		if outcomes[i].Probability == outcomes[j].Probability {
			return outcomes[i].GenotypeKey < outcomes[j].GenotypeKey
		}
		return outcomes[i].Probability > outcomes[j].Probability
	})
	return SimulationResult{
		Sire:     sireN,
		Dam:      damN,
		Outcomes: outcomes,
		Notes:    "简化孟德尔模型，仅供教育与配对参考，非完整金丝熊遗传标准。",
	}, nil
}

func genotypeKey(gt map[string]string) string {
	codes := make([]string, 0, len(gt))
	for code := range gt {
		codes = append(codes, code)
	}
	sort.Strings(codes)
	parts := make([]string, 0, len(codes))
	for _, code := range codes {
		parts = append(parts, code+"="+gt[code])
	}
	return strings.Join(parts, ";")
}

func copyMap(in map[string]string) map[string]string {
	out := make(map[string]string, len(in)+1)
	for k, v := range in {
		out[k] = v
	}
	return out
}

// LocusByCode returns a locus or false.
func LocusByCode(code string) (Locus, bool) {
	for _, locus := range DefaultLoci {
		if locus.Code == code {
			return locus, true
		}
	}
	return Locus{}, false
}
