package growthcore

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type LLMGenerator struct {
	APIKey        string
	BaseURL       string
	Model         string
	HTTP          *http.Client
	Fallback      TemplateGenerator
	PromptVersion string
}

// NewGeneratorFromEnv builds the content generator.
// LLM goes through self-hosted Grok2API (OpenAI-compatible), not the public api.x.ai console.
// Env: AI_* preferred, XAI_* fallback for older deploys.
func NewGeneratorFromEnv() Generator {
	key := firstEnv("AI_API_KEY", "XAI_API_KEY")
	if key == "" {
		return TemplateGenerator{}
	}
	base := firstEnv("AI_BASE_URL", "XAI_BASE_URL")
	if base == "" {
		base = "https://hadeworks.com/v1"
	}
	model := firstEnv("AI_MODEL", "XAI_MODEL")
	if model == "" {
		model = "deepseek-v4-flash-0731"
	}
	return &LLMGenerator{
		APIKey: key, BaseURL: strings.TrimRight(base, "/"), Model: model,
		HTTP: &http.Client{Timeout: 20 * time.Second}, Fallback: TemplateGenerator{}, PromptVersion: "growth-p0-v1",
	}
}

func (g *LLMGenerator) Generate(ctx context.Context, input GenerationInput) (GenerationResult, error) {
	fallback := func() (GenerationResult, error) {
		result, err := g.Fallback.Generate(ctx, input)
		if err == nil {
			result.ModelName = g.Model
			result.PromptVersion = firstNonEmpty(g.PromptVersion, "growth-p0-v1")
		}
		return result, err
	}
	facts, _ := json.Marshal(FactsSnapshot(input.Subject))
	system := "你是熊舍管家的内容导演。只能使用给出的公开事实生成内容，禁止推断健康、价格、库存或内部位置。严格只返回 JSON。"
	user := fmt.Sprintf("类型=%s 平台=%s 目标=%s 时长=%v 语气=%s CTA=%s\n公开事实=%s\n输出字段：title, hook, cover_text, sections(order,duration_seconds,shot,voiceover,overlay), caption, hashtags, cta, facts(key,value,source)。", input.CampaignType, input.Platform, input.Goal, input.DurationSeconds, input.Tone, input.CTA, facts)
	body, _ := json.Marshal(map[string]any{
		"model":       g.Model,
		"messages":    []map[string]string{{"role": "system", "content": system}, {"role": "user", "content": user}},
		"temperature": 0.4,
	})
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, g.BaseURL+"/chat/completions", bytes.NewReader(body))
	if err != nil {
		return fallback()
	}
	req.Header.Set("Authorization", "Bearer "+g.APIKey)
	req.Header.Set("Content-Type", "application/json")
	resp, err := g.HTTP.Do(req)
	if err != nil {
		return fallback()
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode >= 300 {
		return fallback()
	}
	var envelope struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if json.Unmarshal(raw, &envelope) != nil || len(envelope.Choices) == 0 {
		return fallback()
	}
	content := strings.TrimSpace(envelope.Choices[0].Message.Content)
	content = strings.TrimPrefix(content, "```json")
	content = strings.TrimSuffix(strings.TrimSpace(content), "```")
	var script ScriptPayload
	if json.Unmarshal([]byte(strings.TrimSpace(content)), &script) != nil || !validScript(script, input.Subject) {
		return fallback()
	}
	script.Facts = FactsForHamster(input.Subject)
	return GenerationResult{
		Script: script, FactsSnapshot: FactsSnapshot(input.Subject), ModelName: g.Model,
		PromptVersion: firstNonEmpty(g.PromptVersion, "growth-p0-v1"),
	}, nil
}

func validScript(script ScriptPayload, subject PublicHamster) bool {
	return subject.ID != "" && strings.TrimSpace(script.Title) != "" && strings.TrimSpace(script.Hook) != "" && len(script.Sections) > 0 && strings.TrimSpace(script.CTA) != ""
}

func firstEnv(keys ...string) string {
	for _, key := range keys {
		if value := strings.TrimSpace(os.Getenv(key)); value != "" {
			return value
		}
	}
	return ""
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return strings.TrimSpace(value)
		}
	}
	return ""
}
