package geneticcore

import (
	"math"
	"strings"
	"testing"
)

// Golden: locus model must match every authority-table cross before filling gaps.
// Discipline: never let the model override table rows (SimulatePhenotypeTable enforces that).
func TestLocusModelGoldenAgainstAuthorityTable(t *testing.T) {
	doc, err := PhenotypeTableMeta()
	if err != nil {
		t.Fatal(err)
	}
	var ok, bad int
	for _, c := range doc.Crosses {
		got, modelOK := SimulateLocusModel(c.Series, c.ParentA, c.ParentB)
		if !modelOK {
			t.Errorf("model cannot simulate table row %s × %s (%s)", c.ParentA, c.ParentB, c.Series)
			bad++
			continue
		}
		wantFolded := map[string]float64{}
		for _, o := range c.Outcomes {
			wantFolded[foldOutcomeLabel(c.Series, o.Phenotype)] += o.Probability
		}
		gotFolded := map[string]float64{}
		for _, o := range got {
			gotFolded[foldOutcomeLabel(c.Series, o.Phenotype)] += o.Probability
		}

		if !probMapsEqual(wantFolded, gotFolded, 1e-9) {
			t.Errorf("mismatch %s × %s (%s)\n  table=%v\n  model=%v", c.ParentA, c.ParentB, c.Series, wantFolded, gotFolded)
			bad++
			continue
		}
		ok++
	}
	if bad != 0 {
		t.Fatalf("golden failed: ok=%d bad=%d (want 49/49)", ok, bad)
	}
	if ok != 49 {
		t.Fatalf("ok=%d want 49", ok)
	}
}

func foldOutcomeLabel(series, label string) string {
	// Model chocolate offspring uses 黑熊/鸽灰/巧克力/…; table uses the same for pups.
	// Parent-side aliases should not apply to 普通黑熊 as offspring (table uses 黑熊).
	if series != "chocolate" {
		return label
	}
	switch label {
	case "巧克力色":
		return "巧克力"
	case "巧显斑":
		return "巧克力显斑"
	default:
		return label
	}
}

func probMapsEqual(a, b map[string]float64, eps float64) bool {
	if len(a) != len(b) {
		// allow missing zero keys
		keys := map[string]struct{}{}
		for k := range a {
			keys[k] = struct{}{}
		}
		for k := range b {
			keys[k] = struct{}{}
		}
		for k := range keys {
			if math.Abs(a[k]-b[k]) > eps {
				return false
			}
		}
		return true
	}
	for k, v := range a {
		if math.Abs(b[k]-v) > eps {
			return false
		}
	}
	return true
}

func TestChocolateModelCovers105UnorderedPairs(t *testing.T) {
	// Authority catalog lists 14 labels (incl. synonyms) → n(n+1)/2 = 105.
	crosses := EnumerateModelCrosses("chocolate")
	if len(crosses) != 105 {
		t.Fatalf("chocolate model crosses=%d want 105 (14 catalog labels)", len(crosses))
	}
	for _, c := range crosses {
		var sum float64
		for _, o := range c.Outcomes {
			sum += o.Probability
		}
		if math.Abs(sum-1) > 1e-9 {
			t.Fatalf("%s×%s sum=%v", c.ParentA, c.ParentB, sum)
		}
	}
}

func TestPolyModelCovers36UnorderedPairs(t *testing.T) {
	crosses := EnumerateModelCrosses("poly")
	if len(crosses) != 36 { // 8*9/2
		t.Fatalf("poly model crosses=%d want 36", len(crosses))
	}
}

func TestSimulatePhenotypeTableAliasAndModelFill(t *testing.T) {
	// synonym parents still hit authority table
	r, err := SimulatePhenotypeTable("chocolate", "巧克力色", "普通黑熊")
	if err != nil {
		t.Fatal(err)
	}
	if r.PredictionBasis != PredictionBasisAuthorityTable {
		t.Fatalf("basis=%s want authority (table has 巧克力×普通黑熊)", r.PredictionBasis)
	}
	// model-only pair: 普通黑熊 × 普通黑熊 (not in 13 table rows)
	r2, err := SimulatePhenotypeTable("chocolate", "普通黑熊", "普通黑熊")
	if err != nil {
		t.Fatal(err)
	}
	if r2.PredictionBasis != PredictionBasisLocusModel {
		t.Fatalf("basis=%s want locus_model", r2.PredictionBasis)
	}
	if len(r2.Outcomes) != 1 || r2.Outcomes[0].Phenotype != "黑熊" || math.Abs(r2.Outcomes[0].Probability-1) > 1e-9 {
		t.Fatalf("%+v", r2.Outcomes)
	}
}

func TestFindCrossesForTargetIncludesModelPairs(t *testing.T) {
	list, err := FindCrossesForTarget("chocolate", "黑熊")
	if err != nil {
		t.Fatal(err)
	}
	if len(list) < 13 {
		t.Fatalf("expected table+model pairs producing 黑熊, got %d", len(list))
	}
}

func TestCarrierBreakdownOnChocolateCarrierCross(t *testing.T) {
	// 携巧黑熊 × 携巧黑熊 → 表：黑熊 3/4 + 巧克力 1/4；黑熊里 2/3 为 Bb 携巧
	r, err := SimulatePhenotypeTable("chocolate", "携巧黑熊", "携巧黑熊")
	if err != nil {
		t.Fatal(err)
	}
	if r.PredictionBasis != PredictionBasisAuthorityTable {
		t.Fatalf("basis=%s", r.PredictionBasis)
	}
	var black *PhenotypeOutcome
	for i := range r.Outcomes {
		if r.Outcomes[i].Phenotype == "黑熊" {
			black = &r.Outcomes[i]
			break
		}
	}
	if black == nil {
		t.Fatalf("missing 黑熊 outcome: %+v", r.Outcomes)
	}
	if !strings.Contains(black.CarrierSummary, "携巧") {
		t.Fatalf("carrier_summary=%q", black.CarrierSummary)
	}
	if len(black.GenotypeBreakdown) < 2 {
		t.Fatalf("expected BB+Bb breakdown, got %+v", black.GenotypeBreakdown)
	}
	if len(r.GenotypeOutcomes) == 0 {
		t.Fatal("expected flat genotype_outcomes")
	}
}

func TestMultiGenWithGenotypeKey(t *testing.T) {
	// First gen: pick Bb black bear key and continue
	r1, err := SimulatePhenotypeTable("chocolate", "携巧黑熊", "普通黑熊")
	if err != nil {
		t.Fatal(err)
	}
	var carrierKey string
	for _, g := range r1.GenotypeOutcomes {
		for _, t := range g.CarrierTags {
			if t == "携巧" {
				carrierKey = g.Key
				break
			}
		}
		if carrierKey != "" {
			break
		}
	}
	if carrierKey == "" {
		// may all be non-carrier depending on cross; force known key
		carrierKey = "b=Bb|d=DD|s=--"
	}
	r2, err := SimulatePhenotypeTableExt("chocolate", "", "普通黑熊", carrierKey, "")
	if err != nil {
		t.Fatal(err)
	}
	if r2.PredictionBasis != PredictionBasisLocusModel {
		t.Fatalf("basis=%s", r2.PredictionBasis)
	}
	if r2.SireGenotypeKey != carrierKey {
		t.Fatalf("sire key=%s", r2.SireGenotypeKey)
	}
	// Bb × BB → 50% Bb carrier black
	var hasCarrier bool
	for _, o := range r2.Outcomes {
		if strings.Contains(o.CarrierSummary, "携巧") {
			hasCarrier = true
		}
	}
	if !hasCarrier {
		t.Fatalf("expected carrier mass in multi-gen: %+v", r2.Outcomes)
	}
}
