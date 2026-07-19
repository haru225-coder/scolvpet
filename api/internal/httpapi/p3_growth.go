package httpapi

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/growthcore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP3GrowthRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/growth/public-hamsters", s.listGrowthPublicHamsters)
	mux.HandleFunc("PUT /v1/growth/public-hamsters/{hamster_id}", s.upsertGrowthPublicHamster)
	mux.HandleFunc("GET /v1/growth/opportunities", s.listGrowthOpportunities)
	mux.HandleFunc("GET /v1/growth/campaigns", s.listGrowthCampaigns)
	mux.HandleFunc("POST /v1/growth/campaigns/generate", s.generateGrowthCampaign)
	mux.HandleFunc("GET /v1/growth/campaigns/{campaign_id}", s.handleGetGrowthCampaign)
	mux.HandleFunc("POST /v1/growth/campaigns/{campaign_id}/publish", s.publishGrowthCampaign)
	mux.HandleFunc("POST /v1/growth/campaigns/{campaign_id}/archive", s.archiveGrowthCampaign)
	mux.HandleFunc("GET /v1/growth/leads", s.listGrowthLeads)

	mux.HandleFunc("GET /v1/public/sites/{slug}/catalog", s.getGrowthPublicCatalog)
	mux.HandleFunc("GET /v1/public/sites/{slug}/media/{media_id}", s.getGrowthPublicMedia)
	mux.HandleFunc("POST /v1/public/sites/{slug}/consult", s.postGrowthPublicConsultation)
	mux.HandleFunc("POST /v1/public/sites/{slug}/leads", s.postGrowthPublicLead)
}

type growthProfileRequest struct {
	PublicName    *string  `json:"public_name"`
	Summary       *string  `json:"summary"`
	Traits        []string `json:"traits"`
	FilmingStatus string   `json:"filming_status"`
	Published     bool     `json:"published"`
	Consultable   bool     `json:"consultable"`
	CTAText       *string  `json:"cta_text"`
	PriceLabel    *string  `json:"price_label"`
}

type growthGenerateRequest struct {
	CampaignType    string `json:"campaign_type"`
	Platform        string `json:"platform"`
	Goal            string `json:"goal"`
	DurationSeconds *int   `json:"duration_seconds"`
	Tone            string `json:"tone"`
	CTA             string `json:"cta"`
	HamsterID       string `json:"hamster_id"`
}

type growthPublicConsultRequest struct {
	Message             string `json:"message"`
	SessionToken        string `json:"session_token"`
	CampaignCode        string `json:"campaign_code"`
	InterestedHamsterID string `json:"interested_hamster_id"`
	LandingPath         string `json:"landing_path"`
}

type growthPublicLeadRequest struct {
	Name                string `json:"name"`
	Phone               string `json:"phone"`
	Wechat              string `json:"wechat"`
	CampaignCode        string `json:"campaign_code"`
	ConsultationToken   string `json:"consultation_token"`
	InterestedHamsterID string `json:"interested_hamster_id"`
	IntentSummary       string `json:"intent_summary"`
	LandingPath         string `json:"landing_path"`
}

func (s *Server) listGrowthPublicHamsters(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	items, err := s.loadGrowthPublicHamsters(r.Context(), ownerID, false)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, items))
}

func (s *Server) upsertGrowthPublicHamster(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	hamsterID, err := uuid.Parse(strings.TrimSpace(r.PathValue("hamster_id")))
	if err != nil || hamsterID == uuid.Nil {
		writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
		return
	}
	var request growthProfileRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeAPIError(w, r, validationError("body", "公开仓鼠资料格式不正确"))
		return
	}
	request.FilmingStatus = strings.TrimSpace(request.FilmingStatus)
	if request.FilmingStatus == "" {
		request.FilmingStatus = "rest"
	}
	if request.FilmingStatus != "ready" && request.FilmingStatus != "rest" && request.FilmingStatus != "restricted" {
		writeAPIError(w, r, validationError("filming_status", "拍摄状态无效"))
		return
	}
	if request.Consultable && !request.Published {
		writeAPIError(w, r, validationError("consultable", "接受咨询前必须先公开资料"))
		return
	}
	if len(request.Traits) > 12 {
		writeAPIError(w, r, validationError("traits", "特点最多 12 项"))
		return
	}
	for index := range request.Traits {
		request.Traits[index] = strings.TrimSpace(request.Traits[index])
		if utf8.RuneCountInString(request.Traits[index]) > 40 {
			writeAPIError(w, r, validationError("traits", "特点过长"))
			return
		}
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := s.ensureGrowthHamsterOwner(r.Context(), ownerID, hamsterID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPut, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		traits, _ := json.Marshal(request.Traits)
		var id uuid.UUID
		err := tx.QueryRow(ctx, `
			INSERT INTO hamster_public_profile (
				owner_id, organization_id, hamster_id, public_name, summary, traits,
				filming_status, published, consultable, cta_text, price_label
			) VALUES ($1,$2,$3,$4,$5,$6::jsonb,$7,$8,$9,$10,$11)
			ON CONFLICT (owner_id, hamster_id) DO UPDATE SET
				organization_id=EXCLUDED.organization_id,
				public_name=EXCLUDED.public_name,
				summary=EXCLUDED.summary,
				traits=EXCLUDED.traits,
				filming_status=EXCLUDED.filming_status,
				published=EXCLUDED.published,
				consultable=EXCLUDED.consultable,
				cta_text=EXCLUDED.cta_text,
				price_label=EXCLUDED.price_label,
				version=hamster_public_profile.version+1,
				updated_at=now()
			RETURNING id
		`, ownerID, orgID, hamsterID, emptyToNil(request.PublicName), emptyToNil(request.Summary), traits,
			request.FilmingStatus, request.Published, request.Consultable, emptyToNil(request.CTAText), emptyToNil(request.PriceLabel)).Scan(&id)
		if err != nil {
			return 0, nil, nil, err
		}
		item, err := s.queryGrowthPublicHamster(ctx, tx, ownerID, hamsterID)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusOK, envelope(r, item), map[string]string{}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) listGrowthOpportunities(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	items, err := s.loadGrowthPublicHamsters(r.Context(), ownerID, false)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	opportunities := make([]map[string]any, 0, len(items))
	for _, item := range items {
		if item.Published {
			opportunities = append(opportunities, growthcore.BuildOpportunity(item))
		}
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, opportunities))
}

func (s *Server) listGrowthCampaigns(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, campaign_code, campaign_type, platform, status, subject_type, subject_id,
			title, goal, duration_seconds, tone, cta, facts_snapshot, script_payload,
			model_name, prompt_version, published_at, version, created_at, updated_at
		FROM growth_campaign WHERE owner_id=$1 ORDER BY created_at DESC LIMIT 200
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	slug := s.ownerPublicSiteSlug(r.Context(), ownerID)
	items := make([]map[string]any, 0)
	for rows.Next() {
		item, err := scanGrowthCampaign(rows)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		attachCampaignPublicPath(item, slug)
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, items))
}

func (s *Server) generateGrowthCampaign(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request growthGenerateRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeAPIError(w, r, validationError("body", "脚本生成请求格式不正确"))
		return
	}
	request.CampaignType = strings.TrimSpace(request.CampaignType)
	if request.CampaignType != "video" && request.CampaignType != "live" {
		writeAPIError(w, r, validationError("campaign_type", "内容类型必须是 video 或 live"))
		return
	}
	if strings.TrimSpace(request.Platform) == "" || strings.TrimSpace(request.Goal) == "" || strings.TrimSpace(request.Tone) == "" {
		writeAPIError(w, r, validationError("platform/goal/tone", "平台、目标和语气必填"))
		return
	}
	hamsterID, err := uuid.Parse(strings.TrimSpace(request.HamsterID))
	if err != nil || hamsterID == uuid.Nil {
		writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
		return
	}
	subject, err := s.getGrowthPublicHamster(r.Context(), ownerID, hamsterID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if !subject.Published {
		writeAPIError(w, r, validationError("hamster_id", "请先发布这只仓鼠的公开资料"))
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	generator := growthcore.NewGeneratorFromEnv()
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		generated, err := generator.Generate(ctx, growthcore.GenerationInput{
			CampaignType: request.CampaignType, Platform: request.Platform, Goal: request.Goal,
			DurationSeconds: request.DurationSeconds, Tone: request.Tone, CTA: request.CTA, Subject: subject,
		})
		if err != nil {
			return 0, nil, nil, err
		}
		facts, _ := json.Marshal(generated.FactsSnapshot)
		script, _ := json.Marshal(generated.Script)
		code := newCampaignCode()
		var id uuid.UUID
		err = tx.QueryRow(ctx, `
			INSERT INTO growth_campaign (
				owner_id, organization_id, campaign_code, campaign_type, platform, status,
				subject_type, subject_id, title, goal, duration_seconds, tone, cta,
				facts_snapshot, script_payload, model_name, prompt_version
			) VALUES ($1,$2,$3,$4,$5,'ready','hamster',$6,$7,$8,$9,$10,$11,$12::jsonb,$13::jsonb,$14,$15)
			RETURNING id
		`, ownerID, orgID, code, request.CampaignType, request.Platform, hamsterID,
			generated.Script.Title, request.Goal, request.DurationSeconds, request.Tone, generated.Script.CTA,
			facts, script, generated.ModelName, generated.PromptVersion).Scan(&id)
		if err != nil {
			return 0, nil, nil, err
		}
		item, err := s.queryGrowthCampaign(ctx, tx, ownerID, id)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusCreated, envelope(r, item), map[string]string{"Location": "/v1/growth/campaigns/" + id.String()}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) handleGetGrowthCampaign(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	id, err := uuid.Parse(strings.TrimSpace(r.PathValue("campaign_id")))
	if err != nil || id == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	item, err := s.getGrowthCampaign(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, item))
}

func (s *Server) publishGrowthCampaign(w http.ResponseWriter, r *http.Request) {
	s.setGrowthCampaignStatus(w, r, "published")
}

func (s *Server) archiveGrowthCampaign(w http.ResponseWriter, r *http.Request) {
	s.setGrowthCampaignStatus(w, r, "archived")
}

func (s *Server) setGrowthCampaignStatus(w http.ResponseWriter, r *http.Request, status string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	id, err := uuid.Parse(strings.TrimSpace(r.PathValue("campaign_id")))
	if err != nil || id == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	payload := []byte(fmt.Sprintf(`{"status":%q}`, status))
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var current string
		if err := tx.QueryRow(ctx, `SELECT status FROM growth_campaign WHERE owner_id=$1 AND id=$2 FOR UPDATE`, ownerID, id).Scan(&current); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return 0, nil, nil, store.ErrNotFound
			}
			return 0, nil, nil, err
		}
		if status == "published" && current != "draft" && current != "ready" && current != "published" {
			return 0, nil, nil, validationError("status", "当前活动不可发布")
		}
		if status == "archived" && current == "archived" {
			item, err := s.queryGrowthCampaign(ctx, tx, ownerID, id)
			return http.StatusOK, envelope(r, item), map[string]string{}, err
		}
		_, err := tx.Exec(ctx, `
			UPDATE growth_campaign SET status=$3, published_at=CASE WHEN $3='published' THEN COALESCE(published_at, now()) ELSE NULL END,
				version=version+1, updated_at=now() WHERE owner_id=$1 AND id=$2
		`, ownerID, id, status)
		if err != nil {
			return 0, nil, nil, err
		}
		item, err := s.queryGrowthCampaign(ctx, tx, ownerID, id)
		return http.StatusOK, envelope(r, item), map[string]string{}, err
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) listGrowthLeads(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT a.id, a.contact_id, c.name, c.phone, c.wechat, a.campaign_id,
			g.campaign_code, g.title, a.consultation_id, a.source_channel,
			a.landing_path, a.interest_hamster_id, hp.public_name, a.intent_summary, a.created_at
		FROM crm_contact_attribution a
		JOIN crm_contact c ON c.owner_id=a.owner_id AND c.id=a.contact_id
		LEFT JOIN growth_campaign g ON g.owner_id=a.owner_id AND g.id=a.campaign_id
		LEFT JOIN hamster_public_profile hp ON hp.owner_id=a.owner_id AND hp.hamster_id=a.interest_hamster_id
		WHERE a.owner_id=$1 ORDER BY a.created_at DESC LIMIT 200
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]map[string]any, 0)
	for rows.Next() {
		var item map[string]any
		var id, contactID uuid.UUID
		var name string
		var phone, wechat, campaignCode, campaignTitle, sourceChannel, landingPath, hamsterName, intent *string
		var campaignID, consultationID, hamsterID *uuid.UUID
		var created time.Time
		if err := rows.Scan(&id, &contactID, &name, &phone, &wechat, &campaignID, &campaignCode, &campaignTitle, &consultationID, &sourceChannel, &landingPath, &hamsterID, &hamsterName, &intent, &created); err != nil {
			writeAPIError(w, r, err)
			return
		}
		item = map[string]any{"id": id, "contact_id": contactID, "name": name, "campaign_id": campaignID, "campaign_code": campaignCode, "campaign_title": campaignTitle, "consultation_id": consultationID, "source_channel": sourceChannel, "landing_path": landingPath, "interest_hamster_id": hamsterID, "interest_hamster_name": hamsterName, "intent_summary": intent, "created_at": created}
		if phone != nil {
			item["phone"] = *phone
		}
		if wechat != nil {
			item["wechat"] = *wechat
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, items))
}

func (s *Server) getGrowthPublicCatalog(w http.ResponseWriter, r *http.Request) {
	site, ownerID, err := s.findPublishedGrowthSite(r.Context(), r.PathValue("slug"))
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	items, err := s.loadGrowthPublicHamsters(r.Context(), ownerID, true)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	result := map[string]any{"site": site, "hamsters": items}
	code := strings.TrimSpace(r.URL.Query().Get("campaign"))
	if code != "" {
		if campaign, campaignErr := s.getPublishedCampaignByCode(r.Context(), ownerID, code); campaignErr == nil {
			result["campaign"] = campaign
		}
	}
	w.Header().Set("Cache-Control", "no-store")
	writeJSON(w, r, http.StatusOK, envelope(r, result))
}

func (s *Server) getGrowthPublicMedia(w http.ResponseWriter, r *http.Request) {
	_, ownerID, err := s.findPublishedGrowthSite(r.Context(), r.PathValue("slug"))
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	mediaID, err := uuid.Parse(strings.TrimSpace(r.PathValue("media_id")))
	if err != nil || mediaID == uuid.Nil {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	var objectKey, contentType, status, sha string
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT COALESCE(v.object_key, a.original_object_key), COALESCE(v.mime_type, a.mime_type),
			COALESCE(v.status::text, a.status::text), COALESCE(v.sha256, a.sha256)
		FROM hamster h
		JOIN hamster_public_profile p ON p.owner_id=h.owner_id AND p.hamster_id=h.id
		JOIN media_asset a ON a.owner_id=h.owner_id AND a.id=h.cover_media_id AND a.deleted_at IS NULL
		LEFT JOIN LATERAL (
			SELECT object_key, mime_type, status, sha256
			FROM media_variant
			WHERE owner_id=a.owner_id AND media_asset_id=a.id AND deleted_at IS NULL
				AND status='ready' AND object_key IS NOT NULL AND mime_type LIKE 'image/%'
			ORDER BY CASE variant_kind WHEN 'video_cover' THEN 0 WHEN 'thumbnail' THEN 1 WHEN 'preview' THEN 2 ELSE 3 END,
				created_at DESC, id DESC
			LIMIT 1
		) v ON true
		WHERE h.owner_id=$1 AND h.cover_media_id=$2 AND h.deleted_at IS NULL
			AND h.lifecycle_status='active' AND p.published=true
	`, ownerID, mediaID).Scan(&objectKey, &contentType, &status, &sha)
	if errors.Is(err, pgx.ErrNoRows) || status != "ready" || !strings.HasPrefix(contentType, "image/") {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, err)
		return
	}
	if s.ImportObjects == nil {
		w.Header().Set("Cache-Control", "no-store")
		writeAPIError(w, r, errors.New("media object store unavailable"))
		return
	}
	reader, info, err := s.ImportObjects.Get(r.Context(), objectKey)
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		if errors.Is(err, os.ErrNotExist) {
			writeAPIError(w, r, store.ErrNotFound)
			return
		}
		writeAPIError(w, r, err)
		return
	}
	defer reader.Close()
	w.Header().Set("Cache-Control", "public, no-store, max-age=0")
	w.Header().Set("Content-Type", contentType)
	if sha == "" {
		sha = info.SHA256
	}
	if sha != "" {
		w.Header().Set("ETag", `"`+sha+`"`)
	}
	_, _ = io.Copy(w, reader)
}

func (s *Server) postGrowthPublicConsultation(w http.ResponseWriter, r *http.Request) {
	site, ownerID, err := s.findPublishedGrowthSite(r.Context(), r.PathValue("slug"))
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var request growthPublicConsultRequest
	if _, err := decodeGrowthPublicBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "咨询请求格式不正确"))
		return
	}
	request.Message = strings.TrimSpace(request.Message)
	if request.Message == "" || utf8.RuneCountInString(request.Message) > 2000 {
		writeAPIError(w, r, validationError("message", "咨询内容不能为空且不能超过 2000 字"))
		return
	}
	items, err := s.loadGrowthPublicHamsters(r.Context(), ownerID, true)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	answer := growthcore.Consult(request.Message, items)
	campaignID := s.lookupPublishedCampaignID(r.Context(), ownerID, request.CampaignCode)
	interestedID := nullableUUID(request.InterestedHamsterID)
	if interestedID == nil && answer.InterestedHamsterID != "" {
		interestedID = nullableUUID(answer.InterestedHamsterID)
	}
	rawToken := strings.TrimSpace(request.SessionToken)
	if rawToken == "" {
		rawToken = uuid.NewString() + uuid.NewString()
	}
	tokenHash := hashPublicToken(rawToken)
	tx, err := s.Store.Pool.Begin(r.Context())
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer func() { _ = tx.Rollback(r.Context()) }()
	var consultationID uuid.UUID
	err = tx.QueryRow(r.Context(), `SELECT id FROM public_consultation WHERE owner_id=$1 AND public_token_hash=$2 FOR UPDATE`, ownerID, tokenHash).Scan(&consultationID)
	if errors.Is(err, pgx.ErrNoRows) {
		err = tx.QueryRow(r.Context(), `
			INSERT INTO public_consultation (public_token_hash, token_prefix, owner_id, public_site_id, campaign_id, interested_hamster_id)
			VALUES ($1,$2,$3,$4,$5,$6) RETURNING id
		`, tokenHash, rawToken[:12], ownerID, site["id"], campaignID, interestedID).Scan(&consultationID)
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	facts, _ := json.Marshal(answer.Facts)
	if _, err := tx.Exec(r.Context(), `INSERT INTO public_consultation_message (owner_id, consultation_id, role, content, facts_snapshot) VALUES ($1,$2,'user',$3,'[]'::jsonb),($1,$2,'assistant',$4,$5::jsonb)`, ownerID, consultationID, request.Message, answer.Answer, facts); err != nil {
		writeAPIError(w, r, err)
		return
	}
	if _, err := tx.Exec(r.Context(), `UPDATE public_consultation SET campaign_id=COALESCE(campaign_id,$2), interested_hamster_id=COALESCE(interested_hamster_id,$3), turn_count=turn_count+1, last_message_at=now() WHERE owner_id=$1 AND id=$4`, ownerID, campaignID, interestedID, consultationID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := tx.Commit(r.Context()); err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.Header().Set("Cache-Control", "no-store")
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{"session_token": rawToken, "consultation_id": consultationID, "answer": answer.Answer, "recommendations": answer.Recommendations, "facts": answer.Facts, "handoff_suggested": answer.HandoffSuggested}))
}

func (s *Server) postGrowthPublicLead(w http.ResponseWriter, r *http.Request) {
	site, ownerID, err := s.findPublishedGrowthSite(r.Context(), r.PathValue("slug"))
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var request growthPublicLeadRequest
	payload, err := decodeGrowthPublicBody(r, &request)
	if err != nil {
		writeAPIError(w, r, validationError("body", "留资请求格式不正确"))
		return
	}
	request.Name = strings.TrimSpace(request.Name)
	request.Phone = strings.TrimSpace(request.Phone)
	request.Wechat = strings.TrimSpace(request.Wechat)
	if request.Name == "" || utf8.RuneCountInString(request.Name) > 120 {
		writeAPIError(w, r, validationError("name", "称呼必填且不能超过 120 字"))
		return
	}
	if request.Phone == "" && request.Wechat == "" {
		writeAPIError(w, r, validationError("phone/wechat", "手机号或微信至少填写一项"))
		return
	}
	campaignID := s.lookupPublishedCampaignID(r.Context(), ownerID, request.CampaignCode)
	consultationID := s.lookupConsultationID(r.Context(), ownerID, request.ConsultationToken)
	interestedID := nullableUUID(request.InterestedHamsterID)
	if interestedID != nil && !s.isPublishedGrowthHamster(r.Context(), ownerID, *interestedID) {
		interestedID = nil
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var contactID uuid.UUID
		err := tx.QueryRow(ctx, `INSERT INTO crm_contact (owner_id, organization_id, name, phone, wechat, notes, status) VALUES ($1,$2,$3,$4,$5,$6,'lead') RETURNING id`, ownerID, orgID, request.Name, emptyToNil(&request.Phone), emptyToNil(&request.Wechat), emptyToNil(&request.IntentSummary)).Scan(&contactID)
		if err != nil {
			return 0, nil, nil, err
		}
		var attributionID uuid.UUID
		err = tx.QueryRow(ctx, `
			INSERT INTO crm_contact_attribution (owner_id, contact_id, campaign_id, consultation_id, source_channel, landing_path, interest_hamster_id, intent_summary, metadata)
			VALUES ($1,$2,$3,$4,'public_page',$5,$6,$7,$8::jsonb)
			ON CONFLICT (owner_id, consultation_id) WHERE consultation_id IS NOT NULL DO UPDATE SET
				contact_id=EXCLUDED.contact_id, campaign_id=COALESCE(crm_contact_attribution.campaign_id, EXCLUDED.campaign_id),
				interest_hamster_id=COALESCE(crm_contact_attribution.interest_hamster_id, EXCLUDED.interest_hamster_id),
				intent_summary=COALESCE(EXCLUDED.intent_summary, crm_contact_attribution.intent_summary)
			RETURNING id
		`, ownerID, contactID, campaignID, consultationID, emptyToNil(&request.LandingPath), interestedID, emptyToNil(&request.IntentSummary), `{}`).Scan(&attributionID)
		if err != nil {
			return 0, nil, nil, err
		}
		if consultationID != nil {
			_, _ = tx.Exec(ctx, `UPDATE public_consultation SET status='lead_created', last_message_at=now() WHERE owner_id=$1 AND id=$2`, ownerID, *consultationID)
		}
		return http.StatusCreated, envelope(r, map[string]any{"contact_id": contactID, "attribution_id": attributionID, "site_id": site["id"], "campaign_id": campaignID, "consultation_id": consultationID, "interest_hamster_id": interestedID}), map[string]string{}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.Header().Set("Cache-Control", "no-store")
	writeStored(w, r, result)
}

func (s *Server) loadGrowthPublicHamsters(ctx context.Context, ownerID uuid.UUID, consultableOnly bool) ([]growthcore.PublicHamster, error) {
	query := `
		SELECT h.id, COALESCE(p.public_name, h.name, ''), COALESCE(p.summary,''), p.traits,
			h.sex::text, COALESCE(h.variety_code,''), h.birth_date, p.filming_status, p.published, p.consultable,
			COALESCE(p.cta_text,''), COALESCE(p.price_label,''), h.cover_media_id
		FROM hamster_public_profile p JOIN hamster h ON h.owner_id=p.owner_id AND h.id=p.hamster_id
		WHERE p.owner_id=$1 AND h.deleted_at IS NULL AND h.lifecycle_status='active'`
	if consultableOnly {
		query += ` AND p.published=true AND p.consultable=true`
	}
	query += ` ORDER BY p.updated_at DESC, h.id`
	rows, err := s.Store.Pool.Query(ctx, query, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	slug := s.ownerPublicSiteSlug(ctx, ownerID)
	items := make([]growthcore.PublicHamster, 0)
	for rows.Next() {
		item, err := scanGrowthPublicHamster(rows)
		if err != nil {
			return nil, err
		}
		attachGrowthMediaPath(&item, slug)
		items = append(items, item)
	}
	return items, rows.Err()
}

func (s *Server) getGrowthPublicHamster(ctx context.Context, ownerID, hamsterID uuid.UUID) (growthcore.PublicHamster, error) {
	return s.queryGrowthPublicHamster(ctx, s.Store.Pool, ownerID, hamsterID)
}

type growthQueryer interface {
	Query(context.Context, string, ...any) (pgx.Rows, error)
	QueryRow(context.Context, string, ...any) pgx.Row
}

func (s *Server) queryGrowthPublicHamster(ctx context.Context, queryer growthQueryer, ownerID, hamsterID uuid.UUID) (growthcore.PublicHamster, error) {
	rows, err := queryer.Query(ctx, `
		SELECT h.id, COALESCE(p.public_name, h.name, ''), COALESCE(p.summary,''), p.traits,
			h.sex::text, COALESCE(h.variety_code,''), h.birth_date, p.filming_status, p.published, p.consultable,
			COALESCE(p.cta_text,''), COALESCE(p.price_label,''), h.cover_media_id
		FROM hamster_public_profile p JOIN hamster h ON h.owner_id=p.owner_id AND h.id=p.hamster_id
		WHERE p.owner_id=$1 AND p.hamster_id=$2 AND h.deleted_at IS NULL AND h.lifecycle_status='active'
	`, ownerID, hamsterID)
	if err != nil {
		return growthcore.PublicHamster{}, err
	}
	defer rows.Close()
	if !rows.Next() {
		return growthcore.PublicHamster{}, store.ErrNotFound
	}
	item, err := scanGrowthPublicHamster(rows)
	if err != nil {
		return growthcore.PublicHamster{}, err
	}
	attachGrowthMediaPath(&item, s.ownerPublicSiteSlug(ctx, ownerID))
	return item, nil
}

func scanGrowthPublicHamster(row interface{ Scan(...any) error }) (growthcore.PublicHamster, error) {
	var id uuid.UUID
	var name, summary, sex, variety, filming, cta, price string
	var traitsRaw []byte
	var birth *time.Time
	var coverMediaID *uuid.UUID
	var published, consultable bool
	if err := row.Scan(&id, &name, &summary, &traitsRaw, &sex, &variety, &birth, &filming, &published, &consultable, &cta, &price, &coverMediaID); err != nil {
		return growthcore.PublicHamster{}, err
	}
	traits := []string{}
	_ = json.Unmarshal(traitsRaw, &traits)
	item := growthcore.PublicHamster{ID: id.String(), PublicName: name, Summary: summary, Traits: traits, Sex: sex, Variety: publicVariety(variety), FilmingStatus: filming, Published: published, Consultable: consultable, CTAText: cta, PriceLabel: price}
	if coverMediaID != nil {
		item.Media = []growthcore.PublicMedia{{ID: coverMediaID.String(), Kind: "cover"}}
	}
	if birth != nil {
		item.BirthDate = birth.Format("2006-01-02")
	}
	return item, nil
}

func attachGrowthMediaPath(item *growthcore.PublicHamster, slug string) {
	if item == nil || strings.TrimSpace(slug) == "" {
		return
	}
	for index := range item.Media {
		if strings.TrimSpace(item.Media[index].ID) == "" {
			continue
		}
		item.Media[index].URL = fmt.Sprintf(
			"/v1/public/sites/%s/media/%s",
			slug,
			item.Media[index].ID,
		)
	}
}

func (s *Server) getGrowthCampaign(ctx context.Context, ownerID, id uuid.UUID) (map[string]any, error) {
	return s.queryGrowthCampaign(ctx, s.Store.Pool, ownerID, id)
}

func (s *Server) queryGrowthCampaign(ctx context.Context, queryer interface {
	QueryRow(context.Context, string, ...any) pgx.Row
}, ownerID, id uuid.UUID) (map[string]any, error) {
	row := queryer.QueryRow(ctx, `SELECT id, campaign_code, campaign_type, platform, status, subject_type, subject_id, title, goal, duration_seconds, tone, cta, facts_snapshot, script_payload, model_name, prompt_version, published_at, version, created_at, updated_at FROM growth_campaign WHERE owner_id=$1 AND id=$2`, ownerID, id)
	item, err := scanGrowthCampaignRow(row)
	if err != nil {
		return nil, err
	}
	attachCampaignPublicPath(item, s.ownerPublicSiteSlug(ctx, ownerID))
	return item, nil
}

func scanGrowthCampaign(rows pgx.Rows) (map[string]any, error) { return scanGrowthCampaignRow(rows) }

func scanGrowthCampaignRow(row interface{ Scan(...any) error }) (map[string]any, error) {
	var id, subjectID uuid.UUID
	var code, campaignType, platform, status, subjectType, title, goal, tone, cta, model, prompt string
	var duration *int
	var factsRaw, scriptRaw []byte
	var publishedAt *time.Time
	var version int
	var created, updated time.Time
	if err := row.Scan(&id, &code, &campaignType, &platform, &status, &subjectType, &subjectID, &title, &goal, &duration, &tone, &cta, &factsRaw, &scriptRaw, &model, &prompt, &publishedAt, &version, &created, &updated); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, store.ErrNotFound
		}
		return nil, err
	}
	var facts, script any
	if json.Unmarshal(factsRaw, &facts) != nil {
		facts = map[string]any{}
	}
	if json.Unmarshal(scriptRaw, &script) != nil {
		script = map[string]any{}
	}
	return map[string]any{"id": id, "campaign_code": code, "campaign_type": campaignType, "platform": platform, "status": status, "subject_type": subjectType, "subject_id": subjectID, "title": title, "goal": goal, "duration_seconds": duration, "tone": tone, "cta": cta, "facts_snapshot": facts, "script": script, "model_name": model, "prompt_version": prompt, "published_at": publishedAt, "version": version, "created_at": created, "updated_at": updated}, nil
}

func attachCampaignPublicPath(item map[string]any, slug string) {
	code, _ := item["campaign_code"].(string)
	if strings.TrimSpace(slug) == "" || strings.TrimSpace(code) == "" {
		item["public_url_path"] = nil
		return
	}
	item["public_url_path"] = fmt.Sprintf("/p/%s?campaign=%s", slug, code)
}

func (s *Server) ownerPublicSiteSlug(ctx context.Context, ownerID uuid.UUID) string {
	var slug string
	if err := s.Store.Pool.QueryRow(ctx, `SELECT slug FROM public_site WHERE owner_id=$1 ORDER BY published DESC, updated_at DESC LIMIT 1`, ownerID).Scan(&slug); err != nil {
		return ""
	}
	return slug
}

func (s *Server) ensureGrowthHamsterOwner(ctx context.Context, ownerID, hamsterID uuid.UUID) error {
	var exists bool
	err := s.Store.Pool.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL)`, ownerID, hamsterID).Scan(&exists)
	if err != nil {
		return err
	}
	if !exists {
		return store.ErrNotFound
	}
	return nil
}

func (s *Server) findPublishedGrowthSite(ctx context.Context, slug string) (map[string]any, uuid.UUID, error) {
	var siteID, ownerID uuid.UUID
	var title, theme, organizationName string
	var tagline, about, contactWechat, contactPhone *string
	var showContact bool
	var publishedAt *time.Time
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT s.id, s.owner_id, s.title, s.tagline, s.about, s.theme_color, s.published_at,
			s.contact_wechat, s.contact_phone, s.show_contact, COALESCE(o.name, '')
		FROM public_site s
		LEFT JOIN organization o ON o.owner_id=s.owner_id AND o.id=s.organization_id
		WHERE s.slug=$1 AND s.published=true
	`, strings.ToLower(strings.TrimSpace(slug))).Scan(
		&siteID, &ownerID, &title, &tagline, &about, &theme, &publishedAt,
		&contactWechat, &contactPhone, &showContact, &organizationName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, uuid.Nil, store.ErrNotFound
	}
	if err != nil {
		return nil, uuid.Nil, err
	}
	result := map[string]any{"id": siteID, "slug": strings.ToLower(strings.TrimSpace(slug)), "title": title, "tagline": tagline, "about": about, "theme_color": theme, "published_at": publishedAt, "organization_name": organizationName}
	if showContact {
		result["contact_wechat"] = contactWechat
		result["contact_phone"] = contactPhone
	}
	return result, ownerID, nil
}

func (s *Server) getPublishedCampaignByCode(ctx context.Context, ownerID uuid.UUID, code string) (map[string]any, error) {
	// ready/published 活动均可用于公开页展示与归因；archived/draft 无效。
	row := s.Store.Pool.QueryRow(ctx, `SELECT id, campaign_code, campaign_type, platform, status, subject_type, subject_id, title, goal, duration_seconds, tone, cta, facts_snapshot, script_payload, model_name, prompt_version, published_at, version, created_at, updated_at FROM growth_campaign WHERE owner_id=$1 AND campaign_code=$2 AND status IN ('ready','published')`, ownerID, strings.TrimSpace(code))
	item, err := scanGrowthCampaignRow(row)
	if err != nil {
		return nil, err
	}
	attachCampaignPublicPath(item, s.ownerPublicSiteSlug(ctx, ownerID))
	return item, nil
}

func (s *Server) lookupPublishedCampaignID(ctx context.Context, ownerID uuid.UUID, code string) *uuid.UUID {
	var id uuid.UUID
	if strings.TrimSpace(code) == "" {
		return nil
	}
	if err := s.Store.Pool.QueryRow(ctx, `SELECT id FROM growth_campaign WHERE owner_id=$1 AND campaign_code=$2 AND status IN ('ready','published')`, ownerID, strings.TrimSpace(code)).Scan(&id); err != nil {
		return nil
	}
	return &id
}

func (s *Server) lookupConsultationID(ctx context.Context, ownerID uuid.UUID, rawToken string) *uuid.UUID {
	if strings.TrimSpace(rawToken) == "" {
		return nil
	}
	var id uuid.UUID
	if err := s.Store.Pool.QueryRow(ctx, `SELECT id FROM public_consultation WHERE owner_id=$1 AND public_token_hash=$2`, ownerID, hashPublicToken(rawToken)).Scan(&id); err != nil {
		return nil
	}
	return &id
}

func (s *Server) isPublishedGrowthHamster(ctx context.Context, ownerID, hamsterID uuid.UUID) bool {
	var ok bool
	_ = s.Store.Pool.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM hamster_public_profile p JOIN hamster h ON h.owner_id=p.owner_id AND h.id=p.hamster_id WHERE p.owner_id=$1 AND p.hamster_id=$2 AND p.published=true AND h.deleted_at IS NULL)`, ownerID, hamsterID).Scan(&ok)
	return ok
}

func decodeGrowthPublicBody(r *http.Request, target any) ([]byte, error) {
	r.Body = io.NopCloser(io.LimitReader(r.Body, (64<<10)+1))
	return decodeBody(r, target)
}

func newCampaignCode() string {
	return "c_" + strings.ToLower(strings.ReplaceAll(uuid.NewString(), "-", ""))[:18]
}

func hashPublicToken(raw string) string {
	sum := sha256.Sum256([]byte(raw))
	return hex.EncodeToString(sum[:])
}

func nullableUUID(value string) *uuid.UUID {
	id, err := uuid.Parse(strings.TrimSpace(value))
	if err != nil || id == uuid.Nil {
		return nil
	}
	return &id
}

func publicVariety(value string) string {
	if index := strings.Index(value, "|"); index > 0 && index < len(value)-1 {
		return value[index+1:]
	}
	return value
}
