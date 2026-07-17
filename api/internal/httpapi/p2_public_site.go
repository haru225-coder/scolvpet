package httpapi

import (
	"context"
	"errors"
	"net/http"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

// 1–64 chars: start/end alphanumeric; hyphens allowed in the middle.
var publicSiteSlugRE = regexp.MustCompile(`^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$`)

func (s *Server) registerP2PublicSiteRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/public-site", s.getOwnerPublicSite)
	mux.HandleFunc("PUT /v1/public-site", s.upsertOwnerPublicSite)
	mux.HandleFunc("POST /v1/public-site/publish", s.publishOwnerPublicSite)
	mux.HandleFunc("POST /v1/public-site/unpublish", s.unpublishOwnerPublicSite)
	// Unauthenticated public projection (same pattern as /v1/public/shares/{token}).
	mux.HandleFunc("GET /v1/public/sites/{slug}", s.getPublicSiteBySlug)
}

type publicSite struct {
	ID            uuid.UUID  `json:"id"`
	Slug          string     `json:"slug"`
	Title         string     `json:"title"`
	Tagline       *string    `json:"tagline,omitempty"`
	About         *string    `json:"about,omitempty"`
	ContactWechat *string    `json:"contact_wechat,omitempty"`
	ContactPhone  *string    `json:"contact_phone,omitempty"`
	ThemeColor    string     `json:"theme_color"`
	ShowStats     bool       `json:"show_stats"`
	ShowContact   bool       `json:"show_contact"`
	Published     bool       `json:"published"`
	PublishedAt   *time.Time `json:"published_at,omitempty"`
	Version       int        `json:"version"`
	UpdatedAt     time.Time  `json:"updated_at"`
	PublicURLPath string     `json:"public_url_path"`
}

type publicSiteView struct {
	Slug          string         `json:"slug"`
	Title         string         `json:"title"`
	Tagline       *string        `json:"tagline,omitempty"`
	About         *string        `json:"about,omitempty"`
	ThemeColor    string         `json:"theme_color"`
	ContactWechat *string        `json:"contact_wechat,omitempty"`
	ContactPhone  *string        `json:"contact_phone,omitempty"`
	Stats         map[string]any `json:"stats,omitempty"`
	Organization  string         `json:"organization_name,omitempty"`
	PublishedAt   *time.Time     `json:"published_at,omitempty"`
}

type upsertPublicSiteRequest struct {
	Slug          string  `json:"slug"`
	Title         string  `json:"title"`
	Tagline       *string `json:"tagline"`
	About         *string `json:"about"`
	ContactWechat *string `json:"contact_wechat"`
	ContactPhone  *string `json:"contact_phone"`
	ThemeColor    string  `json:"theme_color"`
	ShowStats     *bool   `json:"show_stats"`
	ShowContact   *bool   `json:"show_contact"`
}

func (s *Server) getOwnerPublicSite(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	item, err := s.getPublicSiteByOwner(r.Context(), ownerID)
	if errors.Is(err, store.ErrNotFound) {
		// Empty draft shell so client can edit without 404 noise.
		orgName := ""
		if org, orgErr := s.Store.GetCurrentOrganization(r.Context(), ownerID); orgErr == nil {
			orgName = org.Name
		}
		slug := defaultPublicSlug(orgName, ownerID)
		writeJSON(w, r, http.StatusOK, map[string]any{
			"data": publicSite{
				Slug:          slug,
				Title:         firstNonEmpty(orgName, "我的熊舍"),
				ThemeColor:    "#c77852",
				ShowStats:     true,
				ShowContact:   true,
				Published:     false,
				PublicURLPath: "/v1/public/sites/" + slug,
			},
			"meta": responseMeta(r),
		})
		return
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) upsertOwnerPublicSite(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request upsertPublicSiteRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "公开主页请求体格式不正确"))
		return
	}
	slug := strings.ToLower(strings.TrimSpace(request.Slug))
	title := strings.TrimSpace(request.Title)
	if slug == "" {
		writeAPIError(w, r, validationError("slug", "访问路径必填"))
		return
	}
	if !publicSiteSlugRE.MatchString(slug) {
		writeAPIError(w, r, validationError("slug", "路径仅限小写字母、数字与连字符，2–64 位"))
		return
	}
	if title == "" {
		writeAPIError(w, r, validationError("title", "标题必填"))
		return
	}
	if utf8.RuneCountInString(title) > 120 {
		writeAPIError(w, r, validationError("title", "标题过长"))
		return
	}
	theme := strings.TrimSpace(request.ThemeColor)
	if theme == "" {
		theme = "#c77852"
	}
	if matched, _ := regexp.MatchString(`^#[0-9A-Fa-f]{6}$`, theme); !matched {
		writeAPIError(w, r, validationError("theme_color", "主题色须为 #RRGGBB"))
		return
	}
	showStats := true
	if request.ShowStats != nil {
		showStats = *request.ShowStats
	}
	showContact := true
	if request.ShowContact != nil {
		showContact = *request.ShowContact
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	// Slug conflict with another owner.
	var otherOwner uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT owner_id FROM public_site WHERE slug=$1 AND owner_id<>$2 LIMIT 1
	`, slug, ownerID).Scan(&otherOwner)
	if err == nil {
		writeAPIError(w, r, validationError("slug", "该访问路径已被占用"))
		return
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		writeAPIError(w, r, err)
		return
	}

	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO public_site (
			owner_id, organization_id, slug, title, tagline, about,
			contact_wechat, contact_phone, theme_color, show_stats, show_contact
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
		ON CONFLICT (owner_id) DO UPDATE SET
			slug=EXCLUDED.slug,
			title=EXCLUDED.title,
			tagline=EXCLUDED.tagline,
			about=EXCLUDED.about,
			contact_wechat=EXCLUDED.contact_wechat,
			contact_phone=EXCLUDED.contact_phone,
			theme_color=EXCLUDED.theme_color,
			show_stats=EXCLUDED.show_stats,
			show_contact=EXCLUDED.show_contact,
			version=public_site.version+1,
			updated_at=now()
		RETURNING id
	`, ownerID, orgID, slug, title,
		emptyToNil(request.Tagline), emptyToNil(request.About),
		emptyToNil(request.ContactWechat), emptyToNil(request.ContactPhone),
		theme, showStats, showContact,
	).Scan(&id)
	if err != nil {
		if isUniqueViolation(err) {
			writeAPIError(w, r, validationError("slug", "该访问路径已被占用"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getPublicSiteByOwner(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) publishOwnerPublicSite(w http.ResponseWriter, r *http.Request) {
	s.setPublicSitePublished(w, r, true)
}

func (s *Server) unpublishOwnerPublicSite(w http.ResponseWriter, r *http.Request) {
	s.setPublicSitePublished(w, r, false)
}

func (s *Server) setPublicSitePublished(w http.ResponseWriter, r *http.Request, published bool) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	current, err := s.getPublicSiteByOwner(r.Context(), ownerID)
	if err != nil {
		if errors.Is(err, store.ErrNotFound) {
			writeAPIError(w, r, validationError("site", "请先保存公开主页再发布"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	if published {
		if strings.TrimSpace(current.Title) == "" || strings.TrimSpace(current.Slug) == "" {
			writeAPIError(w, r, validationError("site", "标题与路径不能为空"))
			return
		}
		_, err = s.Store.Pool.Exec(r.Context(), `
			UPDATE public_site
			SET published=true, published_at=COALESCE(published_at, now()),
				version=version+1, updated_at=now()
			WHERE owner_id=$1
		`, ownerID)
	} else {
		_, err = s.Store.Pool.Exec(r.Context(), `
			UPDATE public_site
			SET published=false, published_at=NULL, version=version+1, updated_at=now()
			WHERE owner_id=$1
		`, ownerID)
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getPublicSiteByOwner(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) getPublicSiteBySlug(w http.ResponseWriter, r *http.Request) {
	slug := strings.ToLower(strings.TrimSpace(r.PathValue("slug")))
	if slug == "" || !publicSiteSlugRE.MatchString(slug) {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	var ownerID uuid.UUID
	var item publicSite
	var orgName string
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT s.owner_id, s.id, s.slug, s.title, s.tagline, s.about, s.contact_wechat, s.contact_phone,
			s.theme_color, s.show_stats, s.show_contact, s.published, s.published_at, s.version, s.updated_at,
			COALESCE(o.name, '')
		FROM public_site s
		LEFT JOIN organization o ON o.owner_id=s.owner_id AND o.id=s.organization_id
		WHERE s.slug=$1 AND s.published=true
	`, slug).Scan(
		&ownerID, &item.ID, &item.Slug, &item.Title, &item.Tagline, &item.About, &item.ContactWechat, &item.ContactPhone,
		&item.ThemeColor, &item.ShowStats, &item.ShowContact, &item.Published, &item.PublishedAt, &item.Version, &item.UpdatedAt,
		&orgName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, err)
		return
	}
	view := publicSiteView{
		Slug:       item.Slug,
		Title:      item.Title,
		Tagline:    item.Tagline,
		About:      item.About,
		ThemeColor: item.ThemeColor,
		Organization: orgName,
		PublishedAt:  item.PublishedAt,
	}
	if item.ShowContact {
		view.ContactWechat = item.ContactWechat
		view.ContactPhone = item.ContactPhone
	}
	if item.ShowStats {
		stats, statsErr := s.publicSiteStats(r.Context(), ownerID)
		if statsErr == nil {
			view.Stats = stats
		}
	}
	w.Header().Set("Cache-Control", "public, max-age=30")
	writeJSON(w, r, http.StatusOK, map[string]any{"data": view, "meta": responseMeta(r)})
}

func (s *Server) getPublicSiteByOwner(ctx context.Context, ownerID uuid.UUID) (publicSite, error) {
	var item publicSite
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, slug, title, tagline, about, contact_wechat, contact_phone,
			theme_color, show_stats, show_contact, published, published_at, version, updated_at
		FROM public_site
		WHERE owner_id=$1
	`, ownerID).Scan(
		&item.ID, &item.Slug, &item.Title, &item.Tagline, &item.About, &item.ContactWechat, &item.ContactPhone,
		&item.ThemeColor, &item.ShowStats, &item.ShowContact, &item.Published, &item.PublishedAt, &item.Version, &item.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return publicSite{}, store.ErrNotFound
	}
	if err != nil {
		return publicSite{}, err
	}
	item.PublicURLPath = "/v1/public/sites/" + item.Slug
	return item, nil
}

func (s *Server) publicSiteStats(ctx context.Context, ownerID uuid.UUID) (map[string]any, error) {
	// Prefer usage_meter when available; fall back to live counts.
	stats := map[string]any{}
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT metric::text, current_value::float8
		FROM usage_meter
		WHERE owner_id=$1 AND metric IN ('active_hamsters','active_litters','enclosures')
	`, ownerID)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var metric string
			var value float64
			if scanErr := rows.Scan(&metric, &value); scanErr == nil {
				stats[metric] = int64(value)
			}
		}
	}
	if len(stats) > 0 {
		return stats, nil
	}
	var hamsters, litters, enclosures int64
	_ = s.Store.Pool.QueryRow(ctx, `
		SELECT
			(SELECT count(*) FROM hamster WHERE owner_id=$1 AND deleted_at IS NULL),
			(SELECT count(*) FROM litter WHERE owner_id=$1 AND deleted_at IS NULL),
			(SELECT count(*) FROM enclosure WHERE owner_id=$1 AND deleted_at IS NULL)
	`, ownerID).Scan(&hamsters, &litters, &enclosures)
	return map[string]any{
		"active_hamsters": hamsters,
		"active_litters":  litters,
		"enclosures":      enclosures,
	}, nil
}

func defaultPublicSlug(orgName string, ownerID uuid.UUID) string {
	base := strings.ToLower(strings.TrimSpace(orgName))
	base = strings.ReplaceAll(base, " ", "-")
	var b strings.Builder
	for _, r := range base {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') || r == '-' {
			b.WriteRune(r)
		}
	}
	slug := b.String()
	slug = strings.Trim(slug, "-")
	if len(slug) < 2 {
		// Fallback to owner prefix.
		id := strings.ReplaceAll(ownerID.String(), "-", "")
		if len(id) > 8 {
			id = id[:8]
		}
		slug = "cattery-" + id
	}
	if len(slug) > 64 {
		slug = slug[:64]
		slug = strings.Trim(slug, "-")
	}
	if !publicSiteSlugRE.MatchString(slug) {
		id := strings.ReplaceAll(ownerID.String(), "-", "")
		slug = "cattery-" + id[:8]
	}
	return slug
}

func firstNonEmpty(values ...string) string {
	for _, v := range values {
		if strings.TrimSpace(v) != "" {
			return strings.TrimSpace(v)
		}
	}
	return ""
}
