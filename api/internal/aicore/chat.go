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

// Chat runs general conversation with grok-build-0.1 when configured.
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
	const maxRounds = 4

	for round := 0; round < maxRounds; round++ {
		payload := map[string]any{
			"model":       c.Model,
			"messages":    messages,
			"temperature": 0.35,
			"max_tokens":  1200,
		}
		if len(req.Tools) > 0 && req.RunTool != nil {
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
					Role      string `json:"role"`
					Content   any    `json:"content"`
					ToolCalls []struct {
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
				return Answer{}, fmt.Errorf("empty chat response")
			}
			facts := toolFacts
			if len(facts) == 0 && req.Snapshot != nil {
				facts = snapshotFacts(*req.Snapshot)
			}
			disclaimer := "通用对话 + 本舍工具核验：数量与状态以 tool/结构化事实为准；写操作需你确认后执行。"
			if len(pendingActions) > 0 {
				disclaimer = "已生成待确认写操作卡片；确认前不会改库。"
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
						Value:  truncate(toolResultJSON(value), 160),
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
		// Write drafts already require UI confirm; stop looping so we return
		// promptly instead of burning remaining rounds.
		if len(pendingActions) > 0 {
			answerText := "已准备好待确认操作，请在卡片上确认或取消。"
			if trimmed := strings.TrimSpace(contentText); trimmed != "" {
				answerText = trimmed
			}
			return Answer{
				Answer:     answerText,
				Intent:     "general",
				Mode:       "llm",
				Facts:      toolFacts,
				Actions:    pendingActions,
				Disclaimer: "已生成待确认写操作卡片；确认前不会改库。",
			}, nil
		}
	}
	// Prefer returning partial tool facts over hard failure when the model
	// keeps requesting tools past maxRounds (fallback still available upstream).
	if len(toolFacts) > 0 {
		return Answer{
			Answer:     "已查询本舍数据，但对话轮次用尽。可继续追问，或换一种说法。",
			Intent:     "general",
			Mode:       "llm",
			Facts:      toolFacts,
			Actions:    pendingActions,
			Disclaimer: "通用对话 + 本舍工具核验：数量与状态以 tool/结构化事实为准；写操作需你确认后执行。",
		}, nil
	}
	return Answer{}, fmt.Errorf("tool loop exceeded max rounds")
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
	base := `你是「熊舍管家」App 内的通用 AI 助手（模型：Grok Build）。
你可以：闲聊、养宠通识、经营文案、流程建议、解释 App 功能。
纪律：
1. 涉及本舍具体数量、个体、任务、金额、状态时，禁止编造；`
	if withTools {
		base += `必须先调用工具（get_overview / search_hamsters / list_tasks / create_task 等）再回答。
2. 工具结果优先于下方快照；快照仅作参考。
3. 用户要求创建/完成任务、登记体重、新建/更新仓鼠、新建笼盒时，调用对应写入工具生成「待确认草案」；向用户说明需在 App 点确认后才会生效，禁止说「已创建/已完成」。`
	} else {
		base += `只能依据下方「本舍结构化事实」；没有的就说明不确定。
2. 不要声称已经改过业务数据。
3. 写操作需要用户确认。`
	}
	base += `
4. 用简洁自然的中文；需要分点时用短列表。
5. 不要输出 JSON 或 Markdown 代码围栏，除非用户明确要求代码。`
	facts := strings.TrimSpace(kennelFacts)
	if facts == "" {
		facts = "（暂无快照）"
	}
	return base + "\n\n本舍结构化事实（参考）：\n" + facts
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
