package httpapi

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP2MiniprogramRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/miniprogram/config", s.getMiniprogramConfig)
	mux.HandleFunc("PUT /v1/miniprogram/config", s.upsertMiniprogramConfig)
	mux.HandleFunc("GET /v1/miniprogram/releases", s.listMiniprogramReleases)
	mux.HandleFunc("POST /v1/miniprogram/releases", s.createMiniprogramRelease)
	mux.HandleFunc("POST /v1/miniprogram/releases/{release_id}/submit", s.submitMiniprogramRelease)
	mux.HandleFunc("POST /v1/miniprogram/releases/{release_id}/audit", s.auditMiniprogramRelease)
	mux.HandleFunc("POST /v1/miniprogram/releases/{release_id}/publish", s.publishMiniprogramRelease)
	mux.HandleFunc("POST /v1/miniprogram/releases/{release_id}/rollback", s.rollbackMiniprogramRelease)
}

type miniprogramConfig struct {
	ID               uuid.UUID `json:"id"`
	DisplayName      string    `json:"display_name"`
	AppID            *string   `json:"app_id,omitempty"`
	BoundPublicSlug  *string   `json:"bound_public_slug,omitempty"`
	Enabled          bool      `json:"enabled"`
	Version          int       `json:"version"`
	UpdatedAt        time.Time `json:"updated_at"`
	PipelineNote     string    `json:"pipeline_note"`
}

type miniprogramRelease struct {
	ID           uuid.UUID  `json:"id"`
	VersionLabel string     `json:"version_label"`
	Status       string     `json:"status"`
	Title        string     `json:"title"`
	Summary      *string    `json:"summary,omitempty"`
	PublicSlug   *string    `json:"public_slug,omitempty"`
	AuditNote    *string    `json:"audit_note,omitempty"`
	SubmittedAt  *time.Time `json:"submitted_at,omitempty"`
	AuditedAt    *time.Time `json:"audited_at,omitempty"`
	PublishedAt  *time.Time `json:"published_at,omitempty"`
	RolledBackAt *time.Time `json:"rolled_back_at,omitempty"`
	Version      int        `json:"version"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

type upsertMiniprogramConfigRequest struct {
	DisplayName     string  `json:"display_name"`
	AppID           *string `json:"app_id"`
	BoundPublicSlug *string `json:"bound_public_slug"`
	Enabled         *bool   `json:"enabled"`
}

type createMiniprogramReleaseRequest struct {
	VersionLabel string  `json:"version_label"`
	Title        string  `json:"title"`
	Summary      *string `json:"summary"`
	PublicSlug   *string `json:"public_slug"`
}

type auditMiniprogramReleaseRequest struct {
	Decision string  `json:"decision"` // approve | reject
	Note     *string `json:"note"`
}

func (s *Server) getMiniprogramConfig(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	item, err := s.getMiniprogramConfigRow(r.Context(), ownerID)
	if errors.Is(err, store.ErrNotFound) {
		writeJSON(w, r, http.StatusOK, map[string]any{
			"data": miniprogramConfig{
				DisplayName:  "熊舍小程序",
				Enabled:      true,
				PipelineNote: miniprogramPipelineNote(),
			},
			"meta": responseMeta(r),
		})
		return
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item.PipelineNote = miniprogramPipelineNote()
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) upsertMiniprogramConfig(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request upsertMiniprogramConfigRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "小程序配置请求体格式不正确"))
		return
	}
	name := strings.TrimSpace(request.DisplayName)
	if name == "" {
		name = "熊舍小程序"
	}
	if utf8.RuneCountInString(name) > 80 {
		writeAPIError(w, r, validationError("display_name", "名称过长"))
		return
	}
	enabled := true
	if request.Enabled != nil {
		enabled = *request.Enabled
	}
	slug := emptyToNil(request.BoundPublicSlug)
	if slug != nil {
		normalized := strings.ToLower(strings.TrimSpace(*slug))
		if normalized != "" && !publicSiteSlugRE.MatchString(normalized) {
			writeAPIError(w, r, validationError("bound_public_slug", "公开主页路径格式无效"))
			return
		}
		if normalized == "" {
			slug = nil
		} else {
			slug = &normalized
		}
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	_, err = s.Store.Pool.Exec(r.Context(), `
		INSERT INTO miniprogram_config (
			owner_id, organization_id, display_name, app_id, bound_public_slug, enabled
		) VALUES ($1,$2,$3,$4,$5,$6)
		ON CONFLICT (owner_id) DO UPDATE SET
			display_name=EXCLUDED.display_name,
			app_id=EXCLUDED.app_id,
			bound_public_slug=EXCLUDED.bound_public_slug,
			enabled=EXCLUDED.enabled,
			version=miniprogram_config.version+1,
			updated_at=now()
	`, ownerID, orgID, name, emptyToNil(request.AppID), slug, enabled)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getMiniprogramConfigRow(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item.PipelineNote = miniprogramPipelineNote()
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listMiniprogramReleases(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, version_label, status::text, title, summary, public_slug, audit_note,
			submitted_at, audited_at, published_at, rolled_back_at, version, created_at, updated_at
		FROM miniprogram_release
		WHERE owner_id=$1
		ORDER BY created_at DESC, id DESC
		LIMIT 50
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]miniprogramRelease, 0)
	for rows.Next() {
		item, err := scanMiniprogramRelease(rows)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createMiniprogramRelease(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createMiniprogramReleaseRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "版本请求体格式不正确"))
		return
	}
	label := strings.TrimSpace(request.VersionLabel)
	title := strings.TrimSpace(request.Title)
	if label == "" {
		label = fmt.Sprintf("v%d", time.Now().Unix()%100000)
	}
	if title == "" {
		title = "熊舍展示版"
	}
	if utf8.RuneCountInString(label) > 32 {
		writeAPIError(w, r, validationError("version_label", "版本号过长"))
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	// Default public_slug from config / public_site.
	slug := emptyToNil(request.PublicSlug)
	if slug == nil {
		if cfg, cfgErr := s.getMiniprogramConfigRow(r.Context(), ownerID); cfgErr == nil && cfg.BoundPublicSlug != nil {
			slug = cfg.BoundPublicSlug
		} else if site, siteErr := s.getPublicSiteByOwner(r.Context(), ownerID); siteErr == nil {
			siteSlug := site.Slug
			slug = &siteSlug
		}
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO miniprogram_release (
			owner_id, organization_id, version_label, status, title, summary, public_slug
		) VALUES ($1,$2,$3,'draft',$4,$5,$6)
		RETURNING id
	`, ownerID, orgID, label, title, emptyToNil(request.Summary), slug).Scan(&id)
	if err != nil {
		if isUniqueViolation(err) {
			writeAPIError(w, r, validationError("version_label", "版本号已存在"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getMiniprogramRelease(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) submitMiniprogramRelease(w http.ResponseWriter, r *http.Request) {
	s.transitionMiniprogramRelease(w, r, "submitted", func(current miniprogramRelease) error {
		if current.Status != "draft" && current.Status != "rejected" {
			return validationError("status", "仅草稿或已驳回可提交审核")
		}
		return nil
	}, `
		UPDATE miniprogram_release
		SET status='submitted', submitted_at=now(), audit_note=NULL,
			version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status IN ('draft','rejected')
	`)
}

func (s *Server) auditMiniprogramRelease(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	releaseID, err := uuid.Parse(r.PathValue("release_id"))
	if err != nil {
		writeAPIError(w, r, validationError("release_id", "版本 ID 无效"))
		return
	}
	var request auditMiniprogramReleaseRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "审核请求体格式不正确"))
		return
	}
	decision := strings.TrimSpace(strings.ToLower(request.Decision))
	if decision != "approve" && decision != "reject" {
		writeAPIError(w, r, validationError("decision", "decision 须为 approve 或 reject"))
		return
	}
	current, err := s.getMiniprogramRelease(r.Context(), ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if current.Status != "submitted" && current.Status != "auditing" {
		writeAPIError(w, r, validationError("status", "仅已提交/审核中可审"))
		return
	}
	next := "approved"
	if decision == "reject" {
		next = "rejected"
	}
	note := emptyToNil(request.Note)
	if note == nil {
		if decision == "approve" {
			msg := "沙箱审核通过（非真实微信审核）"
			note = &msg
		} else {
			msg := "沙箱审核驳回"
			note = &msg
		}
	}
	_, err = s.Store.Pool.Exec(r.Context(), `
		UPDATE miniprogram_release
		SET status=$3::miniprogram_release_status, audited_at=now(), audit_note=$4,
			version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status IN ('submitted','auditing')
	`, ownerID, releaseID, next, note)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getMiniprogramRelease(r.Context(), ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) publishMiniprogramRelease(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	releaseID, err := uuid.Parse(r.PathValue("release_id"))
	if err != nil {
		writeAPIError(w, r, validationError("release_id", "版本 ID 无效"))
		return
	}
	current, err := s.getMiniprogramRelease(r.Context(), ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if current.Status != "approved" {
		writeAPIError(w, r, validationError("status", "仅审核通过可发布"))
		return
	}
	tx, err := s.Store.Pool.Begin(r.Context())
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer func() { _ = tx.Rollback(r.Context()) }()
	// Demote previous published.
	_, err = tx.Exec(r.Context(), `
		UPDATE miniprogram_release
		SET status='rolled_back', rolled_back_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND status='published' AND id<>$2
	`, ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	tag, err := tx.Exec(r.Context(), `
		UPDATE miniprogram_release
		SET status='published', published_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='approved'
	`, ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() == 0 {
		writeAPIError(w, r, validationError("status", "发布失败，状态已变化"))
		return
	}
	if err := tx.Commit(r.Context()); err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getMiniprogramRelease(r.Context(), ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) rollbackMiniprogramRelease(w http.ResponseWriter, r *http.Request) {
	s.transitionMiniprogramRelease(w, r, "rolled_back", func(current miniprogramRelease) error {
		if current.Status != "published" {
			return validationError("status", "仅线上版本可回滚")
		}
		return nil
	}, `
		UPDATE miniprogram_release
		SET status='rolled_back', rolled_back_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='published'
	`)
}

func (s *Server) transitionMiniprogramRelease(
	w http.ResponseWriter,
	r *http.Request,
	_ string,
	validate func(miniprogramRelease) error,
	updateSQL string,
) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	releaseID, err := uuid.Parse(r.PathValue("release_id"))
	if err != nil {
		writeAPIError(w, r, validationError("release_id", "版本 ID 无效"))
		return
	}
	current, err := s.getMiniprogramRelease(r.Context(), ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := validate(current); err != nil {
		writeAPIError(w, r, err)
		return
	}
	tag, err := s.Store.Pool.Exec(r.Context(), updateSQL, ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() == 0 {
		writeAPIError(w, r, validationError("status", "状态已变化，请刷新"))
		return
	}
	item, err := s.getMiniprogramRelease(r.Context(), ownerID, releaseID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) getMiniprogramConfigRow(ctx context.Context, ownerID uuid.UUID) (miniprogramConfig, error) {
	var item miniprogramConfig
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, display_name, app_id, bound_public_slug, enabled, version, updated_at
		FROM miniprogram_config
		WHERE owner_id=$1
	`, ownerID).Scan(
		&item.ID, &item.DisplayName, &item.AppID, &item.BoundPublicSlug, &item.Enabled, &item.Version, &item.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return miniprogramConfig{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) getMiniprogramRelease(ctx context.Context, ownerID, id uuid.UUID) (miniprogramRelease, error) {
	row := s.Store.Pool.QueryRow(ctx, `
		SELECT id, version_label, status::text, title, summary, public_slug, audit_note,
			submitted_at, audited_at, published_at, rolled_back_at, version, created_at, updated_at
		FROM miniprogram_release
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id)
	return scanMiniprogramRelease(row)
}

type miniprogramReleaseScanner interface {
	Scan(dest ...any) error
}

func scanMiniprogramRelease(row miniprogramReleaseScanner) (miniprogramRelease, error) {
	var item miniprogramRelease
	err := row.Scan(
		&item.ID, &item.VersionLabel, &item.Status, &item.Title, &item.Summary, &item.PublicSlug, &item.AuditNote,
		&item.SubmittedAt, &item.AuditedAt, &item.PublishedAt, &item.RolledBackAt, &item.Version, &item.CreatedAt, &item.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return miniprogramRelease{}, store.ErrNotFound
	}
	return item, err
}

func miniprogramPipelineNote() string {
	return "沙箱审核链：草稿→提交→审核通过/驳回→发布→回滚。未对接真实微信开放平台。"
}
