package importcsv

import (
	"fmt"
	"math/big"
	"sort"
	"strconv"
	"strings"
	"time"
)

func parseTimeValue(value, timezone string) (*time.Time, error) {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil, nil
	}
	location, err := time.LoadLocation(timezone)
	if err != nil {
		return nil, fmt.Errorf("未知时区 %q", timezone)
	}
	for _, layout := range []string{time.RFC3339Nano, time.RFC3339} {
		if parsed, parseErr := time.Parse(layout, value); parseErr == nil {
			return &parsed, nil
		}
	}
	for _, layout := range []string{
		"2006-01-02 15:04:05",
		"2006-01-02 15:04",
		"2006/01/02 15:04:05",
		"2006/01/02 15:04",
		"2006-01-02",
		"2006/01/02",
		"2006.01.02",
	} {
		if parsed, parseErr := time.ParseInLocation(layout, value, location); parseErr == nil {
			return &parsed, nil
		}
	}
	return nil, fmt.Errorf("不支持的日期时间格式 %q", value)
}

func sameDate(left, right *time.Time) bool {
	if left == nil || right == nil {
		return left == nil && right == nil
	}
	leftYear, leftMonth, leftDay := left.Date()
	rightYear, rightMonth, rightDay := right.Date()
	return leftYear == rightYear && leftMonth == rightMonth && leftDay == rightDay
}

func canonicalTime(value *time.Time) string {
	if value == nil {
		return ""
	}
	return value.UTC().Format(time.RFC3339Nano)
}

func parsePositiveInt(value string, defaultValue int) (int, error) {
	value = strings.TrimSpace(value)
	if value == "" {
		return defaultValue, nil
	}
	parsed, err := strconv.Atoi(value)
	if err != nil || parsed <= 0 {
		return 0, fmt.Errorf("必须是正整数")
	}
	return parsed, nil
}

func normalizeDecimal(value string) (string, error) {
	value = strings.TrimSpace(value)
	if value == "" {
		return "", fmt.Errorf("体重为空")
	}
	if strings.HasPrefix(value, "+") {
		value = strings.TrimPrefix(value, "+")
	}
	parts := strings.Split(value, ".")
	if len(parts) > 2 || len(parts) == 2 && len(parts[1]) > 2 {
		return "", fmt.Errorf("体重最多保留两位小数")
	}
	rational, ok := new(big.Rat).SetString(value)
	if !ok || rational.Sign() <= 0 {
		return "", fmt.Errorf("体重必须是大于 0 的数字")
	}
	maximum, _ := new(big.Rat).SetString("5000")
	if rational.Cmp(maximum) > 0 {
		return "", fmt.Errorf("体重超过 OpenAPI 上限 5000g")
	}
	if len(parts) == 1 {
		return parts[0] + ".00", nil
	}
	fraction := parts[1]
	if len(fraction) == 1 {
		fraction += "0"
	}
	return parts[0] + "." + fraction, nil
}

func splitTags(value string) []string {
	parts := strings.FieldsFunc(value, func(current rune) bool {
		return current == '|' || current == ';' || current == '；' || current == ',' || current == '，'
	})
	seen := make(map[string]struct{})
	result := make([]string, 0, len(parts))
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		if _, ok := seen[part]; ok {
			continue
		}
		seen[part] = struct{}{}
		result = append(result, part)
	}
	sort.Strings(result)
	return result
}

func equalStrings(left, right []string) bool {
	leftCopy := append([]string(nil), left...)
	rightCopy := append([]string(nil), right...)
	sort.Strings(leftCopy)
	sort.Strings(rightCopy)
	if len(leftCopy) != len(rightCopy) {
		return false
	}
	for index := range leftCopy {
		if leftCopy[index] != rightCopy[index] {
			return false
		}
	}
	return true
}

func validEnum(value string, allowed ...string) bool {
	for _, candidate := range allowed {
		if value == candidate {
			return true
		}
	}
	return false
}
