package geneticcore

import (
	"sort"
	"strings"
)

const (
	// PhenotypeAuthorityPriorPups keeps small owner datasets close to the
	// authority table. It is equivalent to observing 64 pups distributed by
	// the table probabilities before owner feedback is added.
	PhenotypeAuthorityPriorPups = 64.0

	// phenotypeParentPairPriorPups lets an exact hamster pair adapt faster than
	// the broader phenotype-pair population while still retaining a substantial
	// authority/population prior.
	phenotypeParentPairPriorPups = 32.0

	PredictionBasisAuthorityTable       = "authority_table"
	PredictionBasisAuthorityPlusHistory = "authority_table_plus_history"
)

// PhenotypeCalibrationHistory is aggregated, deduplicated litter feedback.
// Counts outside the authority-table outcomes are deliberately ignored by the
// calibration functions, so custom labels never become predicted core classes.
type PhenotypeCalibrationHistory struct {
	LitterCount int
	Counts      map[string]int
}

// CalibratePhenotypeTable applies a robust hierarchical Dirichlet posterior.
//
// First, the authority table is the prior for phenotype-pair history. When an
// exact hamster-pair history is present, that pair is removed from the broader
// history and applied as a second, more responsive posterior layer. This avoids
// counting the same litter twice.
func CalibratePhenotypeTable(
	base PhenotypeTableResult,
	phenotypeHistory PhenotypeCalibrationHistory,
	parentPairHistory PhenotypeCalibrationHistory,
) PhenotypeTableResult {
	result := base
	result.Outcomes = clonePhenotypeOutcomes(base.Outcomes)
	result.PredictionBasis = PredictionBasisAuthorityTable
	result.HistoryLitterCount = 0
	result.HistoryPupCount = 0

	background := phenotypeHistory
	if eligibleHistoryPupCount(base.Outcomes, parentPairHistory.Counts) > 0 {
		background = subtractPhenotypeHistory(phenotypeHistory, parentPairHistory)
	}

	var usedPups int
	result.Outcomes, usedPups = calibratePhenotypeOutcomes(
		result.Outcomes,
		background.Counts,
		PhenotypeAuthorityPriorPups,
	)
	if usedPups > 0 {
		result.PredictionBasis = PredictionBasisAuthorityPlusHistory
		result.HistoryLitterCount = nonNegative(background.LitterCount)
		result.HistoryPupCount = usedPups
	}

	pairPups := eligibleHistoryPupCount(result.Outcomes, parentPairHistory.Counts)
	if pairPups > 0 {
		result.Outcomes, pairPups = calibratePhenotypeOutcomes(
			result.Outcomes,
			parentPairHistory.Counts,
			phenotypeParentPairPriorPups,
		)
		result.PredictionBasis = PredictionBasisAuthorityPlusHistory
		result.HistoryLitterCount = nonNegative(parentPairHistory.LitterCount)
		result.HistoryPupCount = pairPups
	}

	// Phenotype margins may have moved; keep genotype splits proportional and refresh flat list.
	rescaleGenotypeBreakdowns(result.Outcomes)
	result.GenotypeOutcomes = flattenGenotypeOutcomes(result.Outcomes)
	return result
}

// CalibratePhenotypeCross applies phenotype-level history to a target-search
// cross without requiring an API-facing PhenotypeTableResult.
func CalibratePhenotypeCross(
	cross PhenotypeCross,
	history PhenotypeCalibrationHistory,
) (PhenotypeCross, string, int, int) {
	result := cross
	result.Outcomes = clonePhenotypeOutcomes(cross.Outcomes)
	calibrated, pupCount := calibratePhenotypeOutcomes(
		result.Outcomes,
		history.Counts,
		PhenotypeAuthorityPriorPups,
	)
	if pupCount == 0 {
		return result, PredictionBasisAuthorityTable, 0, 0
	}
	result.Outcomes = calibrated
	return result, PredictionBasisAuthorityPlusHistory, nonNegative(history.LitterCount), pupCount
}

func calibratePhenotypeOutcomes(
	prior []PhenotypeOutcome,
	counts map[string]int,
	priorEquivalentPups float64,
) ([]PhenotypeOutcome, int) {
	out := clonePhenotypeOutcomes(prior)
	if len(out) == 0 || priorEquivalentPups <= 0 {
		return out, 0
	}

	priorSum := 0.0
	allowed := make(map[string]struct{}, len(out))
	for _, outcome := range out {
		if outcome.Probability > 0 {
			priorSum += outcome.Probability
		}
		allowed[outcome.Phenotype] = struct{}{}
	}
	if priorSum <= 0 {
		return out, 0
	}

	eligible := make(map[string]int, len(counts))
	total := 0
	for rawLabel, count := range counts {
		label := strings.TrimSpace(rawLabel)
		if count <= 0 {
			continue
		}
		if _, ok := allowed[label]; !ok {
			continue
		}
		eligible[label] += count
		total += count
	}
	if total == 0 {
		// Preserve exact table probabilities, ordering, and fractions when no
		// usable history exists.
		return out, 0
	}

	denominator := priorEquivalentPups + float64(total)
	for i := range out {
		priorProbability := out[i].Probability / priorSum
		out[i].Probability = (priorEquivalentPups*priorProbability + float64(eligible[out[i].Phenotype])) / denominator
		// The authority fraction describes the static table, not the posterior.
		out[i].Fraction = ""
	}
	sort.SliceStable(out, func(i, j int) bool {
		if out[i].Probability == out[j].Probability {
			return out[i].Phenotype < out[j].Phenotype
		}
		return out[i].Probability > out[j].Probability
	})
	return out, total
}

func eligibleHistoryPupCount(outcomes []PhenotypeOutcome, counts map[string]int) int {
	allowed := make(map[string]struct{}, len(outcomes))
	for _, outcome := range outcomes {
		allowed[outcome.Phenotype] = struct{}{}
	}
	total := 0
	for rawLabel, count := range counts {
		if count <= 0 {
			continue
		}
		if _, ok := allowed[strings.TrimSpace(rawLabel)]; ok {
			total += count
		}
	}
	return total
}

func subtractPhenotypeHistory(all, subset PhenotypeCalibrationHistory) PhenotypeCalibrationHistory {
	result := PhenotypeCalibrationHistory{
		LitterCount: nonNegative(all.LitterCount - subset.LitterCount),
		Counts:      make(map[string]int, len(all.Counts)),
	}
	for label, count := range all.Counts {
		remaining := count - subset.Counts[label]
		if remaining > 0 {
			result.Counts[label] = remaining
		}
	}
	return result
}

func clonePhenotypeOutcomes(in []PhenotypeOutcome) []PhenotypeOutcome {
	out := make([]PhenotypeOutcome, len(in))
	copy(out, in)
	for i := range out {
		if len(in[i].GenotypeBreakdown) > 0 {
			out[i].GenotypeBreakdown = append([]GenotypeSlice(nil), in[i].GenotypeBreakdown...)
		}
	}
	return out
}

func nonNegative(value int) int {
	if value < 0 {
		return 0
	}
	return value
}
