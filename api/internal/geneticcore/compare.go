package geneticcore

import (
	"fmt"
	"math"
	"sort"
	"strings"
)

// ActualPhenotypeCount is one observed phenotype bucket from a litter.
type ActualPhenotypeCount struct {
	Phenotype string `json:"phenotype"`
	Count     int    `json:"count"`
}

// PhenotypeCompareRow is expected vs actual for one phenotype.
type PhenotypeCompareRow struct {
	Phenotype     string  `json:"phenotype"`
	PredictedP    float64 `json:"predicted_probability"`
	PredictedFrac string  `json:"predicted_fraction,omitempty"`
	ExpectedCount float64 `json:"expected_count"`
	ActualCount   int     `json:"actual_count"`
	Residual      float64 `json:"residual"` // actual - expected
	AbsResidual   float64 `json:"abs_residual"`
}

// PhenotypeCompareResult summarizes prediction vs litter reality.
type PhenotypeCompareResult struct {
	Series             string                `json:"series"`
	SeriesName         string                `json:"series_name"`
	SirePhenotype      string                `json:"sire_phenotype"`
	DamPhenotype       string                `json:"dam_phenotype"`
	TableID            string                `json:"table_id"`
	TableVersion       string                `json:"table_version"`
	PredictionBasis    string                `json:"prediction_basis"`
	HistoryLitterCount int                   `json:"history_litter_count"`
	HistoryPupCount    int                   `json:"history_pup_count"`
	TotalActual        int                   `json:"total_actual"`
	Rows               []PhenotypeCompareRow `json:"rows"`
	MeanAbsError       float64               `json:"mean_abs_error"`
	TotalVariation     float64               `json:"total_variation"` // 0.5 * sum |p_hat - p_obs|
	Notes              string                `json:"notes"`
}

// CompareActualToTable re-runs the authority table prediction and compares to actual counts.
// actualCounts keys are phenotype labels; zero/missing phenotypes still appear if predicted > 0.
func CompareActualToTable(seriesRaw, sire, dam string, actualCounts map[string]int) (PhenotypeCompareResult, error) {
	pred, err := SimulatePhenotypeTable(seriesRaw, sire, dam)
	if err != nil {
		return PhenotypeCompareResult{}, err
	}
	return CompareActualToPrediction(pred, actualCounts)
}

// CompareActualToPrediction compares a litter with the supplied prediction.
// The prediction may be the static authority table or an owner-history
// calibrated posterior; callers decide which evidence is available before the
// current litter is persisted.
func CompareActualToPrediction(pred PhenotypeTableResult, actualCounts map[string]int) (PhenotypeCompareResult, error) {
	total := 0
	for ph, n := range actualCounts {
		if strings.TrimSpace(ph) == "" {
			continue
		}
		if n < 0 {
			return PhenotypeCompareResult{}, fmt.Errorf("表型 %q 数量不能为负", ph)
		}
		total += n
	}
	if total == 0 {
		return PhenotypeCompareResult{}, fmt.Errorf("实际只数合计须大于 0")
	}

	// Union of predicted + actual phenotype labels.
	labels := map[string]struct{}{}
	predBy := map[string]PhenotypeOutcome{}
	for _, o := range pred.Outcomes {
		labels[o.Phenotype] = struct{}{}
		predBy[o.Phenotype] = o
	}
	for ph := range actualCounts {
		ph = strings.TrimSpace(ph)
		if ph != "" {
			labels[ph] = struct{}{}
		}
	}

	rows := make([]PhenotypeCompareRow, 0, len(labels))
	var sumAbs float64
	var tv float64 // total variation on proportions
	for ph := range labels {
		o := predBy[ph]
		p := o.Probability
		actual := actualCounts[ph]
		expected := p * float64(total)
		res := float64(actual) - expected
		obsP := float64(actual) / float64(total)
		tv += math.Abs(obsP - p)
		sumAbs += math.Abs(res)
		rows = append(rows, PhenotypeCompareRow{
			Phenotype:     ph,
			PredictedP:    p,
			PredictedFrac: o.Fraction,
			ExpectedCount: expected,
			ActualCount:   actual,
			Residual:      res,
			AbsResidual:   math.Abs(res),
		})
	}
	sort.Slice(rows, func(i, j int) bool {
		// largest abs residual first, then by predicted p
		if rows[i].AbsResidual != rows[j].AbsResidual {
			return rows[i].AbsResidual > rows[j].AbsResidual
		}
		if rows[i].PredictedP != rows[j].PredictedP {
			return rows[i].PredictedP > rows[j].PredictedP
		}
		return rows[i].Phenotype < rows[j].Phenotype
	})

	mae := sumAbs / float64(len(rows))
	notes := "对比基于核心表理论概率与本窝实际计数；小样本偏差属正常，不表示核心表错误。"
	if pred.PredictionBasis == PredictionBasisAuthorityPlusHistory {
		notes = "对比基于核心表与此前历史窝次校准概率；当前窝尚未进入本次预测。"
	}

	return PhenotypeCompareResult{
		Series:             pred.Series,
		SeriesName:         pred.SeriesName,
		SirePhenotype:      pred.Sire,
		DamPhenotype:       pred.Dam,
		TableID:            pred.TableID,
		TableVersion:       pred.Version,
		PredictionBasis:    pred.PredictionBasis,
		HistoryLitterCount: pred.HistoryLitterCount,
		HistoryPupCount:    pred.HistoryPupCount,
		TotalActual:        total,
		Rows:               rows,
		MeanAbsError:       mae,
		TotalVariation:     0.5 * tv,
		Notes:              notes,
	}, nil
}
