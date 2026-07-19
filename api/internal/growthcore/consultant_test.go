package growthcore

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"
)

func testHamster() PublicHamster {
	return PublicHamster{ID: "h1", PublicName: "奶茶", Summary: "亲人、活动规律", Traits: []string{"亲人", "活动规律"}, Sex: "female", Variety: "金丝熊", BirthDate: "2026-04-18", FilmingStatus: "ready", Published: true, Consultable: true, CTAText: "进入主页咨询"}
}

func TestPublicProjectionAndConsultOnlyUsePublishedProfiles(t *testing.T) {
	visible := testHamster()
	hidden := testHamster()
	hidden.ID = "h2"
	hidden.PublicName = "内部小秘密"
	hidden.Published = false
	answer := Consult("新手适合哪只？", []PublicHamster{visible, hidden})
	if len(answer.Recommendations) != 1 || answer.Recommendations[0].HamsterID != "h1" {
		t.Fatalf("unexpected recommendations: %#v", answer.Recommendations)
	}
	if containsAny(answer.Answer, "内部小秘密") {
		t.Fatal("hidden hamster leaked")
	}
}

func TestTemplateGeneratorKeepsStructuredFacts(t *testing.T) {
	result, err := (TemplateGenerator{}).Generate(context.Background(), GenerationInput{CampaignType: "video", Platform: "wechat_channels", Goal: "成长记录", Tone: "温柔自然", Subject: testHamster()})
	if err != nil {
		t.Fatal(err)
	}
	if result.Script.Title == "" || len(result.Script.Sections) == 0 || len(result.Script.Facts) == 0 || result.FactsSnapshot["subject"] == nil {
		t.Fatalf("incomplete script: %#v", result)
	}
	for _, fact := range result.Script.Facts {
		if fact.Key == "internal_code" || fact.Key == "notes" {
			t.Fatalf("private fact leaked: %#v", fact)
		}
	}
}

func TestLLMInvalidJSONFallsBackToTemplate(t *testing.T) {
	client := &http.Client{Transport: roundTripFunc(func(*http.Request) (*http.Response, error) {
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       io.NopCloser(strings.NewReader(`{"choices":[{"message":{"content":"not json"}}]}`)),
			Header:     make(http.Header),
		}, nil
	})}
	generator := &LLMGenerator{APIKey: "test", BaseURL: "https://example.test/v1", Model: "test-model", HTTP: client, Fallback: TemplateGenerator{}, PromptVersion: "test"}
	result, err := generator.Generate(context.Background(), GenerationInput{CampaignType: "live", Platform: "other", Goal: "介绍", Tone: "自然", Subject: testHamster()})
	if err != nil || result.ModelName != "test-model" || len(result.Script.Sections) == 0 {
		t.Fatalf("fallback failed: result=%#v err=%v", result, err)
	}
}

func TestConsultSuggestsHandoffForPricing(t *testing.T) {
	answer := Consult("这只多少钱？能预订吗？", []PublicHamster{testHamster()})
	if !answer.HandoffSuggested {
		t.Fatal("expected handoff for pricing/reservation")
	}
	if len(answer.Recommendations) == 0 {
		t.Fatal("expected recommendations from published catalog")
	}
}

func TestOpportunityPriorityPrefersReadyFilming(t *testing.T) {
	ready := testHamster()
	rest := testHamster()
	rest.FilmingStatus = "rest"
	rest.Consultable = false
	if BuildOpportunity(ready)["priority"].(int) <= BuildOpportunity(rest)["priority"].(int) {
		t.Fatal("ready filming should rank higher")
	}
}

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }
