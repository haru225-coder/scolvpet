package geneticcore

import (
	"math"
	"testing"
)

func TestNormalizeAllelePair(t *testing.T) {
	locus := DefaultLoci[0] // A
	got, err := NormalizeAllelePair(locus, "a/A")
	if err != nil {
		t.Fatal(err)
	}
	if got != "A/a" {
		t.Fatalf("got %s", got)
	}
	if _, err := NormalizeAllelePair(locus, "X/Y"); err == nil {
		t.Fatal("expected error")
	}
}

func TestSimulateHeterozygousAgouti(t *testing.T) {
	// A/a × A/a → 1 AA : 2 Aa : 1 aa
	result, err := Simulate(
		Genotype{"A": "A/a"},
		Genotype{"A": "A/a"},
	)
	if err != nil {
		t.Fatal(err)
	}
	if len(result.Outcomes) != 3 {
		t.Fatalf("outcomes=%d %+v", len(result.Outcomes), result.Outcomes)
	}
	// Probabilities
	byKey := map[string]float64{}
	for _, o := range result.Outcomes {
		byKey[o.Genotype["A"]] = o.Probability
	}
	if math.Abs(byKey["A/A"]-0.25) > 1e-9 {
		t.Fatalf("A/A prob=%v", byKey["A/A"])
	}
	if math.Abs(byKey["A/a"]-0.5) > 1e-9 {
		t.Fatalf("A/a prob=%v", byKey["A/a"])
	}
	if math.Abs(byKey["a/a"]-0.25) > 1e-9 {
		t.Fatalf("a/a prob=%v", byKey["a/a"])
	}
}

func TestPhenotypeForRecessive(t *testing.T) {
	_, label := PhenotypeFor(Genotype{"A": "a/a", "B": "B/B", "C": "C/c"})
	if label == "" || label == "未知表型" {
		t.Fatalf("label=%s", label)
	}
	// a/a → 黑
	pheno, _ := PhenotypeFor(Genotype{"A": "a/a"})
	if pheno["A"] != "黑" {
		t.Fatalf("pheno=%v", pheno)
	}
}

func TestSimulateTwoLocusIndependence(t *testing.T) {
	// A/a B/b × A/a B/b → 16 cells, 9 genotype classes for complete dominance phenotypes less
	result, err := Simulate(
		Genotype{"A": "A/a", "B": "B/b"},
		Genotype{"A": "A/a", "B": "B/b"},
	)
	if err != nil {
		t.Fatal(err)
	}
	var sum float64
	for _, o := range result.Outcomes {
		sum += o.Probability
	}
	if math.Abs(sum-1.0) > 1e-9 {
		t.Fatalf("sum=%v outcomes=%d", sum, len(result.Outcomes))
	}
	if len(result.Outcomes) != 9 {
		// 3x3 genotype combos
		t.Fatalf("want 9 genotype classes, got %d", len(result.Outcomes))
	}
}
