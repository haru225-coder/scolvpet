package geneticcore

import (
	"math"
	"reflect"
	"testing"
)

func TestCalibratePhenotypeTableNoHistoryPreservesAuthorityExactly(t *testing.T) {
	base, err := SimulatePhenotypeTable("poly", "蜜波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	got := CalibratePhenotypeTable(
		base,
		PhenotypeCalibrationHistory{},
		PhenotypeCalibrationHistory{},
	)
	if !reflect.DeepEqual(got.Outcomes, base.Outcomes) {
		t.Fatalf("zero history changed authority outcomes\ngot:  %+v\nwant: %+v", got.Outcomes, base.Outcomes)
	}
	if got.PredictionBasis != PredictionBasisAuthorityTable {
		t.Fatalf("basis=%s", got.PredictionBasis)
	}
	if got.HistoryLitterCount != 0 || got.HistoryPupCount != 0 {
		t.Fatalf("history=%d litters/%d pups", got.HistoryLitterCount, got.HistoryPupCount)
	}
}

func TestCalibratePhenotypeTableStrongPriorShrinksSmallSample(t *testing.T) {
	base, err := SimulatePhenotypeTable("poly", "蜜波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	got := CalibratePhenotypeTable(
		base,
		PhenotypeCalibrationHistory{
			LitterCount: 1,
			Counts:      map[string]int{"黑蜜波利": 1},
		},
		PhenotypeCalibrationHistory{},
	)
	by := phenotypeProbabilityMap(got.Outcomes)
	wantHoney := 48.0 / 65.0
	wantBlackHoney := 17.0 / 65.0
	if math.Abs(by["蜜波利"]-wantHoney) > 1e-12 {
		t.Fatalf("蜜波利=%v want %v", by["蜜波利"], wantHoney)
	}
	if math.Abs(by["黑蜜波利"]-wantBlackHoney) > 1e-12 {
		t.Fatalf("黑蜜波利=%v want %v", by["黑蜜波利"], wantBlackHoney)
	}
	if by["蜜波利"] < 0.70 {
		t.Fatalf("one pup should remain strongly shrunk to authority prior: %+v", by)
	}
	if got.PredictionBasis != PredictionBasisAuthorityPlusHistory || got.HistoryPupCount != 1 {
		t.Fatalf("metadata=%+v", got)
	}
}

func TestCalibratePhenotypeTableIgnoresCustomLabels(t *testing.T) {
	base, err := SimulatePhenotypeTable("poly", "蜜波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	got := CalibratePhenotypeTable(
		base,
		PhenotypeCalibrationHistory{
			LitterCount: 3,
			Counts: map[string]int{
				"其他手填": 99,
				"":     10,
			},
		},
		PhenotypeCalibrationHistory{},
	)
	if !reflect.DeepEqual(got.Outcomes, base.Outcomes) {
		t.Fatalf("custom labels changed core prediction: %+v", got.Outcomes)
	}
	if got.PredictionBasis != PredictionBasisAuthorityTable || got.HistoryPupCount != 0 {
		t.Fatalf("metadata=%+v", got)
	}
}

func TestCalibratePhenotypeTableExactParentPairUsesSecondLayerWithoutDoubleCount(t *testing.T) {
	base, err := SimulatePhenotypeTable("poly", "蜜波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	all := PhenotypeCalibrationHistory{
		LitterCount: 3,
		Counts: map[string]int{
			"蜜波利":  10,
			"黑蜜波利": 6,
		},
	}
	exactPair := PhenotypeCalibrationHistory{
		LitterCount: 1,
		Counts: map[string]int{
			"黑蜜波利": 4,
		},
	}
	got := CalibratePhenotypeTable(base, all, exactPair)
	by := phenotypeProbabilityMap(got.Outcomes)

	// Background is 10 honey / 2 black:
	//   stage 1 honey = (64*0.75 + 10) / (64+12) = 58/76
	// Exact pair then uses that population posterior as a 32-pup prior and
	// adds four black pups once.
	wantHoney := (32.0 * (58.0 / 76.0)) / 36.0
	if math.Abs(by["蜜波利"]-wantHoney) > 1e-12 {
		t.Fatalf("蜜波利=%v want %v", by["蜜波利"], wantHoney)
	}
	if got.HistoryLitterCount != 1 || got.HistoryPupCount != 4 {
		t.Fatalf("active exact-pair metadata=%d litters/%d pups", got.HistoryLitterCount, got.HistoryPupCount)
	}
	if math.Abs(by["蜜波利"]+by["黑蜜波利"]-1) > 1e-12 {
		t.Fatalf("sum=%v", by["蜜波利"]+by["黑蜜波利"])
	}
}

func TestCompareActualToPredictionUsesCalibratedProbability(t *testing.T) {
	base, err := SimulatePhenotypeTable("poly", "蜜波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	prediction := CalibratePhenotypeTable(
		base,
		PhenotypeCalibrationHistory{
			LitterCount: 1,
			Counts:      map[string]int{"黑蜜波利": 8},
		},
		PhenotypeCalibrationHistory{},
	)
	got, err := CompareActualToPrediction(prediction, map[string]int{
		"蜜波利":  6,
		"黑蜜波利": 2,
	})
	if err != nil {
		t.Fatal(err)
	}
	if got.PredictionBasis != PredictionBasisAuthorityPlusHistory || got.HistoryPupCount != 8 {
		t.Fatalf("metadata=%+v", got)
	}
	by := map[string]PhenotypeCompareRow{}
	for _, row := range got.Rows {
		by[row.Phenotype] = row
	}
	wantExpectedHoney := 8.0 * (48.0 / 72.0)
	if math.Abs(by["蜜波利"].ExpectedCount-wantExpectedHoney) > 1e-12 {
		t.Fatalf("expected honey=%v want %v", by["蜜波利"].ExpectedCount, wantExpectedHoney)
	}
}

func phenotypeProbabilityMap(outcomes []PhenotypeOutcome) map[string]float64 {
	result := make(map[string]float64, len(outcomes))
	for _, outcome := range outcomes {
		result[outcome.Phenotype] = outcome.Probability
	}
	return result
}
