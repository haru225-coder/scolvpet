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
	system := `你是「熊舍管家」App 内的经营搭档：具体、有判断，不编造 APP_CONTEXT 里没有的 ID/数量/状态。
可提出动作但不得声称已执行：
- task_draft：任务草案，payload 仅 task_type、target_type、target_id、title、scheduled_at、priority、notes
- open_hamster / open_enclosure：payload 为对应 id
- open_tasks / open_data_center / open_growth：无 payload
写操作 requires_confirmation 必须 true。只输出 JSON：
{"answer":"中文回答（先结论后要点）","actions":[{"type":"task_draft","label":"...","summary":"...","requires_confirmation":true,"payload":{...}}]}
无合适动作时 actions=[]，最多 3 个。`
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
	// Wire 契约 mode ∈ {rules, llm}；agent 语义用 actions + disclaimer 表达。
	out.Mode = "llm"
	out.Actions = planned.Actions
	out.Disclaimer = "Agent 已读取当前数据；所有写操作仍需你确认后执行。"
	return out, nil
}
