// Package aicore implements the structured-data layer for the 熊舍 AI Agent (T-P2-03).
// Optional LLM polish via Grok2API (gk.scolv.com) when AI_API_KEY/XAI_API_KEY is set;
// write operations remain explicit confirmation flows in the app.
package aicore

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
	"unicode"
)

// Fact is one structured data point used to answer.
type Fact struct {
	Key    string `json:"key"`
	Label  string `json:"label"`
	Value  string `json:"value"`
	Source string `json:"source"`
}

// Snapshot is owner-scoped readonly metrics for answering.
type Snapshot struct {
	OrganizationName string
	ActiveHamsters   int64
	ActiveLitters    int64
	Enclosures       int64
	OpenTasks        int64
	OverdueTasks     int64
	GestatingPlans   int64
	MediaBytes       float64
	PlanCode         string
	GeneratedAt      time.Time
}

// Answer is the assistant response.
type Answer struct {
	Answer     string        `json:"answer"`
	Intent     string        `json:"intent"`
	Mode       string        `json:"mode"` // rules | llm
	Facts      []Fact        `json:"facts"`
	Actions    []AgentAction `json:"actions,omitempty"`
	Disclaimer string        `json:"disclaimer"`
}

// AgentAction is an owner-confirmed application operation proposed by the LLM.
// The API validates every action and never executes writes during chat.
type AgentAction struct {
	Type                 string         `json:"type"`
	Label                string         `json:"label"`
	Summary              string         `json:"summary"`
	RequiresConfirmation bool           `json:"requires_confirmation"`
	Payload              map[string]any `json:"payload,omitempty"`
}

// Intents.
const (
	IntentHelp     = "help"
	IntentOverview = "overview"
	IntentHamsters = "hamsters"
	IntentTasks    = "tasks"
	IntentOverdue  = "overdue"
	IntentBreeding = "breeding"
	IntentUsage    = "usage"
	IntentPlan     = "plan"
	IntentUnknown  = "unknown"
)

// DetectIntent maps free text to a structured intent (Chinese + English keywords).
func DetectIntent(question string) string {
	q := strings.ToLower(strings.TrimSpace(question))
	// Normalize full-width spaces.
	q = strings.Map(func(r rune) rune {
		if unicode.IsSpace(r) {
			return ' '
		}
		return r
	}, q)

	switch {
	case containsAny(q, "帮助", "你能做什么", "help", "能干什么", "怎么用"):
		return IntentHelp
	case containsAny(q, "逾期", "过期", "overdue", "拖欠"):
		return IntentOverdue
	case containsAny(q, "待办", "任务", "提醒", "task", "todo"):
		return IntentTasks
	case containsAny(q, "繁育", "孕期", "配种", "窝次", "breeding", "gestation", "litter"):
		return IntentBreeding
	case containsAny(q, "用量", "配额", "空间", "媒体", "usage", "quota", "storage"):
		return IntentUsage
	case containsAny(q, "套餐", "专业版", "免费版", "权益", "plan", "pro", "entitlement"):
		return IntentPlan
	case containsAny(q, "多少只", "在养", "仓鼠", "hamster", "个体", "档案数"):
		return IntentHamsters
	case containsAny(q, "概况", "总览", "今天", "怎么样", "overview", "summary", "状态"):
		return IntentOverview
	default:
		if q == "" {
			return IntentHelp
		}
		return IntentUnknown
	}
}

// AnswerFromSnapshot builds a deterministic rules answer.
func AnswerFromSnapshot(question string, snap Snapshot) Answer {
	intent := DetectIntent(question)
	facts := snapshotFacts(snap)
	var body string
	switch intent {
	case IntentHelp:
		body = "我是只读助手，可以回答：在养数量、待办/逾期任务、繁育概况、用量与套餐。请用自然语言提问，例如「现在有多少只在养？」「有没有逾期任务？」"
	case IntentHamsters:
		body = fmt.Sprintf("%s当前在养仓鼠约 %d 只，笼盒 %d 个。", orgPrefix(snap), snap.ActiveHamsters, snap.Enclosures)
	case IntentTasks:
		body = fmt.Sprintf("%s未完成任务 %d 项，其中逾期 %d 项。", orgPrefix(snap), snap.OpenTasks, snap.OverdueTasks)
	case IntentOverdue:
		if snap.OverdueTasks == 0 {
			body = fmt.Sprintf("%s目前没有逾期任务。", orgPrefix(snap))
		} else {
			body = fmt.Sprintf("%s有 %d 项逾期任务，建议优先在「今日」或任务列表处理。", orgPrefix(snap), snap.OverdueTasks)
		}
	case IntentBreeding:
		body = fmt.Sprintf("%s活跃窝次 %d，孕期/繁育中计划约 %d。", orgPrefix(snap), snap.ActiveLitters, snap.GestatingPlans)
	case IntentUsage:
		body = fmt.Sprintf("%s媒体占用约 %s，套餐 %s。", orgPrefix(snap), formatBytes(snap.MediaBytes), planLabel(snap.PlanCode))
	case IntentPlan:
		body = fmt.Sprintf("%s当前套餐为 %s（软门禁）。可在「套餐与权益」查看上限与沙箱升级。", orgPrefix(snap), planLabel(snap.PlanCode))
	case IntentOverview:
		body = fmt.Sprintf(
			"%s概况：在养 %d、笼盒 %d、窝次 %d、待办 %d（逾期 %d）、繁育计划 %d、套餐 %s。",
			orgPrefix(snap), snap.ActiveHamsters, snap.Enclosures, snap.ActiveLitters,
			snap.OpenTasks, snap.OverdueTasks, snap.GestatingPlans, planLabel(snap.PlanCode),
		)
	default:
		body = fmt.Sprintf(
			"我按现有数据理解可能不够准确。当前概况：在养 %d、待办 %d（逾期 %d）。可改问「在养多少」「逾期任务」「繁育概况」。",
			snap.ActiveHamsters, snap.OpenTasks, snap.OverdueTasks,
		)
		intent = IntentUnknown
	}
	return Answer{
		Answer:     body,
		Intent:     intent,
		Mode:       "rules",
		Facts:      facts,
		Disclaimer: "只读助手：基于结构化查询，不会修改任何数据。",
	}
}

// OptionalLLMClient polishes a rules answer via Grok2API when configured.
type OptionalLLMClient struct {
	APIKey  string
	BaseURL string
	Model   string
	HTTP    *http.Client
}

func firstEnv(keys ...string) string {
	for _, key := range keys {
		if value := strings.TrimSpace(os.Getenv(key)); value != "" {
			return value
		}
	}
	return ""
}

// NewOptionalLLMFromEnv reads AI_* then XAI_*; defaults to Grok2API (gk.scolv.com) + grok-build-0.1.
func NewOptionalLLMFromEnv() *OptionalLLMClient {
	key := firstEnv("AI_API_KEY", "XAI_API_KEY")
	if key == "" {
		return nil
	}
	base := firstEnv("AI_BASE_URL", "XAI_BASE_URL")
	if base == "" {
		base = "https://gk.scolv.com:8443/v1"
	}
	model := firstEnv("AI_MODEL", "XAI_MODEL")
	if model == "" {
		model = "grok-build-0.1"
	}
	// 控制在移动端默认 receiveTimeout(12s) 之内：上游慢/429 时尽快回退 rules，
	// 避免整次 ask 卡满 20s 导致客户端先超时显示「助手请求失败」。
	return &OptionalLLMClient{
		APIKey:  key,
		BaseURL: strings.TrimRight(base, "/"),
		Model:   model,
		HTTP:    &http.Client{Timeout: 8 * time.Second},
	}
}

// Polish rewrites the rules answer in friendlier Chinese without inventing numbers.
func (c *OptionalLLMClient) Polish(ctx context.Context, question string, rules Answer) (Answer, error) {
	if c == nil || c.APIKey == "" {
		return rules, nil
	}
	factsJSON, _ := json.Marshal(rules.Facts)
	system := "你是熊舍管家 AI Agent。只能依据给出的 facts 回答，禁止编造数字；涉及写操作时只说明需要用户确认，不要假装已经执行。用简洁中文。"
	user := fmt.Sprintf("用户问题：%s\n规则答案：%s\nfacts JSON：%s\n请润色规则答案，保持数字一致。", question, rules.Answer, string(factsJSON))
	payload := map[string]any{
		"model": c.Model,
		"messages": []map[string]string{
			{"role": "system", "content": system},
			{"role": "user", "content": user},
		},
		"temperature": 0.2,
	}
	body, _ := json.Marshal(payload)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.BaseURL+"/chat/completions", bytes.NewReader(body))
	if err != nil {
		return rules, err
	}
	req.Header.Set("Authorization", "Bearer "+c.APIKey)
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return rules, err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode >= 300 {
		return rules, fmt.Errorf("llm status %d: %s", resp.StatusCode, truncate(string(raw), 200))
	}
	var parsed struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return rules, err
	}
	if len(parsed.Choices) == 0 || strings.TrimSpace(parsed.Choices[0].Message.Content) == "" {
		return rules, fmt.Errorf("empty llm response")
	}
	out := rules
	out.Answer = strings.TrimSpace(parsed.Choices[0].Message.Content)
	out.Mode = "llm"
	return out, nil
}

func snapshotFacts(snap Snapshot) []Fact {
	return []Fact{
		{Key: "organization", Label: "熊舍", Value: firstNonEmpty(snap.OrganizationName, "未命名"), Source: "organization"},
		{Key: "active_hamsters", Label: "在养", Value: fmt.Sprintf("%d", snap.ActiveHamsters), Source: "usage_or_count"},
		{Key: "enclosures", Label: "笼盒", Value: fmt.Sprintf("%d", snap.Enclosures), Source: "usage_or_count"},
		{Key: "active_litters", Label: "窝次", Value: fmt.Sprintf("%d", snap.ActiveLitters), Source: "usage_or_count"},
		{Key: "open_tasks", Label: "待办", Value: fmt.Sprintf("%d", snap.OpenTasks), Source: "care_task"},
		{Key: "overdue_tasks", Label: "逾期", Value: fmt.Sprintf("%d", snap.OverdueTasks), Source: "care_task"},
		{Key: "gestating_plans", Label: "繁育中", Value: fmt.Sprintf("%d", snap.GestatingPlans), Source: "breeding_plan"},
		{Key: "media_bytes", Label: "媒体占用", Value: formatBytes(snap.MediaBytes), Source: "usage_meter"},
		{Key: "plan_code", Label: "套餐", Value: planLabel(snap.PlanCode), Source: "entitlement"},
	}
}

func orgPrefix(snap Snapshot) string {
	if strings.TrimSpace(snap.OrganizationName) == "" {
		return ""
	}
	return snap.OrganizationName + "："
}

func planLabel(code string) string {
	switch code {
	case "pro":
		return "专业版"
	case "free", "":
		return "免费版"
	default:
		return code
	}
}

func formatBytes(v float64) string {
	if v < 1024 {
		return fmt.Sprintf("%.0f B", v)
	}
	if v < 1024*1024 {
		return fmt.Sprintf("%.1f KB", v/1024)
	}
	if v < 1024*1024*1024 {
		return fmt.Sprintf("%.1f MB", v/(1024*1024))
	}
	return fmt.Sprintf("%.2f GB", v/(1024*1024*1024))
}

func containsAny(q string, keys ...string) bool {
	for _, k := range keys {
		if strings.Contains(q, strings.ToLower(k)) {
			return true
		}
	}
	return false
}

func firstNonEmpty(values ...string) string {
	for _, v := range values {
		if strings.TrimSpace(v) != "" {
			return strings.TrimSpace(v)
		}
	}
	return ""
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}
