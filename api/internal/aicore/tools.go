package aicore

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
)

// ToolRunner executes a whitelisted tool by name. Must enforce owner isolation outside aicore.
type ToolRunner func(ctx context.Context, name string, args map[string]any) (any, error)

// ToolDefinition is an OpenAI-compatible function tool.
type ToolDefinition struct {
	Type     string             `json:"type"`
	Function ToolFunctionSchema `json:"function"`
}

type ToolFunctionSchema struct {
	Name        string         `json:"name"`
	Description string         `json:"description"`
	Parameters  map[string]any `json:"parameters"`
}

// ReadOnlyToolDefinitions returns Slice B tools (no writes).
func ReadOnlyToolDefinitions() []ToolDefinition {
	strProp := map[string]any{"type": "string"}
	obj := func(props map[string]any, required ...string) map[string]any {
		m := map[string]any{
			"type":       "object",
			"properties": props,
		}
		if len(required) > 0 {
			m["required"] = required
		}
		return m
	}
	return []ToolDefinition{
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "get_overview",
				Description: "读取本舍概况：在养数量、笼盒、窝次、待办、逾期、繁育中计划、套餐。涉及本舍数量时优先调用。",
				Parameters:  obj(map[string]any{}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "search_hamsters",
				Description: "按名称或编号搜索本舍仓鼠档案（最多 20 条）。",
				Parameters: obj(map[string]any{
					"query": strProp,
					"limit": map[string]any{"type": "integer", "minimum": 1, "maximum": 20},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_tasks",
				Description: "列出或搜索本舍未完成任务（pending/in_progress/snoozed）。可按标题关键词 query 搜索、筛逾期；返回 id 供 complete_task 使用。",
				Parameters: obj(map[string]any{
					"query":        strProp,
					"overdue_only": map[string]any{"type": "boolean"},
					"limit":        map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_enclosures",
				Description: "列出本舍笼盒及状态。",
				Parameters: obj(map[string]any{
					"limit": map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_breeding_plans",
				Description: "列出本舍繁育计划摘要。",
				Parameters: obj(map[string]any{
					"limit": map[string]any{"type": "integer", "minimum": 1, "maximum": 20},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_litters",
				Description: "列出本舍窝次摘要。",
				Parameters: obj(map[string]any{
					"limit": map[string]any{"type": "integer", "minimum": 1, "maximum": 20},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "get_hamster",
				Description: "读取单只仓鼠档案详情（id/编号/名字/性别/状态/笼位/生日）。需要精确个体时用。",
				Parameters: obj(map[string]any{
					"hamster_id": strProp,
				}, "hamster_id"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_crm_contacts",
				Description: "列出或搜索本舍客户（姓名/手机/微信/状态）。",
				Parameters: obj(map[string]any{
					"query": strProp,
					"limit": map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_crm_reservations",
				Description: "列出本舍预订（held/confirmed 等），可按状态筛选。",
				Parameters: obj(map[string]any{
					"status": strProp,
					"limit":  map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_crm_handovers",
				Description: "列出本舍交付单（scheduled/completed），可按状态筛选。",
				Parameters: obj(map[string]any{
					"status": strProp,
					"limit":  map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_accounting_summary",
				Description: "本舍财务摘要：最近 N 天收入/支出合计与笔数（默认 30 天）。",
				Parameters: obj(map[string]any{
					"days": map[string]any{"type": "integer", "minimum": 1, "maximum": 366},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_accounting_records",
				Description: "列出本舍记账明细（标题/金额/类型/时间）；可筛 entry_type(income|expense)、最近 days。",
				Parameters: obj(map[string]any{
					"entry_type": strProp,
					"days":       map[string]any{"type": "integer", "minimum": 1, "maximum": 366},
					"limit":      map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "search_docs",
				Description: "按标题搜索本舍合同/回执单据（draft/issued）。",
				Parameters: obj(map[string]any{
					"query": strProp,
					"kind":  map[string]any{"type": "string", "description": "contract|receipt|空=全部"},
					"limit": map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_recent_weights",
				Description: "最近体重记录；可指定 hamster_id。",
				Parameters: obj(map[string]any{
					"hamster_id": strProp,
					"limit":      map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "list_health_records",
				Description: "最近健康记录；可指定 hamster_id、type(daily_check|anomaly|medication|follow_up|isolation|death)。",
				Parameters: obj(map[string]any{
					"hamster_id": strProp,
					"type":       strProp,
					"limit":      map[string]any{"type": "integer", "minimum": 1, "maximum": 30},
				}),
			},
		},
		// Slice C write drafts (require user confirmation; do not claim executed).
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_task",
				Description: "创建护理任务草案（需用户确认后才会写入）。payload: task_type,target_type,target_id,title,scheduled_at(RFC3339),priority,notes。",
				Parameters: obj(map[string]any{
					"task_type":    strProp,
					"target_type":  strProp,
					"target_id":    strProp,
					"title":        strProp,
					"scheduled_at": strProp,
					"priority":     strProp,
					"notes":        strProp,
				}, "target_type", "target_id", "title"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "complete_task",
				Description: "完成任务草案（需用户确认）。优先传 task_id；若只有标题可传 query（须唯一匹配一条未完成任务，否则先 list_tasks）。",
				Parameters: obj(map[string]any{
					"task_id": strProp,
					"query":   strProp,
				}),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_weight_record",
				Description: "登记体重草案（需用户确认）。参数 hamster_id、weight_g、recorded_at(可选 RFC3339)。",
				Parameters: obj(map[string]any{
					"hamster_id":  strProp,
					"weight_g":    map[string]any{"type": "number"},
					"recorded_at": strProp,
				}, "hamster_id", "weight_g"),
			},
		},
		// Slice D
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_hamster",
				Description: "新建仓鼠档案草案（需确认）。参数 internal_code(编号)、name、sex(male|female|unknown)、notes 可选；species_rule_version_id 可省略（用本舍默认规则）。",
				Parameters: obj(map[string]any{
					"internal_code":           strProp,
					"name":                    strProp,
					"sex":                     strProp,
					"notes":                   strProp,
					"species_rule_version_id": strProp,
				}, "internal_code"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "update_hamster",
				Description: "更新仓鼠档案草案（需确认）。参数 hamster_id；可选 name、sex、notes。",
				Parameters: obj(map[string]any{
					"hamster_id": strProp,
					"name":       strProp,
					"sex":        strProp,
					"notes":      strProp,
				}, "hamster_id"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_enclosure",
				Description: "新建笼盒草案（需确认）。参数 code(笼号)、capacity 可选默认1。",
				Parameters: obj(map[string]any{
					"code":     strProp,
					"capacity": map[string]any{"type": "integer", "minimum": 1, "maximum": 20},
				}, "code"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_crm_contact",
				Description: "新建客户草案（需确认）。参数 name 必填；可选 phone、wechat、notes、status(lead|active)。",
				Parameters: obj(map[string]any{
					"name":   strProp,
					"phone":  strProp,
					"wechat": strProp,
					"notes":  strProp,
					"status": strProp,
				}, "name"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "update_crm_contact",
				Description: "更新客户草案（需确认）。参数 contact_id 必填；可选 name、phone、wechat、notes、status(lead|active|archived)。至少改一项。",
				Parameters: obj(map[string]any{
					"contact_id": strProp,
					"name":       strProp,
					"phone":      strProp,
					"wechat":     strProp,
					"notes":      strProp,
					"status":     strProp,
				}, "contact_id"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_crm_reservation",
				Description: "新建预订草案（需确认）。参数 contact_id 必填；可选 hamster_id、title、notes。",
				Parameters: obj(map[string]any{
					"contact_id": strProp,
					"hamster_id": strProp,
					"title":      strProp,
					"notes":      strProp,
				}, "contact_id"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_crm_handover",
				Description: "新建交付草案（需确认）。参数 contact_id 必填；须提供 hamster_id 或 reservation_id（或两者）；可选 scheduled_at(RFC3339)、notes。",
				Parameters: obj(map[string]any{
					"contact_id":     strProp,
					"hamster_id":     strProp,
					"reservation_id": strProp,
					"scheduled_at":   strProp,
					"notes":          strProp,
				}, "contact_id"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_accounting_record",
				Description: "记一笔账草案（需确认）。参数 entry_type(income|expense)、amount_cents、title 必填；可选 currency(默认CNY)、contact_id、notes、occurred_at(RFC3339或日期)。",
				Parameters: obj(map[string]any{
					"entry_type":   strProp,
					"amount_cents": map[string]any{"type": "integer", "minimum": 1},
					"title":        strProp,
					"currency":     strProp,
					"contact_id":   strProp,
					"notes":        strProp,
					"occurred_at":  strProp,
				}, "entry_type", "amount_cents", "title"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "create_health_record",
				Description: "登记健康记录草案（需确认）。参数 hamster_id、type(daily_check|anomaly|medication|follow_up|isolation|death) 必填；可选 notes、severity(info|low|medium|high|critical)、observed_at(RFC3339)。",
				Parameters: obj(map[string]any{
					"hamster_id":  strProp,
					"type":        strProp,
					"notes":       strProp,
					"severity":   strProp,
					"observed_at": strProp,
				}, "hamster_id", "type"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "confirm_crm_reservation",
				Description: "确认预订草案（held→confirmed，需用户确认）。参数 reservation_id。",
				Parameters: obj(map[string]any{
					"reservation_id": strProp,
				}, "reservation_id"),
			},
		},
		{
			Type: "function",
			Function: ToolFunctionSchema{
				Name:        "complete_crm_handover",
				Description: "完成交付草案（scheduled→completed，会转出仓鼠，需用户确认）。参数 handover_id。",
				Parameters: obj(map[string]any{
					"handover_id": strProp,
				}, "handover_id"),
			},
		},
	}
}

func allowedToolNames() map[string]bool {
	out := map[string]bool{}
	for _, t := range ReadOnlyToolDefinitions() {
		out[t.Function.Name] = true
	}
	return out
}

func parseToolArgs(raw string) map[string]any {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return map[string]any{}
	}
	var args map[string]any
	if err := json.Unmarshal([]byte(raw), &args); err != nil {
		return map[string]any{"_raw": raw, "_parse_error": err.Error()}
	}
	if args == nil {
		return map[string]any{}
	}
	return args
}

func toolResultJSON(value any) string {
	b, err := json.Marshal(value)
	if err != nil {
		return fmt.Sprintf(`{"error":%q}`, err.Error())
	}
	s := string(b)
	if len(s) > 8000 {
		return s[:8000] + "…"
	}
	return s
}

func intArg(args map[string]any, key string, def, min, max int) int {
	v, ok := args[key]
	if !ok {
		return def
	}
	switch n := v.(type) {
	case float64:
		i := int(n)
		if i < min {
			return min
		}
		if i > max {
			return max
		}
		return i
	case int:
		if n < min {
			return min
		}
		if n > max {
			return max
		}
		return n
	default:
		return def
	}
}

func boolArg(args map[string]any, key string) bool {
	v, ok := args[key]
	if !ok {
		return false
	}
	b, _ := v.(bool)
	return b
}

func stringArg(args map[string]any, key string) string {
	v, ok := args[key]
	if !ok {
		return ""
	}
	s, _ := v.(string)
	return strings.TrimSpace(s)
}
