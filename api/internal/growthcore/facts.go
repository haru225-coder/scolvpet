// Package growthcore contains the domain logic for the P0 AI growth loop.
// It deliberately works on public projections so internal hamster data cannot
// accidentally become content or visitor-facing advice.
package growthcore

import (
	"fmt"
	"sort"
	"strings"
	"unicode"
)

type PublicMedia struct {
	ID   string `json:"id,omitempty"`
	URL  string `json:"url,omitempty"`
	Kind string `json:"kind,omitempty"`
}

type PublicHamster struct {
	ID            string        `json:"hamster_id"`
	PublicName    string        `json:"public_name"`
	Summary       string        `json:"summary,omitempty"`
	Traits        []string      `json:"traits,omitempty"`
	Sex           string        `json:"sex,omitempty"`
	Variety       string        `json:"variety,omitempty"`
	BirthDate     string        `json:"birth_date,omitempty"`
	FilmingStatus string        `json:"filming_status"`
	Published     bool          `json:"published"`
	Consultable   bool          `json:"consultable"`
	CTAText       string        `json:"cta_text,omitempty"`
	PriceLabel    string        `json:"price_label,omitempty"`
	Media         []PublicMedia `json:"media,omitempty"`
}

type PublicFact struct {
	Key    string `json:"key"`
	Value  string `json:"value"`
	Source string `json:"source"`
}

func FactsForHamster(item PublicHamster) []PublicFact {
	facts := make([]PublicFact, 0, 8)
	add := func(key, value, source string) {
		if strings.TrimSpace(value) == "" {
			return
		}
		facts = append(facts, PublicFact{Key: key, Value: value, Source: source})
	}
	add("public_name", item.PublicName, "hamster_public_profile.public_name")
	add("variety", item.Variety, "hamster.variety_code.public_projection")
	add("sex", sexLabel(item.Sex), "hamster.sex.public_projection")
	add("birth_date", item.BirthDate, "hamster.birth_date.public_projection")
	add("summary", item.Summary, "hamster_public_profile.summary")
	if len(item.Traits) > 0 {
		add("traits", strings.Join(item.Traits, "、"), "hamster_public_profile.traits")
	}
	return facts
}

func FactsSnapshot(item PublicHamster) map[string]any {
	return map[string]any{
		"subject": item,
		"facts":   FactsForHamster(item),
	}
}

func BuildOpportunity(item PublicHamster) map[string]any {
	reason := "公开资料已经准备好，可以开始持续曝光。"
	if item.FilmingStatus == "ready" {
		reason = "拍摄状态为 ready，适合生成一条真实成长内容。"
	}
	if strings.TrimSpace(item.Summary) == "" || len(item.Traits) == 0 {
		reason = "建议先补充公开特点，再生成更具体的口播。"
	}
	return map[string]any{
		"kind":        "hamster_profile",
		"hamster_id":  item.ID,
		"title":       fmt.Sprintf("为%s拍一条内容", displayName(item)),
		"reason":      reason,
		"priority":    opportunityPriority(item),
		"suggestion":  "生成短视频脚本",
		"public_name": item.PublicName,
	}
}

func MatchPublicHamsters(question string, catalog []PublicHamster) []Recommendation {
	q := normalize(question)
	type scored struct {
		item  PublicHamster
		score int
	}
	items := make([]scored, 0, len(catalog))
	for _, item := range catalog {
		if !item.Published || !item.Consultable {
			continue
		}
		score := 0
		for _, token := range append([]string{item.Variety, item.PublicName, item.Summary, item.Sex}, item.Traits...) {
			if token != "" && strings.Contains(q, normalize(token)) {
				score += 3
			}
		}
		if strings.Contains(q, "新手") {
			for _, trait := range item.Traits {
				if strings.Contains(normalize(trait), "亲人") || strings.Contains(normalize(trait), "稳定") {
					score += 2
				}
			}
		}
		if score == 0 && len(items) == 0 {
			score = 1
		}
		if score > 0 {
			items = append(items, scored{item: item, score: score})
		}
	}
	sort.SliceStable(items, func(i, j int) bool {
		if items[i].score == items[j].score {
			return displayName(items[i].item) < displayName(items[j].item)
		}
		return items[i].score > items[j].score
	})
	result := make([]Recommendation, 0, len(items))
	for _, item := range items {
		result = append(result, Recommendation{
			HamsterID:  item.item.ID,
			PublicName: item.item.PublicName,
			Summary:    item.item.Summary,
			Reason:     recommendationReason(question, item.item),
			Media:      item.item.Media,
		})
	}
	if len(result) > 3 {
		result = result[:3]
	}
	return result
}

type Recommendation struct {
	HamsterID  string        `json:"hamster_id"`
	PublicName string        `json:"public_name"`
	Summary    string        `json:"summary,omitempty"`
	Reason     string        `json:"reason"`
	Media      []PublicMedia `json:"media,omitempty"`
}

type ConsultantAnswer struct {
	Answer              string           `json:"answer"`
	Recommendations     []Recommendation `json:"recommendations"`
	Facts               []PublicFact     `json:"facts"`
	HandoffSuggested    bool             `json:"handoff_suggested"`
	InterestedHamsterID string           `json:"interested_hamster_id,omitempty"`
}

func Consult(question string, catalog []PublicHamster) ConsultantAnswer {
	q := strings.TrimSpace(question)
	recommendations := MatchPublicHamsters(q, catalog)
	handoff := containsAny(q, "价格", "多少钱", "订金", "预订", "预定", "健康保证", "投诉", "退款", "付款")
	answer := "我可以根据已公开的仓鼠资料，帮你了解品种、性别、生日和公开特点。"
	if len(recommendations) > 0 {
		answer = "按当前已发布且可咨询的资料，比较匹配的是：" + recommendationNames(recommendations) + "。"
		if containsAny(q, "新手", "适合") {
			answer += "我会优先参考公开的性格特点和成长信息，具体健康与预订事项请由熊舍人工确认。"
		}
	} else if containsAny(q, "有哪些", "哪只", "推荐", "新手", "适合") {
		answer = "目前没有找到符合这句话的已发布可咨询仓鼠，可以换一个品种、性别或性格偏好再问。"
	}
	if handoff {
		answer += "这类问题需要熊舍人工确认，我可以先为你留下联系方式。"
	}
	var interested string
	if len(recommendations) > 0 {
		interested = recommendations[0].HamsterID
	}
	var facts []PublicFact
	if interested != "" {
		for _, item := range catalog {
			if item.ID == interested {
				facts = FactsForHamster(item)
				break
			}
		}
	}
	return ConsultantAnswer{
		Answer:              answer,
		Recommendations:     recommendations,
		Facts:               facts,
		HandoffSuggested:    handoff,
		InterestedHamsterID: interested,
	}
}

func normalize(value string) string {
	return strings.Map(func(r rune) rune {
		if unicode.IsSpace(r) {
			return -1
		}
		return unicode.ToLower(r)
	}, strings.TrimSpace(value))
}

func sexLabel(value string) string {
	switch value {
	case "male":
		return "公"
	case "female":
		return "母"
	case "unknown":
		return "未知"
	default:
		return value
	}
}

func displayName(item PublicHamster) string {
	if strings.TrimSpace(item.PublicName) != "" {
		return strings.TrimSpace(item.PublicName)
	}
	return "这只仓鼠"
}

func opportunityPriority(item PublicHamster) int {
	if item.FilmingStatus == "ready" && item.Consultable {
		return 100
	}
	if item.FilmingStatus == "ready" {
		return 80
	}
	return 50
}

func recommendationReason(question string, item PublicHamster) string {
	if containsAny(question, "新手", "适合") && len(item.Traits) > 0 {
		return "公开特点包含：" + strings.Join(item.Traits, "、")
	}
	if item.Variety != "" {
		return "品种为" + item.Variety + "，且当前资料已公开并接受咨询。"
	}
	return "当前公开资料已发布并接受咨询。"
}

func recommendationNames(items []Recommendation) string {
	names := make([]string, 0, len(items))
	for _, item := range items {
		if item.PublicName != "" {
			names = append(names, item.PublicName)
		}
	}
	if len(names) == 0 {
		return "符合条件的仓鼠"
	}
	return strings.Join(names, "、")
}

func containsAny(value string, keys ...string) bool {
	q := normalize(value)
	for _, key := range keys {
		if strings.Contains(q, normalize(key)) {
			return true
		}
	}
	return false
}
