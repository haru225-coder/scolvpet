package aicore

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// ChatMessage is one turn in a multi-turn assistant session.
type ChatMessage struct {
	Role    string `json:"role"` // user | assistant | system
	Content string `json:"content"`
}

// ChatRequest drives the general-chat path (tools optional, Slice B).
type ChatRequest struct {
	// History is prior turns (user/assistant only). Do not include the latest user message.
	History []ChatMessage
	// UserMessage is the latest user input.
	UserMessage string
	// KennelFacts is a short structured snapshot injected into the system prompt.
	KennelFacts string
	// PreferLLM attempts Grok; on failure returns rules fallback when Snapshot is set.
	PreferLLM bool
	// Snapshot enables rules fallback for kennel-scoped questions.
	Snapshot *Snapshot
	// Tools enables OpenAI tool_calls (Slice B read-only).
	Tools []ToolDefinition
	// RunTool executes tools; required when Tools is non-empty.
	RunTool ToolRunner
}

// Chat runs general conversation with the configured AI_MODEL (default deepseek-v4-flash-0731).
// Without LLM or on failure: rules AnswerFromSnapshot if Snapshot is set, else a fixed help line.
func (c *OptionalLLMClient) Chat(ctx context.Context, req ChatRequest) (Answer, error) {
	fallback := chatFallback(req)
	if !req.PreferLLM || c == nil || c.APIKey == "" {
		return fallback, nil
	}
	out, err := c.runGeneralChat(ctx, req)
	if err != nil {
		return fallback, err
	}
	return out, nil
}

func chatFallback(req ChatRequest) Answer {
	if req.Snapshot != nil {
		return AnswerFromSnapshot(req.UserMessage, *req.Snapshot)
	}
	return Answer{
		Answer:     "我是熊舍管家助手。智能服务暂不可用时，仍可问在养数量、待办、繁育概况、用量与套餐。",
		Intent:     IntentHelp,
		Mode:       "rules",
		Facts:      nil,
		Disclaimer: "当前为规则降级模式。",
	}
}

func (c *OptionalLLMClient) runGeneralChat(ctx context.Context, req ChatRequest) (Answer, error) {
	system := generalChatSystemPrompt(req.KennelFacts, len(req.Tools) > 0)
	messages := make([]map[string]any, 0, len(req.History)+8)
	messages = append(messages, map[string]any{"role": "system", "content": system})
	for _, m := range req.History {
		role := strings.TrimSpace(m.Role)
		if role != "user" && role != "assistant" {
			continue
		}
		content := strings.TrimSpace(m.Content)
		if content == "" {
			continue
		}
		if len([]rune(content)) > 2000 {
			content = string([]rune(content)[:2000]) + "…"
		}
		messages = append(messages, map[string]any{"role": role, "content": content})
	}
	messages = append(messages, map[string]any{"role": "user", "content": strings.TrimSpace(req.UserMessage)})

	client := c.httpClientForChat()
	allowed := allowedToolNames()
	toolFacts := make([]Fact, 0, 8)
	pendingActions := make([]AgentAction, 0, 4)
	const maxRounds = 6
	// After write drafts or final tool batch, force one synthesis round without tools.
	forceSynthesize := false

	for round := 0; round < maxRounds; round++ {
		payload := map[string]any{
			"model":       c.Model,
			"messages":    messages,
			"temperature": 0.55,
			// Flash-0731 会占用 reasoning tokens；给足输出预算避免正文被挤空。
			"max_tokens": 4096,
		}
		toolsOn := len(req.Tools) > 0 && req.RunTool != nil && !forceSynthesize
		if toolsOn {
			payload["tools"] = req.Tools
			payload["tool_choice"] = "auto"
		}
		body, _ := json.Marshal(payload)
		httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.BaseURL+"/chat/completions", bytes.NewReader(body))
		if err != nil {
			return Answer{}, err
		}
		httpReq.Header.Set("Authorization", "Bearer "+c.APIKey)
		httpReq.Header.Set("Content-Type", "application/json")

		resp, err := client.Do(httpReq)
		if err != nil {
			return Answer{}, err
		}
		raw, _ := io.ReadAll(resp.Body)
		_ = resp.Body.Close()
		if resp.StatusCode >= 300 {
			return Answer{}, fmt.Errorf("chat status %d: %s", resp.StatusCode, truncate(string(raw), 200))
		}

		var parsed struct {
			Choices []struct {
				Message struct {
					Role             string `json:"role"`
					Content          any    `json:"content"`
					ReasoningContent string `json:"reasoning_content"`
					ToolCalls        []struct {
						ID       string `json:"id"`
						Type     string `json:"type"`
						Function struct {
							Name      string `json:"name"`
							Arguments string `json:"arguments"`
						} `json:"function"`
					} `json:"tool_calls"`
				} `json:"message"`
				FinishReason string `json:"finish_reason"`
			} `json:"choices"`
		}
		if err := json.Unmarshal(raw, &parsed); err != nil {
			return Answer{}, err
		}
		if len(parsed.Choices) == 0 {
			return Answer{}, fmt.Errorf("empty chat response")
		}
		msg := parsed.Choices[0].Message
		contentText := messageContentString(msg.Content)

		if len(msg.ToolCalls) == 0 {
			if strings.TrimSpace(contentText) == "" {
				// 推理模型偶发只填 reasoning_content；勿整轮失败掉进弱规则模板。
				if len(toolFacts) > 0 || len(pendingActions) > 0 {
					return synthesizeFromTools(toolFacts, pendingActions), nil
				}
				return Answer{}, fmt.Errorf("empty chat response")
			}
			facts := toolFacts
			if len(facts) == 0 && req.Snapshot != nil {
				facts = snapshotFacts(*req.Snapshot)
			}
			disclaimer := "本舍数量/状态以工具查询为准；写操作需你点确认后才会执行。"
			if len(pendingActions) > 0 {
				disclaimer = "已生成待确认操作卡片；确认前不会改库。"
			}
			return Answer{
				Answer:     strings.TrimSpace(contentText),
				Intent:     "general",
				Mode:       "llm",
				Facts:      facts,
				Actions:    pendingActions,
				Disclaimer: disclaimer,
			}, nil
		}

		// Append assistant message with tool_calls for the next round.
		assistantMsg := map[string]any{
			"role":       "assistant",
			"content":    contentText,
			"tool_calls": msg.ToolCalls,
		}
		messages = append(messages, assistantMsg)

		for _, call := range msg.ToolCalls {
			name := strings.TrimSpace(call.Function.Name)
			args := parseToolArgs(call.Function.Arguments)
			var result any
			if !allowed[name] {
				result = map[string]any{"error": "tool not allowed", "name": name}
			} else if req.RunTool == nil {
				result = map[string]any{"error": "tool runner unavailable"}
			} else {
				value, err := req.RunTool(ctx, name, args)
				if err != nil {
					result = map[string]any{"error": err.Error()}
				} else {
					result = value
					toolFacts = append(toolFacts, Fact{
						Key:    "tool:" + name,
						Label:  "工具 " + name,
						Value:  truncate(toolResultJSON(value), 240),
						Source: "tool",
					})
					if action, ok := agentActionFromToolResult(name, value); ok && len(pendingActions) < 3 {
						pendingActions = append(pendingActions, action)
					}
				}
			}
			messages = append(messages, map[string]any{
				"role":         "tool",
				"tool_call_id": call.ID,
				"content":      toolResultJSON(result),
			})
		}
		// 有写草案时：再跑一轮「只说话」合成自然语言，避免干巴巴一句「已准备好」。
		if len(pendingActions) > 0 {
			forceSynthesize = true
			messages = append(messages, map[string]any{
				"role":    "user",
				"content": "工具结果已返回。请用自然、具体的中文总结你查到的内容，并说明待确认卡片上用户需要做什么。不要再调用工具。",
			})
			continue
		}
	}
	// Prefer returning partial tool facts over hard failure when the model
	// keeps requesting tools past maxRounds (fallback still available upstream).
	if len(toolFacts) > 0 || len(pendingActions) > 0 {
		return synthesizeFromTools(toolFacts, pendingActions), nil
	}
	return Answer{}, fmt.Errorf("tool loop exceeded max rounds")
}

func synthesizeFromTools(toolFacts []Fact, pending []AgentAction) Answer {
	var b strings.Builder
	if len(pending) > 0 {
		b.WriteString("我已经根据本舍数据准备好待确认操作")
		if len(pending) == 1 {
			b.WriteString("：")
			b.WriteString(pending[0].Summary)
		} else {
			b.WriteString("：")
			for i, a := range pending {
				if i > 0 {
					b.WriteString("；")
				}
				b.WriteString(a.Summary)
			}
		}
		b.WriteString("。请在下方卡片确认后才会写入。")
	} else {
		b.WriteString("已查到本舍相关数据")
		if len(toolFacts) > 0 {
			b.WriteString("（")
			for i, f := range toolFacts {
				if i >= 3 {
					break
				}
				if i > 0 {
					b.WriteString("；")
				}
				b.WriteString(f.Label)
				b.WriteString("=")
				b.WriteString(f.Value)
			}
			b.WriteString("）")
		}
		b.WriteString("。你可以继续追问细节，例如某只个体、某条任务或下一步怎么做。")
	}
	disclaimer := "本舍数量/状态以工具查询为准；写操作需你点确认后才会执行。"
	if len(pending) > 0 {
		disclaimer = "已生成待确认操作卡片；确认前不会改库。"
	}
	return Answer{
		Answer:     b.String(),
		Intent:     "general",
		Mode:       "llm",
		Facts:      toolFacts,
		Actions:    pending,
		Disclaimer: disclaimer,
	}
}

func (c *OptionalLLMClient) httpClientForChat() *http.Client {
	if c.HTTP == nil {
		return &http.Client{Timeout: 25 * time.Second}
	}
	if c.HTTP.Timeout > 0 && c.HTTP.Timeout < 15*time.Second {
		return &http.Client{Timeout: 25 * time.Second, Transport: c.HTTP.Transport}
	}
	return c.HTTP
}

func messageContentString(content any) string {
	switch v := content.(type) {
	case string:
		return v
	case nil:
		return ""
	default:
		b, _ := json.Marshal(v)
		return string(b)
	}
}

func generalChatSystemPrompt(kennelFacts string, withTools bool) string {
	base := `你是「熊舍管家」App 里的经营搭档：像一个懂仓鼠繁育与日常照护的店长助理，不是客服话术机，也不是只读报表。
能力：闲聊、养宠通识、文案润色、流程建议、解释 App；更重要的是——基于本舍真实数据帮用户想清楚下一步。
说话：自然、具体、有判断；先给结论再补关键数字；少套话、少复读用户问题；不要用「作为 AI」开头。
纪律：
1. 涉及本舍数量、个体、任务、金额、状态时禁止编造；`
	if withTools {
		base += `先调工具再答。
只读：get_overview、search_hamsters、get_hamster、list_tasks（可用 query 搜标题）、list_enclosures、list_breeding_plans、list_litters、list_crm_contacts、list_crm_reservations、list_crm_handovers、list_accounting_summary、list_accounting_records、search_docs、list_recent_weights、list_health_records。
写入草案（需确认）：create_task、complete_task（task_id 或唯一 query）、create_weight_record、create_hamster、update_hamster、create_enclosure、create_crm_contact、update_crm_contact、create_crm_reservation、confirm_crm_reservation、create_crm_handover、complete_crm_handover、create_accounting_record、create_health_record。
完成任务闭环：先 list_tasks(query=关键词) 拿到 id，再 complete_task(task_id)；若标题唯一也可直接 complete_task(query=…)。
2. 工具结果优先于下方快照；快照可能过期。
3. 改数据时必须走写入工具生成「待确认」；明确说「你确认后才会写入」，禁止说「已创建/已完成」。
4. 问题含糊时给最可能解读 + 1～2 个方向，少空泛反问。
5. 主动给可执行建议，且须有工具数据支撑。`
	} else {
		base += `只能依据下方「本舍结构化事实」；没有的就诚实说不确定。
2. 不要声称已经改过业务数据。
3. 写操作需要用户确认。
4. 问题含糊时给方向而不是空泛客套。`
	}
	base += `
6. 中文为主；需要分点用短列表，不要输出 JSON/代码围栏（除非用户明确要求）。
7. 不要假装能访问外部网页或本 App 以外的系统。`
	facts := strings.TrimSpace(kennelFacts)
	if facts == "" {
		facts = "（暂无快照）"
	}
	return base + "\n\n本舍结构化事实（参考，工具结果优先）：\n" + facts
}

func agentActionFromToolResult(toolName string, value any) (AgentAction, bool) {
	m, ok := value.(map[string]any)
	if !ok {
		return AgentAction{}, false
	}
	// Write tools return {pending_confirmation:true, action_id, type, label, summary, payload}
	if m["pending_confirmation"] != true {
		return AgentAction{}, false
	}
	actionType, _ := m["type"].(string)
	if actionType == "" {
		actionType = toolName
	}
	label, _ := m["label"].(string)
	summary, _ := m["summary"].(string)
	if label == "" || summary == "" {
		return AgentAction{}, false
	}
	payload, _ := m["payload"].(map[string]any)
	if payload == nil {
		payload = map[string]any{}
	}
	if id, ok := m["action_id"].(string); ok && id != "" {
		payload["action_id"] = id
	}
	return AgentAction{
		Type:                 actionType,
		Label:                label,
		Summary:              summary,
		RequiresConfirmation: true,
		Payload:              payload,
	}, true
}

// FormatKennelFacts renders snapshot for system prompt injection.
func FormatKennelFacts(snap Snapshot) string {
	return fmt.Sprintf(
		"熊舍=%s；在养=%d；笼盒=%d；窝次=%d；待办=%d；逾期=%d；繁育中计划=%d；媒体占用=%s；套餐=%s；快照时间=%s",
		firstNonEmpty(snap.OrganizationName, "未命名"),
		snap.ActiveHamsters,
		snap.Enclosures,
		snap.ActiveLitters,
		snap.OpenTasks,
		snap.OverdueTasks,
		snap.GestatingPlans,
		formatBytes(snap.MediaBytes),
		planLabel(snap.PlanCode),
		snap.GeneratedAt.UTC().Format(time.RFC3339),
	)
}
