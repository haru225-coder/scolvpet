package httpapi

// WeChat mini-program identity (P2): wx.login silent sign-in for bound
// customers, one-time bind tickets + SMS verification for first-time binding.
// openid only skips the repeat SMS step; phone stays the business source of
// truth and session issuance reuses the 0035 customer_session mechanism.

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

const (
	wechatBindTicketTTL       = 10 * time.Minute
	customerSessionTTL        = 30 * 24 * time.Hour
	wechatSessionIPMaxPerHour = 60
)

type wechatSessionRequest struct {
	JsCode string `json:"js_code"`
}

type wechatBindingRequest struct {
	WechatTicket   string    `json:"wechat_ticket"`
	Phone          string    `json:"phone"`
	VerificationID uuid.UUID `json:"verification_id"`
	Code           string    `json:"code"`
}

// issueCustomerSessionData mirrors createCustomerSession: opaque ct_* bearer,
// sha256 at rest in customer_session, identical response data shape.
func (s *Server) issueCustomerSessionData(ctx context.Context, phone string) (map[string]any, error) {
	rawToken := "ct_" + uuid.NewString()
	hash := sha256Hex(rawToken)
	expires := time.Now().UTC().Add(customerSessionTTL)
	_, err := s.Store.Pool.Exec(ctx, `
		INSERT INTO customer_session (phone, token_sha256, expires_at)
		VALUES ($1, $2, $3)
	`, phone, hash, expires)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"token_type":         "Bearer",
		"access_token":       rawToken,
		"expires_in_seconds": int(customerSessionTTL / time.Second),
		"phone":              phone,
	}, nil
}

func wechatUnavailableError() error {
	return &apiError{Status: http.StatusServiceUnavailable, Code: "WECHAT_UNAVAILABLE", Message: "微信登录暂不可用，请使用短信验证码登录"}
}

func wechatCodeInvalidError() error {
	return &apiError{Status: http.StatusUnauthorized, Code: "WECHAT_CODE_INVALID", Message: "微信登录凭证无效，请重试"}
}

// createCustomerWechatSession exchanges a wx.login js_code: bound openid gets
// a silent ct_* session (201); unbound openid gets a one-time bind ticket
// (200, bind_required). The raw wt_* ticket appears only in this response.
func (s *Server) createCustomerWechatSession(w http.ResponseWriter, r *http.Request) {
	var request wechatSessionRequest
	if _, err := decodeBody(r, &request); err != nil || strings.TrimSpace(request.JsCode) == "" {
		writeAPIError(w, r, validationError("js_code", "请提供微信登录凭证"))
		return
	}
	if retry, err := s.enforceRateLimit(r.Context(), "cust-wx:ip:"+s.clientIP(r), 0, wechatSessionIPMaxPerHour, time.Hour); err != nil {
		if isRateLimitError(err) {
			writeAPIError(w, r, rateLimitedError(retry))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	if s.Wechat == nil {
		writeAPIError(w, r, wechatUnavailableError())
		return
	}
	session, err := s.Wechat.Code2Session(r.Context(), strings.TrimSpace(request.JsCode))
	if err != nil {
		if s.Logger != nil {
			s.Logger.Warn("wechat code2session failed", "error", err)
		}
		writeAPIError(w, r, wechatCodeInvalidError())
		return
	}
	// SessionKey never leaves this handler.
	var identityID uuid.UUID
	var phone string
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT id, phone FROM customer_wechat_identity
		WHERE openid=$1 AND revoked_at IS NULL
	`, session.OpenID).Scan(&identityID, &phone)
	switch {
	case err == nil:
		data, issueErr := s.issueCustomerSessionData(r.Context(), phone)
		if issueErr != nil {
			writeAPIError(w, r, issueErr)
			return
		}
		_, _ = s.Store.Pool.Exec(r.Context(), `
			UPDATE customer_wechat_identity SET last_login_at=now() WHERE id=$1
		`, identityID)
		writeJSON(w, r, http.StatusCreated, envelope(r, data))
	case errors.Is(err, pgx.ErrNoRows):
		rawTicket := "wt_" + uuid.NewString()
		var unionID *string
		if session.UnionID != "" {
			unionID = &session.UnionID
		}
		_, insertErr := s.Store.Pool.Exec(r.Context(), `
			INSERT INTO wechat_bind_ticket (openid, unionid, ticket_sha256, expires_at)
			VALUES ($1, $2, $3, $4)
		`, session.OpenID, unionID, sha256Hex(rawTicket), time.Now().UTC().Add(wechatBindTicketTTL))
		if insertErr != nil {
			writeAPIError(w, r, insertErr)
			return
		}
		writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
			"bind_required": true,
			"wechat_ticket": rawTicket,
		}))
	default:
		writeAPIError(w, r, err)
	}
}

// createCustomerWechatBinding consumes a bind ticket after SMS verification:
// ticket valid → VerifyCode → mark used → insert binding → issue session.
func (s *Server) createCustomerWechatBinding(w http.ResponseWriter, r *http.Request) {
	var request wechatBindingRequest
	if _, err := decodeBody(r, &request); err != nil ||
		!strings.HasPrefix(request.WechatTicket, "wt_") ||
		!phonePattern.MatchString(request.Phone) ||
		!codePattern.MatchString(request.Code) ||
		request.VerificationID == uuid.Nil {
		writeAPIError(w, r, validationError("wechat_binding", "请提供完整的微信绑定信息"))
		return
	}
	var ticketID uuid.UUID
	var openID string
	var unionID *string
	var expiresAt time.Time
	var usedAt *time.Time
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT id, openid, unionid, expires_at, used_at
		FROM wechat_bind_ticket
		WHERE ticket_sha256=$1
	`, sha256Hex(request.WechatTicket)).Scan(&ticketID, &openID, &unionID, &expiresAt, &usedAt)
	if errors.Is(err, pgx.ErrNoRows) || (err == nil && (usedAt != nil || !time.Now().UTC().Before(expiresAt))) {
		writeAPIError(w, r, validationError("wechat_ticket", "微信绑定票据无效或已过期，请重新进入小程序"))
		return
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := s.Auth.VerifyCode(r.Context(), request.VerificationID, request.Phone, request.Code); err != nil {
		writeAPIError(w, r, err)
		return
	}
	// One-shot consumption guarded by used_at IS NULL against races.
	tag, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE wechat_bind_ticket SET used_at=now() WHERE id=$1 AND used_at IS NULL
	`, ticketID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() != 1 {
		writeAPIError(w, r, validationError("wechat_ticket", "微信绑定票据无效或已过期，请重新进入小程序"))
		return
	}
	_, err = s.Store.Pool.Exec(r.Context(), `
		INSERT INTO customer_wechat_identity (openid, unionid, phone)
		VALUES ($1, $2, $3)
	`, openID, unionID, request.Phone)
	if err != nil {
		if strings.Contains(err.Error(), "ux_customer_wechat_identity_openid_active") ||
			strings.Contains(err.Error(), "duplicate") || strings.Contains(err.Error(), "unique") {
			writeAPIError(w, r, validationError("openid", "该微信已绑定手机号，请直接登录"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	data, err := s.issueCustomerSessionData(r.Context(), request.Phone)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, envelope(r, data))
}

// deleteCustomerWechatBinding revokes all active bindings for the customer's
// phone (revoked_at=now(), rows kept for audit) and returns 204.
func (s *Server) deleteCustomerWechatBinding(w http.ResponseWriter, r *http.Request) {
	principal, ok := s.authenticateCustomer(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	_, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE customer_wechat_identity
		SET revoked_at=now()
		WHERE phone=$1 AND revoked_at IS NULL
	`, principal.Phone)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
