// Package entitlementcore evaluates plan limits and feature flags (T-P1-08).
package entitlementcore

import (
	"strings"
	"time"
)

// Plan codes.
const (
	PlanFree = "free"
	PlanPro  = "pro"
)

// Enforcement modes.
const (
	EnforcementNone = "none" // never block
	EnforcementSoft = "soft" // warn / UI paywall only
	EnforcementHard = "hard" // API may reject (reserved)
)

// Feature codes used by client/API checks.
const (
	FeatureGeneticSimulator = "feature.genetic_simulator"
	FeatureServerPush       = "feature.server_push"
	FeatureAdvancedExport   = "feature.advanced_export"
	FeatureUnlimitedMedia   = "feature.unlimited_media"
)

// Limit codes map to usage_metric names with prefix "limit.".
const (
	LimitActiveHamsters = "limit.active_hamsters"
	LimitActiveLitters  = "limit.active_litters"
	LimitEnclosures     = "limit.enclosures"
	LimitMediaBytes     = "limit.media_bytes"
)

// Feature describes a boolean capability.
type Feature struct {
	Code        string `json:"code"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Allowed     bool   `json:"allowed"`
}

// Limit describes a numeric cap.
type Limit struct {
	Code      string   `json:"code"`
	Metric    string   `json:"metric"`
	Title     string   `json:"title"`
	Limit     *float64 `json:"limit,omitempty"` // nil = unlimited
	Used      float64  `json:"used"`
	Remaining *float64 `json:"remaining,omitempty"`
	Over      bool     `json:"over"`
	Unit      string   `json:"unit"`
}

// PlanCatalogEntry is static marketing + default values.
type PlanCatalogEntry struct {
	Code         string             `json:"code"`
	Title        string             `json:"title"`
	Description  string             `json:"description"`
	PriceHint    string             `json:"price_hint"`
	Features     map[string]bool    `json:"features"`
	Limits       map[string]float64 `json:"limits"` // metric -> limit; omit unlimited
	Enforcement  string             `json:"enforcement"`
	Highlight    bool               `json:"highlight,omitempty"`
}

// Snapshot is the evaluated entitlement state for an owner.
type Snapshot struct {
	PlanCode    string     `json:"plan_code"`
	PlanTitle   string     `json:"plan_title"`
	Enforcement string     `json:"enforcement"`
	Source      string     `json:"source"`
	EffectiveAt time.Time  `json:"effective_at"`
	ExpiresAt   *time.Time `json:"expires_at,omitempty"`
	Features    []Feature  `json:"features"`
	Limits      []Limit    `json:"limits"`
	OverLimit   bool       `json:"over_limit"`
	PaywallHint string     `json:"paywall_hint,omitempty"`
}

// CheckResult is the response for feature/limit checks.
type CheckResult struct {
	Allowed     bool    `json:"allowed"`
	Enforcement string  `json:"enforcement"`
	PlanCode    string  `json:"plan_code"`
	Reason      string  `json:"reason,omitempty"`
	Feature     string  `json:"feature,omitempty"`
	Metric      string  `json:"metric,omitempty"`
	Used        float64 `json:"used,omitempty"`
	Limit       *float64 `json:"limit,omitempty"`
}

// DefaultCatalog free + pro (StoreKit prices TBD for CN).
func DefaultCatalog() []PlanCatalogEntry {
	return []PlanCatalogEntry{
		{
			Code:        PlanFree,
			Title:       "免费版",
			Description: "单舍日常管理与基础数据中心",
			PriceHint:   "免费",
			Enforcement: EnforcementSoft,
			Features: map[string]bool{
				FeatureGeneticSimulator: true,
				FeatureServerPush:       true,
				FeatureAdvancedExport:   false,
				FeatureUnlimitedMedia:   false,
			},
			Limits: map[string]float64{
				"active_hamsters": 30,
				"active_litters":  15,
				"enclosures":      25,
				"media_bytes":     200 * 1024 * 1024, // 200 MiB
			},
		},
		{
			Code:        PlanPro,
			Title:       "专业版",
			Description: "更高用量与高级导出；适合扩繁",
			PriceHint:   "沙箱可激活 · 正式支付另接",
			Enforcement: EnforcementSoft,
			Highlight:   true,
			Features: map[string]bool{
				FeatureGeneticSimulator: true,
				FeatureServerPush:       true,
				FeatureAdvancedExport:   true,
				FeatureUnlimitedMedia:   true,
			},
			Limits: map[string]float64{
				"active_hamsters": 500,
				"active_litters":  200,
				"enclosures":      300,
				// media unlimited → omit
			},
		},
	}
}

func CatalogByCode(code string) (PlanCatalogEntry, bool) {
	code = strings.TrimSpace(code)
	if code == "" {
		code = PlanFree
	}
	for _, p := range DefaultCatalog() {
		if p.Code == code {
			return p, true
		}
	}
	return PlanCatalogEntry{}, false
}

func FeatureTitle(code string) string {
	if p, ok := CatalogByCode(code); ok {
		return p.Title
	}
	return code
}

// BuildSnapshot merges plan defaults, stored overrides, and current usage meters.
func BuildSnapshot(planCode, source string, effectiveAt time.Time, expiresAt *time.Time, usage map[string]float64, featureOverrides map[string]bool, limitOverrides map[string]*float64) Snapshot {
	plan, ok := CatalogByCode(planCode)
	if !ok {
		plan, _ = CatalogByCode(PlanFree)
		planCode = PlanFree
	}
	if source == "" {
		source = "system"
	}
	if effectiveAt.IsZero() {
		effectiveAt = time.Now().UTC()
	}

	features := []Feature{
		{Code: FeatureGeneticSimulator, Title: "遗传模拟", Description: "A/B/C 配对概率"},
		{Code: FeatureServerPush, Title: "服务端推送", Description: "设备令牌与测试推送"},
		{Code: FeatureAdvancedExport, Title: "高级导出", Description: "扩展数据集导出"},
		{Code: FeatureUnlimitedMedia, Title: "媒体扩容", Description: "更高媒体存储上限"},
	}
	for i := range features {
		allowed, exists := plan.Features[features[i].Code]
		if !exists {
			allowed = false
		}
		if ov, ok := featureOverrides[features[i].Code]; ok {
			allowed = ov
		}
		features[i].Allowed = allowed
	}

	limitDefs := []struct {
		metric string
		title  string
		unit   string
	}{
		{"active_hamsters", "在养仓鼠", "count"},
		{"active_litters", "活跃窝次", "count"},
		{"enclosures", "笼盒", "count"},
		{"media_bytes", "媒体占用", "bytes"},
		{"video_minutes", "视频分钟", "minutes"},
		{"backup_bytes", "备份占用", "bytes"},
	}
	limits := make([]Limit, 0, len(limitDefs))
	overAny := false
	for _, def := range limitDefs {
		used := usage[def.metric]
		var lim *float64
		if ov, ok := limitOverrides[def.metric]; ok {
			lim = ov
		} else if v, ok := plan.Limits[def.metric]; ok {
			cp := v
			lim = &cp
		}
		item := Limit{
			Code:   "limit." + def.metric,
			Metric: def.metric,
			Title:  def.title,
			Limit:  lim,
			Used:   used,
			Unit:   def.unit,
		}
		if lim != nil {
			rem := *lim - used
			item.Remaining = &rem
			if used > *lim {
				item.Over = true
				overAny = true
			}
		}
		limits = append(limits, item)
	}

	hint := ""
	if overAny {
		hint = "部分用量已超过当前套餐建议上限，可升级专业版。"
	} else if planCode == PlanFree {
		hint = "免费版可完整使用核心繁育流程；扩繁可升级专业版。"
	}

	return Snapshot{
		PlanCode:    planCode,
		PlanTitle:   plan.Title,
		Enforcement: plan.Enforcement,
		Source:      source,
		EffectiveAt: effectiveAt,
		ExpiresAt:   expiresAt,
		Features:    features,
		Limits:      limits,
		OverLimit:   overAny,
		PaywallHint: hint,
	}
}

// CheckFeature evaluates a feature flag under current enforcement.
func CheckFeature(snap Snapshot, feature string) CheckResult {
	feature = strings.TrimSpace(feature)
	for _, f := range snap.Features {
		if f.Code == feature {
			if f.Allowed {
				return CheckResult{
					Allowed: true, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode, Feature: feature,
				}
			}
			// Soft enforcement never hard-blocks API; client shows paywall.
			allowed := snap.Enforcement == EnforcementNone
			reason := "当前套餐未包含该能力"
			if snap.Enforcement == EnforcementSoft {
				allowed = true // soft: allow but reason signals upgrade
				reason = "软门禁：建议升级以正式启用"
			}
			if snap.Enforcement == EnforcementHard {
				allowed = false
			}
			return CheckResult{
				Allowed: allowed, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode,
				Feature: feature, Reason: reason,
			}
		}
	}
	return CheckResult{
		Allowed: false, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode,
		Feature: feature, Reason: "未知功能码",
	}
}

// CheckMetric evaluates usage against limit.
func CheckMetric(snap Snapshot, metric string) CheckResult {
	metric = strings.TrimSpace(metric)
	for _, lim := range snap.Limits {
		if lim.Metric != metric {
			continue
		}
		if lim.Limit == nil {
			return CheckResult{
				Allowed: true, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode,
				Metric: metric, Used: lim.Used,
			}
		}
		if !lim.Over {
			return CheckResult{
				Allowed: true, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode,
				Metric: metric, Used: lim.Used, Limit: lim.Limit,
			}
		}
		allowed := snap.Enforcement != EnforcementHard
		reason := "已超过套餐建议上限"
		if snap.Enforcement == EnforcementSoft {
			reason = "软门禁：已超限，可继续使用但建议升级"
		}
		return CheckResult{
			Allowed: allowed, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode,
			Metric: metric, Used: lim.Used, Limit: lim.Limit, Reason: reason,
		}
	}
	return CheckResult{
		Allowed: true, Enforcement: snap.Enforcement, PlanCode: snap.PlanCode,
		Metric: metric, Reason: "无限额定义",
	}
}

// PlanCodeEntitlement is the stored entitlement row key for plan membership.
const PlanCodeEntitlement = "plan.code"
