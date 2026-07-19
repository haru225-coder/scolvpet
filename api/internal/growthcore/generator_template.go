package growthcore

import (
	"context"
	"fmt"
	"strings"
)

type TemplateGenerator struct{}

func (TemplateGenerator) Generate(_ context.Context, input GenerationInput) (GenerationResult, error) {
	if input.Subject.ID == "" {
		return GenerationResult{}, fmt.Errorf("subject hamster is required")
	}
	name := displayName(input.Subject)
	goal := strings.TrimSpace(input.Goal)
	if goal == "" {
		goal = "记录成长并引导咨询"
	}
	tone := strings.TrimSpace(input.Tone)
	if tone == "" {
		tone = "温柔自然"
	}
	cta := strings.TrimSpace(input.CTA)
	if cta == "" {
		cta = input.Subject.CTAText
	}
	if cta == "" {
		cta = "想了解这只仓鼠，可以进入主页咨询。"
	}
	duration := 35
	if input.DurationSeconds != nil && *input.DurationSeconds > 0 {
		duration = *input.DurationSeconds
	}
	sections := []ScriptSection{
		{Order: 1, DurationSeconds: min(duration/5, 8), Shot: "环境与仓鼠自然活动的稳定画面", Voiceover: fmt.Sprintf("今天带你认识%s，记录它最近的真实状态。", name), Overlay: "真实成长记录"},
		{Order: 2, DurationSeconds: min(duration/3, 15), Shot: "仓鼠侧面或互动近景", Voiceover: fmt.Sprintf("%s，%s。", name, publicDescription(input.Subject)), Overlay: publicOverlay(input.Subject)},
		{Order: 3, DurationSeconds: min(duration/4, 12), Shot: "补充活动、进食或探索画面", Voiceover: fmt.Sprintf("这次内容的主题是%s，欢迎在评论区告诉我们你最想了解什么。", goal), Overlay: "只使用已公开资料"},
		{Order: 4, DurationSeconds: max(duration/10, 3), Shot: "熊舍主页或仓鼠回头画面", Voiceover: cta, Overlay: "进入主页咨询"},
	}
	if input.CampaignType == "live" {
		sections = []ScriptSection{
			{Order: 1, DurationSeconds: 60, Shot: "开场与熊舍环境", Voiceover: fmt.Sprintf("欢迎来到熊舍，今天先认识%s。", name), Overlay: "直播开场"},
			{Order: 2, DurationSeconds: max(duration/3, 90), Shot: "仓鼠出镜与现场互动", Voiceover: fmt.Sprintf("我们根据公开资料介绍%s：%s。", name, publicDescription(input.Subject)), Overlay: publicOverlay(input.Subject)},
			{Order: 3, DurationSeconds: max(duration/3, 90), Shot: "回答观众问题，展示活动状态", Voiceover: "大家可以问品种、性别、生日和公开特点；涉及健康、价格和预订，请由熊舍人工确认。", Overlay: "公开资料问答"},
			{Order: 4, DurationSeconds: 60, Shot: "收尾与主页二维码/链接", Voiceover: cta, Overlay: "进入主页咨询"},
		}
	}
	return GenerationResult{
		Script: ScriptPayload{
			Title:     fmt.Sprintf("%s｜%s", name, goal),
			Hook:      fmt.Sprintf("你见过%s这样自然活动吗？", name),
			CoverText: fmt.Sprintf("认识%s", name),
			Sections:  sections,
			Caption:   fmt.Sprintf("%s｜%s。%s", name, goal, cta),
			Hashtags:  []string{"#仓鼠", "#金丝熊", "#熊舍日常", "#成长记录"},
			CTA:       cta,
			Facts:     FactsForHamster(input.Subject),
		},
		FactsSnapshot: FactsSnapshot(input.Subject),
		ModelName:     "template-v1",
		PromptVersion: "growth-p0-v1",
	}, nil
}

func publicDescription(item PublicHamster) string {
	parts := make([]string, 0, 4)
	if item.Variety != "" {
		parts = append(parts, "品种是"+item.Variety)
	}
	if item.Sex != "" {
		parts = append(parts, "性别为"+sexLabel(item.Sex))
	}
	if len(item.Traits) > 0 {
		parts = append(parts, "公开特点是"+strings.Join(item.Traits, "、"))
	}
	if item.Summary != "" {
		parts = append(parts, item.Summary)
	}
	if len(parts) == 0 {
		return "这段介绍只使用熊舍已经公开的资料"
	}
	return strings.Join(parts, "，")
}

func publicOverlay(item PublicHamster) string {
	parts := make([]string, 0, 2)
	if item.Variety != "" {
		parts = append(parts, item.Variety)
	}
	if item.BirthDate != "" {
		parts = append(parts, "生日 "+item.BirthDate)
	}
	return strings.Join(parts, " · ")
}
