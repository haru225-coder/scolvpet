package httpapi

// B 端 WeChat identity (P2 mirror): wx.login exchanges into the existing
// staff Bearer session. It deliberately does not touch customer_session or
// issue a ct_* token.

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/domain"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

const (
	breederWechatBindTicketTTL       = 10 * time.Minute
	breederWechatSessionIPMaxPerHour = 60
)

type breederWechatSessionRequest struct {
	JsCode string `json:"js_code"`
}

type breederWechatBindingRequest struct {
	WechatTicket   string    `json:"wechat_ticket"`
	Phone          string    `json:"phone"`
	VerificationID uuid.UUID `json:"verification_id"`
	Code           string    `json:"code"`
}

func breederWechatUnavailableError() error {
	return &apiError{Status: http.StatusServiceUnavailable, Code: "WECHAT_UNAVAILABLE", Message: "微信登录暂不可用，请使用短信验证码登录"}
}

func breederWechatCodeInvalidError() error {
	return &apiError{Status: http.StatusUnauthorized, Code: "WECHAT_CODE_INVALID", Message: "微信登录凭证无效，请重试"}
}

// createBreederWechatSession exchanges a wx.login js_code. Bound openids get
// a normal staff session; an unbound openid gets a short-lived bwt_* ticket.
func (s *Server) createBreederWechatSession(w http.ResponseWriter, r *http.Request) {
	var request breederWechatSessionRequest
	if _, err := decodeBody(r, &request); err != nil || strings.TrimSpace(request.JsCode) == "" {
		writeAPIError(w, r, validationError("js_code", "请提供微信登录凭证"))
		return
	}
	if retry, err := s.enforceRateLimit(r.Context(), "breeder-wx:ip:"+s.clientIP(r), 0, breederWechatSessionIPMaxPerHour, time.Hour); err != nil {
		if isRateLimitError(err) {
			writeAPIError(w, r, rateLimitedError(retry))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	if s.Wechat == nil {
		writeAPIError(w, r, breederWechatUnavailableError())
		return
	}
	session, err := s.Wechat.Code2Session(r.Context(), strings.TrimSpace(request.JsCode))
	if err != nil {
		if s.Logger != nil {
			s.Logger.Warn("breeder wechat code2session failed", "error", err)
		}
		writeAPIError(w, r, breederWechatCodeInvalidError())
		return
	}

	var accountID uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT account_id
		FROM breeder_wechat_identity
		WHERE openid=$1 AND revoked_at IS NULL
	`, session.OpenID).Scan(&accountID)
	switch {
	case err == nil:
		account, accountErr := s.Store.GetAccount(r.Context(), accountID)
		if accountErr != nil {
			writeAPIError(w, r, accountErr)
			return
		}
		key := strings.TrimSpace(r.Header.Get("Idempotency-Key"))
		if key == "" {
			key = "breeder-wx-session-" + uuid.NewString()
		}
		requestPayload, _ := json.Marshal(request)
		result, issueErr := s.Store.RunIdempotent(r.Context(), accountID, key, http.MethodPost, r.URL.Path, requestPayload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			tag, err := tx.Exec(ctx, `
				UPDATE breeder_wechat_identity
				SET last_login_at=now()
				WHERE openid=$1 AND account_id=$2 AND revoked_at IS NULL
			`, session.OpenID, accountID)
			if err != nil {
				return 0, nil, nil, err
			}
			if tag.RowsAffected() != 1 {
				return 0, nil, nil, authRequired()
			}
			return s.issueBreederSessionResponseTx(ctx, tx, r, account, accountID, false)
		})
		if issueErr != nil {
			writeAPIError(w, r, issueErr)
			return
		}
		writeStored(w, r, result)
	case errors.Is(err, pgx.ErrNoRows):
		rawTicket := "bwt_" + uuid.NewString()
		var unionID *string
		if session.UnionID != "" {
			unionID = &session.UnionID
		}
		_, insertErr := s.Store.Pool.Exec(r.Context(), `
			INSERT INTO breeder_wechat_bind_ticket (openid, unionid, ticket_sha256, expires_at)
			VALUES ($1, $2, $3, $4)
		`, session.OpenID, unionID, sha256Hex(rawTicket), time.Now().UTC().Add(breederWechatBindTicketTTL))
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

// createBreederWechatBinding consumes the ticket after SMS verification and
// issues the same staff session shape as phone-code login.
func (s *Server) createBreederWechatBinding(w http.ResponseWriter, r *http.Request) {
	var request breederWechatBindingRequest
	payload, err := decodeBody(r, &request)
	if err != nil ||
		!strings.HasPrefix(request.WechatTicket, "bwt_") ||
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
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT id, openid, unionid, expires_at, used_at
		FROM breeder_wechat_bind_ticket
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
	account, accountID, err := s.Store.EnsureAccount(r.Context(), request.Phone)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	key := strings.TrimSpace(r.Header.Get("Idempotency-Key"))
	if key == "" {
		key = "breeder-wx-bind-" + ticketID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), accountID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		tag, updateErr := tx.Exec(ctx, `
			UPDATE breeder_wechat_bind_ticket
			SET used_at=now()
			WHERE id=$1 AND used_at IS NULL AND expires_at > now()
		`, ticketID)
		if updateErr != nil {
			return 0, nil, nil, updateErr
		}
		if tag.RowsAffected() != 1 {
			return 0, nil, nil, validationError("wechat_ticket", "微信绑定票据无效或已过期，请重新进入小程序")
		}
		_, insertErr := tx.Exec(ctx, `
			INSERT INTO breeder_wechat_identity (openid, unionid, account_id)
			VALUES ($1, $2, $3)
		`, openID, unionID, accountID)
		if insertErr != nil {
			if isUniqueViolation(insertErr) {
				return 0, nil, nil, conflictError("wechat_identity", "该微信或经营账号已绑定其他身份")
			}
			return 0, nil, nil, insertErr
		}
		return s.issueBreederSessionResponseTx(ctx, tx, r, account, accountID, true)
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) deleteBreederWechatBinding(w http.ResponseWriter, r *http.Request) {
	_, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	principal, ok := principalFromRequest(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	if _, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE breeder_wechat_identity
		SET revoked_at=now()
		WHERE account_id=$1 AND revoked_at IS NULL
	`, principal.AccountID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) issueBreederSessionResponseTx(
	ctx context.Context,
	tx pgx.Tx,
	r *http.Request,
	account domain.Account,
	accountID uuid.UUID,
	onboard bool,
) (int, any, map[string]string, error) {
	var principal store.Principal
	var organization domain.Organization
	var err error
	if onboard {
		// The binding path has already verified the phone and ensured its account;
		// use the normal login resolver so invitations and owner membership follow
		// the same rules as SMS login.
		phone, phoneErr := breederAccountPhoneTx(ctx, tx, accountID)
		if phoneErr != nil {
			return 0, nil, nil, phoneErr
		}
		principal, organization, err = store.ResolveLoginPrincipalTx(ctx, tx, accountID, phone)
	} else {
		principal, organization, err = store.ResolvePrincipalContextTx(ctx, tx, accountID)
	}
	if err != nil {
		return 0, nil, nil, err
	}
	accessToken, refreshToken, err := s.Auth.CreateSession(ctx, principal.AccountID)
	if err != nil {
		return 0, nil, nil, err
	}
	return http.StatusCreated, envelope(r, map[string]any{
		"token_type":           "Bearer",
		"access_token":         accessToken,
		"expires_in_seconds":   3600,
		"refresh_token":        refreshToken,
		"account":              account,
		"current_organization": organization,
		"member_role":          principal.Role,
		"capabilities":         principalCapabilities(principal.Role),
	}), map[string]string{}, nil
}

func breederAccountPhoneTx(ctx context.Context, tx pgx.Tx, accountID uuid.UUID) (string, error) {
	var country, number string
	if err := tx.QueryRow(ctx, `
		SELECT phone_country_code, phone_number
		FROM account
		WHERE id=$1 AND deleted_at IS NULL
	`, accountID).Scan(&country, &number); err != nil {
		return "", err
	}
	return country + number, nil
}
