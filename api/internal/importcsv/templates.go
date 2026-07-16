package importcsv

import (
	"fmt"
	"strings"
	"unicode"
)

var templateDefinitions = map[TemplateType]Template{
	TemplateHamster: {
		Type: TemplateHamster,
		Fields: []FieldDefinition{
			{Name: "internal_code", Required: true, Core: true, Aliases: []string{"internal_code", "hamster_code", "编号", "内部编号", "仓鼠编号"}},
			{Name: "name", Aliases: []string{"name", "nickname", "昵称", "名称"}},
			{Name: "species_rule_version_id", Core: true, Aliases: []string{"species_rule_version_id", "rule_version_id", "物种规则版本"}},
			{Name: "variety_code", Aliases: []string{"variety_code", "variety", "品系", "品种"}},
			{Name: "sex", Core: true, Aliases: []string{"sex", "gender", "性别"}},
			{Name: "born_at", Core: true, Aliases: []string{"born_at", "birth_date", "birthday", "出生日期", "出生时间"}},
			{Name: "source_type", Core: true, Aliases: []string{"source_type", "source", "来源类型", "来源"}},
			{Name: "lifecycle_status", Core: true, Aliases: []string{"lifecycle_status", "status", "生命周期", "个体状态"}},
			{Name: "breeding_status", Core: true, Aliases: []string{"breeding_status", "繁育状态"}},
			{Name: "litter_code", Core: true, Aliases: []string{"litter_code", "litter", "窝次编号", "窝号"}},
			{Name: "sire_code", Core: true, Aliases: []string{"sire_code", "father_code", "父本编号", "父亲编号"}},
			{Name: "dam_code", Core: true, Aliases: []string{"dam_code", "mother_code", "母本编号", "母亲编号"}},
			{Name: "enclosure_code", Core: true, Aliases: []string{"enclosure_code", "cage_code", "笼盒编号", "笼位编号"}},
			{Name: "enclosure_started_at", Core: true, Aliases: []string{"enclosure_started_at", "stay_started_at", "入住时间"}},
			{Name: "tags", Aliases: []string{"tags", "标签"}},
			{Name: "notes", Aliases: []string{"notes", "remark", "备注"}},
		},
	},
	TemplateEnclosure: {
		Type: TemplateEnclosure,
		Fields: []FieldDefinition{
			{Name: "code", Required: true, Core: true, Aliases: []string{"code", "enclosure_code", "cage_code", "编号", "笼盒编号", "笼位编号"}},
			{Name: "rack_code", Aliases: []string{"rack_code", "rack", "笼架编号", "笼架"}},
			{Name: "level_code", Aliases: []string{"level_code", "level", "层位编号", "层位"}},
			{Name: "capacity", Core: true, Aliases: []string{"capacity", "容量"}},
			{Name: "state", Core: true, Aliases: []string{"state", "status", "笼盒状态"}},
			{Name: "cleanliness", Aliases: []string{"cleanliness", "cleanliness_state", "清洁状态"}},
			{Name: "last_cleaned_at", Aliases: []string{"last_cleaned_at", "最近清洁时间"}},
			{Name: "disabled_reason", Aliases: []string{"disabled_reason", "停用原因"}},
		},
	},
	TemplateWeight: {
		Type: TemplateWeight,
		Fields: []FieldDefinition{
			{Name: "subject_type", Core: true, Aliases: []string{"subject_type", "称重对象类型", "对象类型"}},
			{Name: "hamster_code", Core: true, Aliases: []string{"hamster_code", "internal_code", "仓鼠编号", "内部编号"}},
			{Name: "litter_code", Core: true, Aliases: []string{"litter_code", "窝次编号", "窝号"}},
			{Name: "measurement_kind", Core: true, Aliases: []string{"measurement_kind", "称重方式", "计量方式"}},
			{Name: "subject_count", Core: true, Aliases: []string{"subject_count", "个体数量", "只数"}},
			{Name: "weight_g", Required: true, Core: true, Aliases: []string{"weight_g", "weight_grams", "weight", "体重克", "体重"}},
			{Name: "recorded_at", Required: true, Core: true, Aliases: []string{"recorded_at", "measured_at", "称重时间", "记录时间"}},
			{Name: "acquisition_key", Core: true, Aliases: []string{"acquisition_key", "采集编号", "幂等键"}},
		},
	},
}

func Templates() []Template {
	return []Template{
		cloneTemplate(templateDefinitions[TemplateHamster]),
		cloneTemplate(templateDefinitions[TemplateEnclosure]),
		cloneTemplate(templateDefinitions[TemplateWeight]),
	}
}

func TemplateFor(kind TemplateType) (Template, bool) {
	template, ok := templateDefinitions[kind]
	if !ok {
		return Template{}, false
	}
	return cloneTemplate(template), true
}

func cloneTemplate(template Template) Template {
	cloned := template
	cloned.Fields = append([]FieldDefinition(nil), template.Fields...)
	for index := range cloned.Fields {
		cloned.Fields[index].Aliases = append([]string(nil), template.Fields[index].Aliases...)
	}
	return cloned
}

func normalizeColumn(value string) string {
	value = strings.TrimSpace(strings.TrimPrefix(value, "\ufeff"))
	value = strings.ToLower(value)
	var builder strings.Builder
	lastUnderscore := false
	for _, current := range value {
		switch {
		case unicode.IsSpace(current), current == '-', current == '.', current == '/':
			if !lastUnderscore {
				builder.WriteByte('_')
				lastUnderscore = true
			}
		default:
			builder.WriteRune(current)
			lastUnderscore = current == '_'
		}
	}
	return strings.Trim(builder.String(), "_")
}

func aliasIndex(template Template) map[string]string {
	result := make(map[string]string)
	for _, field := range template.Fields {
		result[normalizeColumn(field.Name)] = field.Name
		for _, alias := range field.Aliases {
			result[normalizeColumn(alias)] = field.Name
		}
	}
	return result
}

func fieldIndex(template Template) map[string]FieldDefinition {
	result := make(map[string]FieldDefinition, len(template.Fields))
	for _, field := range template.Fields {
		result[field.Name] = field
	}
	return result
}

func detectTemplate(headers []string) (TemplateType, error) {
	type candidate struct {
		kind  TemplateType
		score int
	}
	candidates := make([]candidate, 0, len(templateDefinitions))
	for _, template := range Templates() {
		aliases := aliasIndex(template)
		seen := make(map[string]struct{})
		score := 0
		for _, header := range headers {
			if field, ok := aliases[normalizeColumn(header)]; ok {
				if _, duplicate := seen[field]; !duplicate {
					seen[field] = struct{}{}
					score += 10
				}
			}
		}
		for _, field := range template.Fields {
			if field.Required {
				if _, ok := seen[field.Name]; ok {
					score += 25
				} else {
					score -= 20
				}
			}
		}
		candidates = append(candidates, candidate{kind: template.Type, score: score})
	}
	best := candidate{score: -1 << 30}
	tied := false
	for _, current := range candidates {
		if current.score > best.score {
			best = current
			tied = false
		} else if current.score == best.score {
			tied = true
		}
	}
	if best.score <= 0 || tied {
		return "", fmt.Errorf("无法从表头唯一识别 CSV 模板")
	}
	return best.kind, nil
}
