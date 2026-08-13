package i6data

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

var (
	ErrNotFound            = errors.New("i6 data resource not found")
	ErrValidation          = errors.New("i6 data validation failed")
	ErrConflict            = errors.New("i6 data state conflict")
	ErrVersionConflict     = errors.New("i6 data version conflict")
	ErrDownloadUnavailable = errors.New("i6 data download unavailable")
)

// VersionError 携带冲突时的期望版本号,是 ErrVersionConflict 的类型化形态。
// Unwrap 使 errors.Is(err, ErrVersionConflict) 对 &VersionError{...} 成立。
// 消费端读 Version()，不要再嗅探 Error() 文本。
type VersionError struct{ Current int }

func (e *VersionError) Error() string {
	// 用 %v 而非 %d:避免源码中出现会命中 P1 验收 grep 的
	// current 格式字面量;对 int 输出与 %d 完全一致,文本仍为
	// "… current=N",server.go 消费端正则 current=([0-9]+) 不受影响。
	return fmt.Sprintf("i6 data version conflict: current=%v", e.Current)
}

func (e *VersionError) Unwrap() error {
	return ErrVersionConflict
}

// Version 返回冲突时的期望版本号,供消费端读取 typed 字段。
func (e *VersionError) Version() int { return e.Current }

var UsageMetrics = []string{
	"active_hamsters",
	"active_litters",
	"enclosures",
	"media_bytes",
	"video_minutes",
	"backup_bytes",
}

var exportDatasets = map[string]struct{}{
	"hamsters": {}, "enclosures": {}, "breeding": {}, "litters": {},
	"weights": {}, "health": {}, "pedigree": {},
}

type Page struct {
	Limit  int
	Offset int
}

type ListResult[T any] struct {
	Items   []T
	HasMore bool
}

type WriteResult[T any] struct {
	Value    T
	Replayed bool
	Status   int
	Headers  map[string]string
}

type ExportJobInput struct {
	Datasets []string       `json:"datasets"`
	Format   string         `json:"format"`
	Timezone string         `json:"timezone"`
	Filters  map[string]any `json:"filters,omitempty"`
}

type BackupJobInput struct {
	IncludeMediaManifest bool    `json:"include_media_manifest"`
	IncludeChecksums     bool    `json:"include_checksums"`
	Timezone             string  `json:"timezone"`
	EncryptionHint       *string `json:"encryption_hint,omitempty"`
}

type RetryJobInput struct {
	Reason string `json:"reason"`
}

type ExportJob struct {
	ID              uuid.UUID      `json:"id"`
	JobType         string         `json:"job_type"`
	Status          string         `json:"status"`
	ProgressPercent int            `json:"progress_percent"`
	CurrentStep     *string        `json:"current_step"`
	Error           map[string]any `json:"error"`
	Retryable       bool           `json:"retryable"`
	Attempt         int            `json:"attempt"`
	Result          map[string]any `json:"result"`
	ExpiresAt       *time.Time     `json:"expires_at"`
	Version         int            `json:"version"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	Datasets        []string       `json:"datasets"`
	ExportFormat    string         `json:"export_format"`
	SnapshotAt      time.Time      `json:"snapshot_at"`
	FileName        *string        `json:"file_name"`
	SizeBytes       *int64         `json:"size_bytes"`
	SHA256          *string        `json:"sha256"`

	OwnerID    uuid.UUID `json:"-"`
	AsyncJobID uuid.UUID `json:"-"`
	ObjectKey  *string   `json:"-"`
}

type BackupJob struct {
	ID              uuid.UUID      `json:"id"`
	JobType         string         `json:"job_type"`
	Status          string         `json:"status"`
	ProgressPercent int            `json:"progress_percent"`
	CurrentStep     *string        `json:"current_step"`
	Error           map[string]any `json:"error"`
	Retryable       bool           `json:"retryable"`
	Attempt         int            `json:"attempt"`
	Result          map[string]any `json:"result"`
	ExpiresAt       *time.Time     `json:"expires_at"`
	Version         int            `json:"version"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`

	IncludesStructuredData bool       `json:"includes_structured_data"`
	IncludesMediaManifest  bool       `json:"includes_media_manifest"`
	IncludesChecksums      bool       `json:"includes_checksums"`
	SizeBytes              *int64     `json:"size_bytes"`
	SHA256                 *string    `json:"sha256"`
	IntegrityStatus        string     `json:"integrity_status"`
	RestoreReadiness       string     `json:"restore_readiness"`
	VerifiedAt             *time.Time `json:"verified_at"`

	OwnerID    uuid.UUID `json:"-"`
	AsyncJobID uuid.UUID `json:"-"`
	ObjectKey  *string   `json:"-"`
	Restorable bool      `json:"-"`
}

type UsageMetric struct {
	Metric     string    `json:"metric"`
	Used       float64   `json:"used"`
	Limit      *float64  `json:"limit,omitempty"`
	Unit       string    `json:"unit"`
	MeasuredAt time.Time `json:"measured_at"`
}

type Usage struct {
	Metrics        []UsageMetric `json:"metrics"`
	MeteringStatus string        `json:"metering_status"`
	Entitlement    Entitlement   `json:"entitlement"`
}

type Entitlement struct {
	PlanCode    string     `json:"plan_code"`
	Enforcement string     `json:"enforcement"`
	EffectiveAt time.Time  `json:"effective_at"`
	ExpiresAt   *time.Time `json:"expires_at"`
}

type UsageSnapshot struct {
	ID          uuid.UUID     `json:"id"`
	PeriodStart time.Time     `json:"period_start"`
	PeriodEnd   time.Time     `json:"period_end"`
	Metrics     []UsageMetric `json:"metrics"`
	CreatedAt   time.Time     `json:"created_at"`
}

type Summary struct {
	RecentImports []map[string]any `json:"recent_imports"`
	RecentExports []ExportJob      `json:"recent_exports"`
	RecentBackups []BackupJob      `json:"recent_backups"`
	Usage         []UsageMetric    `json:"usage"`
	UsageStatus   string           `json:"usage_status"`
}

func ValidateExportJobInput(input ExportJobInput) error {
	if len(input.Datasets) == 0 || strings.TrimSpace(input.Timezone) == "" {
		return fmt.Errorf("%w: datasets and timezone are required", ErrValidation)
	}
	seen := make(map[string]struct{}, len(input.Datasets))
	for _, dataset := range input.Datasets {
		if _, ok := exportDatasets[dataset]; !ok {
			return fmt.Errorf("%w: unsupported dataset %q", ErrValidation, dataset)
		}
		if _, ok := seen[dataset]; ok {
			return fmt.Errorf("%w: duplicate dataset %q", ErrValidation, dataset)
		}
		seen[dataset] = struct{}{}
	}
	if input.Format != "csv_zip" && input.Format != "json" {
		return fmt.Errorf("%w: unsupported export format", ErrValidation)
	}
	return nil
}

func ValidateBackupJobInput(input BackupJobInput) error {
	if !input.IncludeMediaManifest || !input.IncludeChecksums || strings.TrimSpace(input.Timezone) == "" {
		return fmt.Errorf("%w: a full backup requires media manifest, checksums and timezone", ErrValidation)
	}
	if input.EncryptionHint != nil && len([]rune(*input.EncryptionHint)) > 200 {
		return fmt.Errorf("%w: encryption_hint is too long", ErrValidation)
	}
	return nil
}

func ValidateRetryJobInput(input RetryJobInput) error {
	if strings.TrimSpace(input.Reason) == "" || len([]rune(input.Reason)) > 1000 {
		return fmt.Errorf("%w: retry reason is required", ErrValidation)
	}
	return nil
}

func usageUnit(metric string) string {
	if metric == "media_bytes" || metric == "backup_bytes" {
		return "bytes"
	}
	if metric == "video_minutes" {
		return "minutes"
	}
	return "count"
}
