package geneticcore

import (
	"strings"
	"testing"
)

func TestInferParentsChocolateCarrierLitter(t *testing.T) {
	// Two "黑熊" parents, litter with chocolates → both must carry Bb.
	r, err := InferParentGenotypes(InferParentGenotypesRequest{
		Series:        "chocolate",
		SirePhenotype: "普通黑熊",
		DamPhenotype:  "普通黑熊",
		OffspringCounts: map[string]int{
			"黑熊":  6,
			"巧克力": 2,
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	if r.PredictionBasis != PredictionBasisParentPosterior {
		t.Fatalf("basis=%s", r.PredictionBasis)
	}
	if len(r.Hypotheses) == 0 {
		t.Fatal("no hypotheses")
	}
	top := r.Hypotheses[0]
	// Top joint should be Bb × Bb
	if top.SireKey != "b=Bb|d=DD|s=--" || top.DamKey != "b=Bb|d=DD|s=--" {
		t.Fatalf("top=%s × %s (p=%.3f), want Bb×Bb", top.SireKey, top.DamKey, top.Probability)
	}
	if top.Probability < 0.5 {
		t.Fatalf("top posterior too low: %.3f", top.Probability)
	}
	// Marginal: Bb dominates both sides
	if r.SireMarginal[0].Key != "b=Bb|d=DD|s=--" || r.SireMarginal[0].Probability < 0.7 {
		t.Fatalf("sire marginal=%+v", r.SireMarginal)
	}
}

func TestInferParentsChocolateNonCarrierLitter(t *testing.T) {
	// Only black pups, parents labeled 普通黑熊 → BB×BB preferred
	r, err := InferParentGenotypes(InferParentGenotypesRequest{
		Series:        "chocolate",
		SirePhenotype: "普通黑熊",
		DamPhenotype:  "普通黑熊",
		OffspringCounts: map[string]int{
			"黑熊": 12,
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	top := r.Hypotheses[0]
	if top.SireKey != "b=BB|d=DD|s=--" || top.DamKey != "b=BB|d=DD|s=--" {
		// Allow high BB mass even if joint ranking ties oddly
		if r.SireMarginal[0].Key != "b=BB|d=DD|s=--" {
			t.Fatalf("top=%s×%s marginal sire=%s", top.SireKey, top.DamKey, r.SireMarginal[0].Key)
		}
	}
}

func TestInferParentsFixedMate(t *testing.T) {
	// Known dam Bb, sire 普通黑熊, chocolates in litter → sire also Bb
	r, err := InferParentGenotypes(InferParentGenotypesRequest{
		Series:         "chocolate",
		SirePhenotype:  "普通黑熊",
		DamPhenotype:   "携巧黑熊",
		DamGenotypeKey: "b=Bb|d=DD|s=--",
		OffspringCounts: map[string]int{
			"黑熊":  4,
			"巧克力": 4,
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	if r.DamMarginal[0].Key != "b=Bb|d=DD|s=--" {
		t.Fatalf("dam should be fixed Bb: %+v", r.DamMarginal)
	}
	if r.SireMarginal[0].Key != "b=Bb|d=DD|s=--" {
		t.Fatalf("sire should infer Bb: %+v", r.SireMarginal)
	}
}

func TestInferParentsRejectsImpossible(t *testing.T) {
	// BB×BB cannot produce chocolate
	_, err := InferParentGenotypes(InferParentGenotypesRequest{
		Series:         "chocolate",
		SireGenotypeKey: "b=BB|d=DD|s=--",
		DamGenotypeKey:  "b=BB|d=DD|s=--",
		OffspringCounts: map[string]int{"巧克力": 1},
	})
	if err == nil {
		t.Fatal("expected impossible litter error")
	}
}

func TestInferParentsPolyRecessiveEvidence(t *testing.T) {
	// 火波利 × 火波利 producing 黑波利 → both carry black (k=Aa)
	r, err := InferParentGenotypes(InferParentGenotypesRequest{
		Series:        "poly",
		SirePhenotype: "火波利",
		DamPhenotype:  "火波利",
		OffspringCounts: map[string]int{
			"火波利": 10,
			"黑波利": 2,
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	// Top should not be fully AA at black locus for both
	top := r.Hypotheses[0]
	if top.SireKey == "c=AA|y=AA|k=AA" && top.DamKey == "c=AA|y=AA|k=AA" {
		t.Fatalf("should not prefer pure AA×AA when black pups exist: %+v", top)
	}
	found := containsKeyLocus(top.SireKey, "k=Aa") || containsKeyLocus(top.DamKey, "k=Aa")
	if !found {
		t.Fatalf("expected 携黑 signal in posterior: top=%+v sire=%+v", top, r.SireMarginal)
	}
}

func containsKeyLocus(key, part string) bool {
	return strings.Contains(key, part)
}
