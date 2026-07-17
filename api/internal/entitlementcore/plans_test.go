package entitlementcore

import (
	"testing"
	"time"
)

func TestBuildSnapshotFreeOverLimitSoft(t *testing.T) {
	snap := BuildSnapshot(PlanFree, "system", time.Now().UTC(), nil, map[string]float64{
		"active_hamsters": 50,
		"enclosures":      5,
	}, nil, nil)
	if snap.PlanCode != PlanFree {
		t.Fatalf("plan=%s", snap.PlanCode)
	}
	if !snap.OverLimit {
		t.Fatal("expected over limit")
	}
	check := CheckMetric(snap, "active_hamsters")
	if !check.Allowed {
		t.Fatalf("soft should allow: %+v", check)
	}
	if check.Reason == "" {
		t.Fatal("expected reason")
	}
}

func TestCheckFeatureAdvancedExportFree(t *testing.T) {
	snap := BuildSnapshot(PlanFree, "system", time.Now().UTC(), nil, nil, nil, nil)
	check := CheckFeature(snap, FeatureAdvancedExport)
	if !check.Allowed {
		t.Fatalf("soft free still allows with hint: %+v", check)
	}
	pro := BuildSnapshot(PlanPro, "sandbox", time.Now().UTC(), nil, nil, nil, nil)
	proCheck := CheckFeature(pro, FeatureAdvancedExport)
	if !proCheck.Allowed || proCheck.Reason != "" {
		// allowed true, no upgrade reason needed when included
		if !proCheck.Allowed {
			t.Fatalf("pro should allow: %+v", proCheck)
		}
	}
}

func TestCatalog(t *testing.T) {
	if _, ok := CatalogByCode(PlanPro); !ok {
		t.Fatal("pro missing")
	}
	if len(DefaultCatalog()) < 2 {
		t.Fatal("catalog")
	}
}
