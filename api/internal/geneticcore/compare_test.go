package geneticcore

import (
	"math"
	"testing"
)

func TestCompareActualToTableHoneySelf(t *testing.T) {
	// 蜜×蜜 → 75% 蜜 / 25% 黑蜜；窝产 8 只若 6 蜜 2 黑蜜，与期望完全一致
	got, err := CompareActualToTable("poly", "蜜波利", "蜜波利", map[string]int{
		"蜜波利":  6,
		"黑蜜波利": 2,
	})
	if err != nil {
		t.Fatal(err)
	}
	if got.TotalActual != 8 {
		t.Fatalf("total=%d", got.TotalActual)
	}
	by := map[string]PhenotypeCompareRow{}
	for _, r := range got.Rows {
		by[r.Phenotype] = r
	}
	if math.Abs(by["蜜波利"].ExpectedCount-6) > 1e-9 {
		t.Fatalf("expected 蜜=%v", by["蜜波利"].ExpectedCount)
	}
	if math.Abs(by["蜜波利"].Residual) > 1e-9 {
		t.Fatalf("residual 蜜=%v", by["蜜波利"].Residual)
	}
	if math.Abs(got.TotalVariation) > 1e-9 {
		t.Fatalf("tv=%v want 0", got.TotalVariation)
	}
}

func TestCompareActualToTableWithSurprisePhenotype(t *testing.T) {
	// 黑蜜×黑蜜 只预测黑蜜 100%；若出现其他表型 residual 拉大
	got, err := CompareActualToTable("poly", "黑蜜波利", "黑蜜波利", map[string]int{
		"黑蜜波利": 3,
		"蜜波利":  1, // 表上期望 0
	})
	if err != nil {
		t.Fatal(err)
	}
	var surprise PhenotypeCompareRow
	for _, r := range got.Rows {
		if r.Phenotype == "蜜波利" {
			surprise = r
		}
	}
	if surprise.PredictedP != 0 || surprise.ActualCount != 1 {
		t.Fatalf("%+v", surprise)
	}
	if surprise.Residual != 1 {
		t.Fatalf("residual=%v", surprise.Residual)
	}
}

func TestCompareActualToTableRejectsEmpty(t *testing.T) {
	_, err := CompareActualToTable("poly", "蜜波利", "蜜波利", map[string]int{})
	if err == nil {
		t.Fatal("expected error")
	}
}
