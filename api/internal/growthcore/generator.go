package growthcore

import "context"

type GenerationInput struct {
	CampaignType    string        `json:"campaign_type"`
	Platform        string        `json:"platform"`
	Goal            string        `json:"goal"`
	DurationSeconds *int          `json:"duration_seconds,omitempty"`
	Tone            string        `json:"tone"`
	CTA             string        `json:"cta"`
	Subject         PublicHamster `json:"subject"`
}

type ScriptSection struct {
	Order           int    `json:"order"`
	DurationSeconds int    `json:"duration_seconds"`
	Shot            string `json:"shot"`
	Voiceover       string `json:"voiceover"`
	Overlay         string `json:"overlay"`
}

type ScriptPayload struct {
	Title     string          `json:"title"`
	Hook      string          `json:"hook"`
	CoverText string          `json:"cover_text"`
	Sections  []ScriptSection `json:"sections"`
	Caption   string          `json:"caption"`
	Hashtags  []string        `json:"hashtags"`
	CTA       string          `json:"cta"`
	Facts     []PublicFact    `json:"facts"`
}

type GenerationResult struct {
	Script        ScriptPayload  `json:"script"`
	FactsSnapshot map[string]any `json:"facts_snapshot"`
	ModelName     string         `json:"model_name"`
	PromptVersion string         `json:"prompt_version"`
}

type Generator interface {
	Generate(context.Context, GenerationInput) (GenerationResult, error)
}
