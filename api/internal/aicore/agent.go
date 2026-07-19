package aicore

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

// RunAgent asks an OpenAI-compatible model to reason over an owner-scoped app
// context and propose whitelisted UI/write actions. Writes remain drafts until
// the mobile client opens a confirmation form.
func (c *OptionalLLMClient) RunAgent(
	ctx context.Context,
	question string,
	rules Answer,
	appContext map[string]any,
) (Answer, error) {
	if c == nil || c.APIKey == "" {
		return rules, nil
	}
	contextJSON, _ := json.Marshal(appContext)
	system := `你是熊舍管家应用内 Agent。你必须基于 APP_CONTEXT 中的真实数据回答，不得编造 ID、数量或状态。
你可以提出以下动作，但不得声称已经执行：
- task_draft：创建任务草案，payload 只能包含 task_type、target_type、target_id、title、scheduled_at、priority、notes。
- open_hamster：打开仓鼠详情，payload 为 hamster_id。
- open_enclosure：打开笼盒详情，payload 为 enclosure_id。
- open_tasks、open_data_center、open_growth：打开对应页面，payload 为空。
任何写操作 requires_confirmation 必须为 true。输出严格 JSON，不要 Markdown：
{"answer":"中文回答","actions":[{"type":"task_draft","label":"查看任务草案","summary":"...","requires_confirmation":true,"payload":{...}}]}
没有合适动作时 actions 返回空数组。最多返回 3 个动作。`
	user := fmt.Sprintf(
		"用户请求：%s\n规则基线：%s\nAPP_CONTEXT：%s",
		question,
		rules.Answer,
		string(contextJSON),
	)
	payload := map[string]any{
		"model": c.Model,
		"messages": []map[string]string{
			{"role": "system", "content": system},
			{"role": "user", "content": user},
		},
		"temperature":     0.15,
		"max_tokens":      600,
		"response_format": map[string]string{"type": "json_object"},
	}
	body, _ := json.Marshal(payload)
	req, err := http.NewRequestWithContext(
		ctx,
		http.MethodPost,
		c.BaseURL+"/chat/completions",
		bytes.NewReader(body),
	)
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
		return rules, fmt.Errorf("agent status %d: %s", resp.StatusCode, truncate(string(raw), 200))
	}
	var completion struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.Unmarshal(raw, &completion); err != nil {
		return rules, err
	}
	if len(completion.Choices) == 0 {
		return rules, fmt.Errorf("empty agent response")
	}
	content := strings.TrimSpace(completion.Choices[0].Message.Content)
	content = strings.TrimPrefix(content, "```json")
	content = strings.TrimPrefix(content, "```")
	content = strings.TrimSuffix(content, "```")
	var planned struct {
		Answer  string        `json:"answer"`
		Actions []AgentAction `json:"actions"`
	}
	if err := json.Unmarshal([]byte(strings.TrimSpace(content)), &planned); err != nil {
		return rules, err
	}
	if strings.TrimSpace(planned.Answer) == "" {
		return rules, fmt.Errorf("empty agent answer")
	}
	out := rules
	out.Answer = strings.TrimSpace(planned.Answer)
	out.Mode = "agent"
	out.Actions = planned.Actions
	out.Disclaimer = "Agent 已读取当前数据；所有写操作仍需你确认后执行。"
	return out, nil
}
