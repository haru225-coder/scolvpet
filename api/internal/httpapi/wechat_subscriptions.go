package httpapi

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

func (s *Server) registerWechatSubscriptionRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/wechat/subscriptions", s.listWechatSubscriptions)
	mux.HandleFunc("PUT /v1/wechat/subscriptions", s.upsertWechatSubscriptions)
	mux.HandleFunc("POST /v1/wechat/subscriptions/send", s.sendWechatSubscription)
}

type wechatSubscription struct {
	ID         uuid.UUID  `json:"id"`
	TemplateID string     `json:"template_id"`
	Status     string     `json:"status"`
	Page       *string    `json:"page,omitempty"`
	GrantedAt  time.Time  `json:"granted_at"`
	LastSentAt *time.Time `json:"last_sent_at,omitempty"`
	Version    int        `json:"version"`
}

type upsertWechatSubscriptionsRequest struct {
	Templates map[string]string `json:"templates"`
	Page      *string           `json:"page"`
}

type sendWechatSubscriptionRequest struct {
	TemplateID string            `json:"template_id"`
	Page       *string           `json:"page"`
	Data       map[string]string `json:"data"`
}

func (s *Server) listWechatSubscriptions(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, template_id, status, page, granted_at, last_sent_at, version
		FROM breeder_wechat_subscription
		WHERE account_id=$1
		ORDER BY updated_at DESC, id DESC
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]wechatSubscription, 0)
	for rows.Next() {
		var item wechatSubscription
		if err := rows.Scan(&item.ID, &item.TemplateID, &item.Status, &item.Page, &item.GrantedAt, &item.LastSentAt, &item.Version); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) upsertWechatSubscriptions(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request upsertWechatSubscriptionsRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "订阅授权请求体格式不正确"))
		return
	}
	if len(request.Templates) == 0 || len(request.Templates) > 20 {
		writeAPIError(w, r, validationError("templates", "请提供 1 至 20 个订阅模板授权状态"))
		return
	}
	for templateID, status := range request.Templates {
		if !validWechatTemplateID(templateID) {
			writeAPIError(w, r, validationError("templates", "订阅模板 ID 无效"))
			return
		}
		if !validWechatSubscriptionStatus(status) {
			writeAPIError(w, r, validationError("templates", "订阅授权状态无效"))
			return
		}
	}
	page := strings.TrimSpace(derefString(request.Page))
	var openID string
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT openid
		FROM breeder_wechat_identity
		WHERE account_id=$1 AND revoked_at IS NULL
		ORDER BY last_login_at DESC
		LIMIT 1
	`, ownerID).Scan(&openID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			writeAPIError(w, r, wechatSubscriptionNotBoundError())
			return
		}
		writeAPIError(w, r, err)
		return
	}
	for templateID, status := range request.Templates {
		if _, err := s.Store.Pool.Exec(r.Context(), `
			INSERT INTO breeder_wechat_subscription (account_id, openid, template_id, status, page)
			VALUES ($1,$2,$3,$4,$5)
			ON CONFLICT (account_id, template_id) DO UPDATE SET
				openid=EXCLUDED.openid,
				status=EXCLUDED.status,
				page=COALESCE(EXCLUDED.page, breeder_wechat_subscription.page),
				granted_at=now(),
				version=breeder_wechat_subscription.version+1,
				updated_at=now()
		`, ownerID, openID, templateID, strings.ToLower(strings.TrimSpace(status)), emptyToNil(&page)); err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	s.listWechatSubscriptions(w, r)
}

func (s *Server) sendWechatSubscription(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	if s.WechatSubscription == nil {
		writeAPIError(w, r, wechatSubscriptionUnavailableError())
		return
	}
	var request sendWechatSubscriptionRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "订阅消息请求体格式不正确"))
		return
	}
	request.TemplateID = strings.TrimSpace(request.TemplateID)
	if !validWechatTemplateID(request.TemplateID) {
		writeAPIError(w, r, validationError("template_id", "订阅模板 ID 无效"))
		return
	}
	if len(request.Data) == 0 || len(request.Data) > 20 {
		writeAPIError(w, r, validationError("data", "订阅消息数据必须包含 1 至 20 个字段"))
		return
	}
	for key, value := range request.Data {
		if strings.TrimSpace(key) == "" || len(key) > 64 || len(value) > 256 {
			writeAPIError(w, r, validationError("data", "订阅消息字段格式无效"))
			return
		}
	}
	var openID, storedPage string
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT s.openid, COALESCE(s.page, '')
		FROM breeder_wechat_subscription s
		JOIN breeder_wechat_identity i
		  ON i.account_id=s.account_id AND i.openid=s.openid AND i.revoked_at IS NULL
		WHERE s.account_id=$1 AND s.template_id=$2 AND s.status='accept'
	`, ownerID, request.TemplateID).Scan(&openID, &storedPage)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			writeAPIError(w, r, validationError("template_id", "该模板尚未获得有效订阅授权"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	page := strings.TrimSpace(derefString(request.Page))
	if page == "" {
		page = storedPage
	}
	delivery, err := s.WechatSubscription.SendSubscription(r.Context(), openID, request.TemplateID, page, request.Data)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	_, err = s.Store.Pool.Exec(r.Context(), `
		UPDATE breeder_wechat_subscription
		SET last_sent_at=$3, version=version+1, updated_at=now()
		WHERE account_id=$1 AND template_id=$2
	`, ownerID, request.TemplateID, delivery.SentAt)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"template_id":         request.TemplateID,
			"provider_message_id": delivery.ProviderMessageID,
			"sent_at":             delivery.SentAt,
		},
		"meta": responseMeta(r),
	})
}

func validWechatTemplateID(value string) bool {
	value = strings.TrimSpace(value)
	return value != "" && len(value) <= 128 && !strings.ContainsAny(value, "\r\n")
}

func validWechatSubscriptionStatus(value string) bool {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "accept", "reject", "ban", "unknown":
		return true
	default:
		return false
	}
}

func wechatSubscriptionNotBoundError() error {
	return &apiError{Status: http.StatusConflict, Code: "WECHAT_NOT_BOUND", Message: "请先完成 B 端微信登录绑定后再授权订阅消息"}
}

func wechatSubscriptionUnavailableError() error {
	return &apiError{Status: http.StatusServiceUnavailable, Code: "WECHAT_SUBSCRIPTION_UNAVAILABLE", Message: "微信订阅消息通道暂未配置"}
}
