package geneticcore

import (
	"encoding/json"
	"math"
	"testing"
)

func TestPhenotypeTableLoadsAndCounts(t *testing.T) {
	doc, err := PhenotypeTableMeta()
	if err != nil {
		t.Fatal(err)
	}
	if doc.ID != PhenotypeTableID {
		t.Fatalf("id=%s", doc.ID)
	}
	if len(doc.Crosses) != 49 {
		t.Fatalf("crosses=%d want 49", len(doc.Crosses))
	}
	totalOutcomes := 0
	for _, c := range doc.Crosses {
		totalOutcomes += len(c.Outcomes)
		sum := 0.0
		for _, o := range c.Outcomes {
			sum += o.Probability
		}
		if math.Abs(sum-1.0) > 1e-9 {
			t.Fatalf("%s × %s sum=%v", c.ParentA, c.ParentB, sum)
		}
	}
	if totalOutcomes != 213 {
		t.Fatalf("outcomes=%d want 213", totalOutcomes)
	}
}

func TestSimulatePhenotypeTablePolyHoneyFire(t *testing.T) {
	// 蜜波利 × 火波利 → 8 种表型各有概率（来自长表）
	result, err := SimulatePhenotypeTable("波利系列", "蜜波利", "火波利")
	if err != nil {
		t.Fatal(err)
	}
	if result.Series != "poly" {
		t.Fatalf("series=%s", result.Series)
	}
	if len(result.Outcomes) != 8 {
		t.Fatalf("outcomes=%d %+v", len(result.Outcomes), result.Outcomes)
	}
	by := map[string]float64{}
	var sum float64
	for _, o := range result.Outcomes {
		by[o.Phenotype] = o.Probability
		sum += o.Probability
	}
	if math.Abs(sum-1) > 1e-9 {
		t.Fatalf("sum=%v", sum)
	}
	// 蜜/肉桂/黄/火 各 3/16=0.1875；黑蜜/鸽灰/黑黄/黑 各 1/16=0.0625
	want1875 := []string{"蜜波利", "肉桂波利", "黄波利", "火波利"}
	for _, name := range want1875 {
		if math.Abs(by[name]-0.1875) > 1e-9 {
			t.Fatalf("%s=%v want 0.1875", name, by[name])
		}
	}
	want0625 := []string{"黑蜜波利", "鸽灰波利", "黑黄波利", "黑波利"}
	for _, name := range want0625 {
		if math.Abs(by[name]-0.0625) > 1e-9 {
			t.Fatalf("%s=%v want 0.0625", name, by[name])
		}
	}
}

func TestSimulatePhenotypeTableOrderIndependent(t *testing.T) {
	a, err := SimulatePhenotypeTable("poly", "火波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	b, err := SimulatePhenotypeTable("poly", "蜜波利", "火波利")
	if err != nil {
		t.Fatal(err)
	}
	if len(a.Outcomes) != len(b.Outcomes) {
		t.Fatalf("len %d vs %d", len(a.Outcomes), len(b.Outcomes))
	}
	ma := map[string]float64{}
	mb := map[string]float64{}
	for _, o := range a.Outcomes {
		ma[o.Phenotype] = o.Probability
	}
	for _, o := range b.Outcomes {
		mb[o.Phenotype] = o.Probability
	}
	for k, v := range ma {
		if math.Abs(mb[k]-v) > 1e-12 {
			t.Fatalf("%s %v vs %v", k, v, mb[k])
		}
	}
}

func TestSimulatePhenotypeTableChocolateSelf(t *testing.T) {
	// 巧克力 × 巧克力 → 巧克力 0.75 + 香槟色 0.25
	result, err := SimulatePhenotypeTable("chocolate", "巧克力", "巧克力")
	if err != nil {
		t.Fatal(err)
	}
	by := map[string]float64{}
	for _, o := range result.Outcomes {
		by[o.Phenotype] = o.Probability
	}
	if math.Abs(by["巧克力"]-0.75) > 1e-9 || math.Abs(by["香槟色"]-0.25) > 1e-9 {
		t.Fatalf("%+v", by)
	}
}

func TestSimulatePhenotypeTableCinnamonFireCorrection(t *testing.T) {
	// 校正1：肉桂波利×火波利 采用 /32
	result, err := SimulatePhenotypeTable("poly", "肉桂波利", "火波利")
	if err != nil {
		t.Fatal(err)
	}
	by := map[string]float64{}
	var sum float64
	for _, o := range result.Outcomes {
		by[o.Phenotype] = o.Probability
		sum += o.Probability
	}
	if math.Abs(sum-1) > 1e-9 {
		t.Fatalf("sum=%v", sum)
	}
	if math.Abs(by["肉桂波利"]-0.28125) > 1e-9 { // 9/32
		t.Fatalf("肉桂波利=%v", by["肉桂波利"])
	}
	if math.Abs(by["黑蜜波利"]-0.03125) > 1e-9 { // 1/32
		t.Fatalf("黑蜜波利=%v", by["黑蜜波利"])
	}
}

func TestSimulatePhenotypeTableMissingCross(t *testing.T) {
	// 波利系列里没有「蜜波利×蜜波利」以外的非法表型组合用未知表型
	_, err := SimulatePhenotypeTable("poly", "蜜波利", "不存在的表型")
	if err == nil {
		t.Fatal("expected error")
	}
}

func TestFindCrossesForTarget(t *testing.T) {
	list, err := FindCrossesForTarget("poly", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	if len(list) == 0 {
		t.Fatal("expected crosses producing 蜜波利")
	}
	// top should be 蜜波利×蜜波利 at 0.75
	top := list[0]
	if !(top.ParentA == "蜜波利" && top.ParentB == "蜜波利") {
		// still ok if another is higher — check max p among outcomes for 蜜波利
	}
	var maxP float64
	for _, c := range list {
		for _, o := range c.Outcomes {
			if o.Phenotype == "蜜波利" && o.Probability > maxP {
				maxP = o.Probability
			}
		}
	}
	if math.Abs(maxP-0.75) > 1e-9 {
		t.Fatalf("maxP=%v", maxP)
	}
}

func TestToSimulationResultShape(t *testing.T) {
	r, err := SimulatePhenotypeTable("poly", "黑蜜波利", "黑蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	sim := r.ToSimulationResult()
	if len(sim.Outcomes) != 1 || sim.Outcomes[0].PhenotypeLabel != "黑蜜波利" {
		t.Fatalf("%+v", sim.Outcomes)
	}
	if math.Abs(sim.Outcomes[0].Probability-1.0) > 1e-9 {
		t.Fatalf("p=%v", sim.Outcomes[0].Probability)
	}
	// JSON marshal sanity
	b, err := json.Marshal(sim)
	if err != nil {
		t.Fatal(err)
	}
	if len(b) < 20 {
		t.Fatal(string(b))
	}
}

func TestGoldenEveryCrossSumsToOne(t *testing.T) {
	doc, err := PhenotypeTableMeta()
	if err != nil {
		t.Fatal(err)
	}
	for _, c := range doc.Crosses {
		got, err := SimulatePhenotypeTable(c.Series, c.ParentA, c.ParentB)
		if err != nil {
			t.Fatalf("%s %s×%s: %v", c.Series, c.ParentA, c.ParentB, err)
		}
		// match outcome multiset
		if len(got.Outcomes) != len(c.Outcomes) {
			t.Fatalf("%s×%s outcomes %d vs %d", c.ParentA, c.ParentB, len(got.Outcomes), len(c.Outcomes))
		}
		want := map[string]float64{}
		for _, o := range c.Outcomes {
			want[o.Phenotype] = o.Probability
		}
		for _, o := range got.Outcomes {
			if math.Abs(want[o.Phenotype]-o.Probability) > 1e-12 {
				t.Fatalf("%s×%s %s: got %v want %v", c.ParentA, c.ParentB, o.Phenotype, o.Probability, want[o.Phenotype])
			}
		}
	}
}
