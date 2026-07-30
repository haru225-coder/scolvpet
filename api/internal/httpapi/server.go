package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"net/netip"
	"os"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/domain"
	"github.com/scolvpet/scolvpet/api/internal/objectstore"
	"github.com/scolvpet/scolvpet/api/internal/ratelimit"
	"github.com/scolvpet/scolvpet/api/internal/store"
	"github.com/scolvpet/scolvpet/api/internal/wechat"
)

type Server struct {
	Store         *store.Store
	Auth          *auth.Service
	Logger        *slog.Logger
	ImportObjects objectstore.ObjectStore
	RateLimiter   *ratelimit.Postgres
	// Wechat exchanges wx.login js_codes for WeChat identities (P2).
	Wechat wechat.Provider
	// WechatSubscription delivers accepted B-side subscription templates.
	WechatSubscription wechat.SubscriptionSender
	// Environment is APP_ENV (development|test|staging|production).
	// Sandbox entitlement routes are only registered outside production.
	Environment string
	// Ready surfaces deploy-relevant config facts on /readyz so the
	// production smoke can assert the runtime wiring (docs/30 P1-2).
	// Nil keeps the legacy {"status":"ready"} shape for unit tests.
	Ready *ReadyChecks
	// TrustedProxies gates X-Forwarded-For / X-Real-IP trust for clientIP.
	// Empty means no proxy is trusted and only the socket peer is used.
	TrustedProxies []netip.Prefix
	// WechatPhoneGlobalPerMinute and WechatPhoneGlobalPerDay cap all public
	// WeChat phone-code exchanges across clients. Process startup injects the
	// configured values; zero keeps DB-free unit tests free of rate limits.
	WechatPhoneGlobalPerMinute int
	WechatPhoneGlobalPerDay    int
}

// smsPhoneDailyMax caps verification-code sends per phone per 24h in
// staging/production (P3 policy); dev/test skip it for repeated smoke runs.
const smsPhoneDailyMax = 10

// customerWechatPhoneIPMaxPerMinute is deliberately independent of ticket
// state. Tickets are single-use; a separate ticket retry budget would create
// misleading retry semantics for a one-shot WeChat phone_code.
const customerWechatPhoneIPMaxPerMinute = 10

// ReadyChecks is the /readyz "checks" payload; values come from the process
// runtime config, not from re-reading the environment.
type ReadyChecks struct {
	SMSProvider                         string `json:"sms_provider"`
	SMSMockCodeSet                      bool   `json:"sms_mock_code_set"`
	WechatProvider                      string `json:"wechat_provider"`
	WechatSubscriptionProvider          string `json:"wechat_subscription_provider"`
	WechatTaskTemplateConfigured        bool   `json:"wechat_task_template_configured"`
	WechatReservationTemplateConfigured bool   `json:"wechat_reservation_template_configured"`
}

type deviceInfo struct {
	Platform   string  `json:"platform"`
	DeviceName *string `json:"device_name"`
	AppVersion string  `json:"app_version"`
	PushToken  *string `json:"push_token"`
}

type verificationRequest struct {
	Phone   string `json:"phone"`
	Purpose string `json:"purpose"`
}

type loginRequest struct {
	Phone          string     `json:"phone"`
	VerificationID uuid.UUID  `json:"verification_id"`
	Code           string     `json:"code"`
	Device         deviceInfo `json:"device"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type logoutRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type meta struct {
	RequestID   string    `json:"request_id"`
	GeneratedAt time.Time `json:"generated_at"`
	Timezone    string    `json:"timezone"`
}

func NewServer(store *store.Store, authService *auth.Service, logger *slog.Logger) *Server {
	root := os.Getenv("IMPORT_OBJECT_STORE_DIR")
	if root == "" {
		root = os.TempDir() + "/scolvpet-imports"
	}
	objects, err := objectstore.NewLocalFS(root)
	if err != nil {
		// Keep auth-only/unit-test construction functional. A DB-backed server
		// reports the storage error when an upload is attempted.
		logger.Warn("import object store unavailable", "error", err)
	}
	var rateLimiter *ratelimit.Postgres
	if store != nil && store.Pool != nil {
		rateLimiter = ratelimit.NewPostgres(store.Pool)
	}
	return &Server{Store: store, Auth: authService, Logger: logger, ImportObjects: objects, RateLimiter: rateLimiter}
}

func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", s.health)
	mux.HandleFunc("GET /readyz", s.ready)
	mux.HandleFunc("POST /v1/auth/verification-codes", s.sendVerificationCode)
	mux.HandleFunc("POST /v1/auth/sessions", s.createSession)
	mux.HandleFunc("POST /v1/auth/wechat-sessions", s.createBreederWechatSession)
	mux.HandleFunc("POST /v1/auth/wechat-bindings", s.createBreederWechatBinding)
	mux.HandleFunc("DELETE /v1/auth/wechat-bindings/current", s.deleteBreederWechatBinding)
	s.registerWechatSubscriptionRoutes(mux)
	mux.HandleFunc("POST /v1/auth/sessions/refresh", s.refreshSession)
	mux.HandleFunc("DELETE /v1/auth/sessions/current", s.deleteSession)
	mux.HandleFunc("GET /v1/me", s.getMe)
	mux.HandleFunc("GET /v1/organizations/current", s.getOrganization)
	mux.HandleFunc("PATCH /v1/organizations/current", s.patchOrganization)
	mux.HandleFunc("GET /v1/species-rule-templates", s.listSystemRules)
	mux.HandleFunc("GET /v1/species-rule-versions", s.listOwnerRules)
	mux.HandleFunc("POST /v1/species-rule-versions", s.createOwnerRule)
	mux.HandleFunc("GET /v1/species-rule-versions/{rule_version_id}", s.getRule)
	s.registerI2CoreRoutes(mux)
	s.registerI2ImportRoutes(mux)
	s.registerI3Routes(mux)
	s.registerI4Routes(mux)
	s.registerI5Routes(mux)
	s.registerI6DataRoutes(mux)
	s.registerI6MediaRoutes(mux)
	s.registerP1MemberRoutes(mux)
	s.registerP1CrmRoutes(mux)
	s.registerP1ContractRoutes(mux)
	s.registerP1AccountingRoutes(mux)
	s.registerP1GeneticRoutes(mux)
	s.registerP1PushRoutes(mux)
	s.registerP1EntitlementRoutes(mux)
	s.registerP2PublicSiteRoutes(mux)
	s.registerP2MiniprogramRoutes(mux)
	s.registerP2AssistantRoutes(mux)
	s.registerP2StudRoutes(mux)
	s.registerP3GrowthRoutes(mux)
	s.registerOpenAPIConformanceRoutes(mux)
	s.registerCustomerRoutes(mux)
	return requestIDMiddleware(s.Logger, s.rbacMiddleware(mux))
}

func (s *Server) health(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, r, http.StatusOK, map[string]any{"status": "ok", "service": "scolvpet-api"})
}

func (s *Server) ready(w http.ResponseWriter, r *http.Request) {
	if err := s.Store.Ping(r.Context()); err != nil {
		writeJSON(w, r, http.StatusServiceUnavailable, map[string]any{"status": "not_ready", "error": "database unavailable"})
		return
	}
	writeJSON(w, r, http.StatusOK, s.readyBody())
}

func (s *Server) readyBody() map[string]any {
	body := map[string]any{"status": "ready"}
	if env := strings.TrimSpace(s.Environment); env != "" {
		body["environment"] = env
	}
	if s.Ready != nil {
		body["checks"] = s.Ready
	}
	return body
}

func (s *Server) sendVerificationCode(w http.ResponseWriter, r *http.Request) {
	var request verificationRequest
	payload, err := decodeBody(r, &request)
	if err != nil || !phonePattern.MatchString(request.Phone) || request.Purpose != "login" {
		writeAPIError(w, r, validationError("phone/purpose", "请输入有效的中国大陆手机号和 login 用途"))
		return
	}
	key := r.Header.Get("Idempotency-Key")
	// Public pre-account idempotency: no EnsureAccount before verification.
	result, err := s.Store.RunPublicIdempotent(r.Context(), key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context) (int, any, error) {
		phoneCooldown := 60 * time.Second
		phoneMax := 5
		ipMax := 20
		dailyMax := smsPhoneDailyMax
		retryAfterHint := 60
		if env := strings.ToLower(strings.TrimSpace(s.Environment)); env == "" || env == "development" || env == "test" {
			// Local smoke logs out and requests a second code immediately; keep
			// the hourly caps but avoid a development-only 60-second wait.
			phoneCooldown = 0
			dailyMax = 0
			retryAfterHint = 1
		}
		if retry, err := s.enforceRateLimit(ctx, "sms:phone:"+request.Phone, phoneCooldown, phoneMax, time.Hour); err != nil {
			if isRateLimitError(err) {
				return 0, nil, rateLimitedError(retry)
			}
			return 0, nil, err
		}
		if retry, err := s.enforceRateLimit(ctx, "sms:ip:"+s.clientIP(r), 0, ipMax, time.Hour); err != nil {
			if isRateLimitError(err) {
				return 0, nil, rateLimitedError(retry)
			}
			return 0, nil, err
		}
		// Daily cap per phone (P3): the hourly bucket alone allows 120/day.
		if dailyMax > 0 {
			if retry, err := s.enforceRateLimit(ctx, "sms:phone:day:"+request.Phone, 0, dailyMax, 24*time.Hour); err != nil {
				if isRateLimitError(err) {
					return 0, nil, rateLimitedError(retry)
				}
				return 0, nil, err
			}
		}
		challenge, err := s.Auth.RequestCode(ctx, request.Phone)
		if err != nil {
			return 0, nil, err
		}
		return http.StatusAccepted, envelope(r, map[string]any{
			"verification_id":     challenge.ID,
			"expires_in_seconds":  300,
			"retry_after_seconds": retryAfterHint,
		}), nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) createSession(w http.ResponseWriter, r *http.Request) {
	var request loginRequest
	payload, err := decodeBody(r, &request)
	if err != nil || !phonePattern.MatchString(request.Phone) || !codePattern.MatchString(request.Code) || request.VerificationID == uuid.Nil {
		writeAPIError(w, r, validationError("login", "请输入完整的验证码登录信息"))
		return
	}
	// Prefer replaying an existing login idempotency record when the account already
	// exists, so we never re-consume a verification challenge on retry.
	if account, ownerID, found, findErr := s.Store.FindAccountByPhone(r.Context(), request.Phone); findErr != nil {
		writeAPIError(w, r, findErr)
		return
	} else if found {
		key := r.Header.Get("Idempotency-Key")
		if strings.TrimSpace(key) != "" {
			result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
				if err := s.Auth.VerifyCode(ctx, request.VerificationID, request.Phone, request.Code); err != nil {
					return 0, nil, nil, err
				}
				return s.issueSessionResponse(ctx, tx, r, account, ownerID, request.Phone)
			})
			if err != nil {
				writeAPIError(w, r, err)
				return
			}
			writeStored(w, r, result)
			return
		}
	}

	// First-time or non-idempotent path: verify before any account write.
	if err := s.Auth.VerifyCode(r.Context(), request.VerificationID, request.Phone, request.Code); err != nil {
		writeAPIError(w, r, err)
		return
	}
	account, ownerID, err := s.Store.EnsureAccount(r.Context(), request.Phone)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "login-" + ownerID.String() + "-" + request.VerificationID.String()
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		// Challenge already consumed above; only issue tokens + principal.
		return s.issueSessionResponse(ctx, tx, r, account, ownerID, request.Phone)
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) issueSessionResponse(
	ctx context.Context,
	tx pgx.Tx,
	r *http.Request,
	account domain.Account,
	ownerID uuid.UUID,
	phone string,
) (int, any, map[string]string, error) {
	principal, organization, err := store.ResolveLoginPrincipalTx(ctx, tx, ownerID, phone)
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

func (s *Server) refreshSession(w http.ResponseWriter, r *http.Request) {
	var request refreshRequest
	payload, err := decodeBody(r, &request)
	if err != nil || request.RefreshToken == "" {
		writeAPIError(w, r, validationError("refresh_token", "刷新令牌不能为空"))
		return
	}
	accountID, err := s.Auth.OwnerForRefresh(r.Context(), request.RefreshToken)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	account, err := s.Store.GetAccount(r.Context(), accountID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	result, err := s.Store.RunIdempotent(r.Context(), accountID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		principal, organization, err := store.ResolvePrincipalContextTx(
			ctx,
			tx,
			accountID,
		)
		if err != nil {
			return 0, nil, nil, err
		}
		accessToken, nextRefreshToken, err := s.Auth.RefreshTx(ctx, tx, request.RefreshToken)
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusCreated, envelope(r, map[string]any{
			"token_type":           "Bearer",
			"access_token":         accessToken,
			"expires_in_seconds":   3600,
			"refresh_token":        nextRefreshToken,
			"account":              account,
			"current_organization": organization,
			"member_role":          principal.Role,
			"capabilities":         principalCapabilities(principal.Role),
		}), map[string]string{}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) deleteSession(w http.ResponseWriter, r *http.Request) {
	ownerID, accessToken, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	var body logoutRequest
	// Body is optional; when present, revoke the provided refresh token family.
	if r.Body != nil && r.ContentLength != 0 {
		_, _ = decodeBody(r, &body)
	}
	refreshToken := strings.TrimSpace(body.RefreshToken)
	if refreshToken == "" {
		refreshToken = strings.TrimSpace(r.Header.Get("X-Refresh-Token"))
	}
	// Revocation must never run behind a stored-response cache: a replayed 204
	// would report success while leaving the token family live.
	if err := s.Auth.RevokeAccess(r.Context(), accessToken); err != nil {
		writeAPIError(w, r, err)
		return
	}
	if refreshToken != "" {
		if err := s.Auth.RevokeRefresh(r.Context(), refreshToken); err != nil {
			writeAPIError(w, r, err)
			return
		}
	} else {
		// Without a refresh token in the request, revoke all active sessions for this account.
		if err := s.Auth.RevokeAllRefreshForOwner(r.Context(), ownerID); err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	w.Header().Set("Idempotency-Key", r.Header.Get("Idempotency-Key"))
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) getMe(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	principal, ok := principalFromRequest(r)
	if !ok {
		accountID, parseErr := s.Auth.ParseAccessToken(
			strings.TrimSpace(strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ")),
		)
		if parseErr != nil {
			writeAPIError(w, r, authRequired())
			return
		}
		resolvedPrincipal, resolveErr := s.Store.ResolvePrincipal(r.Context(), accountID)
		if resolveErr != nil {
			writeAPIError(w, r, resolveErr)
			return
		}
		principal = resolvedPrincipal
	}
	account, err := s.Store.GetAccount(r.Context(), principal.AccountID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	organization, err := s.Store.GetCurrentOrganization(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"account":              account,
		"current_organization": organization,
		"member_role":          principal.Role,
		"capabilities":         principalCapabilities(principal.Role),
	}))
}

func (s *Server) getOrganization(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	organization, err := s.Store.GetCurrentOrganization(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(organization.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, organization))
}

func (s *Server) patchOrganization(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	var request store.OrganizationUpdate
	payload, err := decodeBody(r, &request)
	if err != nil || request.Name == nil && request.Mode == nil && request.Timezone == nil {
		writeAPIError(w, r, validationError("organization", "至少填写一项熊舍资料"))
		return
	}
	result, err := s.Store.UpdateOrganization(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), r.Header.Get("If-Match"), payload, request, func(organization domain.Organization) any {
		return envelope(r, organization)
	}, r.URL.Path)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) listSystemRules(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	_ = ownerID
	rules, err := s.Store.ListRules(r.Context(), nil)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, rules))
}

func (s *Server) listOwnerRules(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	rules, err := s.Store.ListRules(r.Context(), &ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, rules))
}

func (s *Server) createOwnerRule(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	var request store.RuleCopyRequest
	payload, err := decodeBody(r, &request)
	if err != nil || !validRuleCopyRequest(request) {
		writeAPIError(w, r, validationError("rule", "规则请求体格式不正确"))
		return
	}
	result, err := s.Store.CopyRule(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), request, payload, func(rule domain.SpeciesRuleVersion) any {
		return envelope(r, rule)
	}, r.URL.Path)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func validRuleCopyRequest(request store.RuleCopyRequest) bool {
	if strings.TrimSpace(request.SpeciesCode) == "" ||
		request.GestationMinDays < 1 ||
		request.GestationMaxDays < request.GestationMinDays ||
		request.WeaningTargetDays < 1 ||
		request.SexingTargetDays < 1 ||
		request.SeparationTargetDays < 1 ||
		strings.TrimSpace(request.SourceNote) == "" ||
		request.EffectiveAt.IsZero() {
		return false
	}
	if request.PairingMaxMinutes != nil && *request.PairingMaxMinutes < 1 {
		return false
	}
	if request.PostBreedingRestDays != nil && *request.PostBreedingRestDays < 0 {
		return false
	}
	if request.ProfileCreationDeadlineDays != nil && *request.ProfileCreationDeadlineDays < 0 {
		return false
	}
	return true
}

func (s *Server) getRule(w http.ResponseWriter, r *http.Request) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	ruleID, err := uuid.Parse(r.PathValue("rule_version_id"))
	if err != nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	rule, err := s.Store.GetRule(r.Context(), ownerID, ruleID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(rule.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, rule))
}

func (s *Server) authenticate(r *http.Request) (uuid.UUID, string, bool) {
	value := strings.TrimSpace(r.Header.Get("Authorization"))
	if len(value) < 8 || !strings.EqualFold(value[:7], "Bearer ") {
		return uuid.Nil, "", false
	}
	token := strings.TrimSpace(value[7:])
	accountID, err := s.Auth.ParseAccessTokenContext(r.Context(), token)
	if err != nil {
		return uuid.Nil, token, false
	}
	principal, err := s.resolveRequestPrincipal(r, accountID)
	if err != nil {
		return uuid.Nil, token, false
	}
	if _, ok := principalFromRequest(r); !ok {
		ctx := context.WithValue(
			r.Context(),
			requestPrincipalContextKey{},
			principal,
		)
		*r = *r.WithContext(ctx)
	}
	return principal.OwnerID, token, true
}

func decodeBody(r *http.Request, target any) ([]byte, error) {
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return nil, err
	}
	return json.Marshal(target)
}

func envelope(r *http.Request, data any) map[string]any {
	return map[string]any{"data": data, "meta": responseMeta(r)}
}

func listEnvelope(r *http.Request, data any) map[string]any {
	count := 0
	if values, ok := data.([]domain.SpeciesRuleVersion); ok {
		count = len(values)
	}
	return map[string]any{
		"data": data,
		"page": map[string]any{"next_cursor": nil, "has_more": false, "count": count},
		"meta": responseMeta(r),
	}
}

func responseMeta(r *http.Request) meta {
	timezone := r.Header.Get("X-Timezone")
	if timezone == "" {
		timezone = "Asia/Shanghai"
	}
	return meta{RequestID: r.Header.Get("X-Request-ID"), GeneratedAt: time.Now().UTC(), Timezone: timezone}
}

func requestIDMiddleware(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requestID := r.Header.Get("X-Request-ID")
		if requestID == "" {
			requestID = "req_" + uuid.NewString()
		}
		r.Header.Set("X-Request-ID", requestID)
		w.Header().Set("X-Request-ID", requestID)
		start := time.Now()
		next.ServeHTTP(w, r)
		if logger != nil {
			logger.Info("http request", "request_id", requestID, "method", r.Method, "path", r.URL.Path, "duration_ms", time.Since(start).Milliseconds())
		}
	})
}

func writeStored(w http.ResponseWriter, r *http.Request, result store.IdempotentResult) {
	for key, value := range result.Headers {
		w.Header().Set(key, value)
	}
	w.Header().Set("Idempotency-Key", r.Header.Get("Idempotency-Key"))
	w.Header().Set("Idempotency-Replayed", fmt.Sprintf("%t", result.Replayed))
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(result.Status)
	if result.Status != http.StatusNoContent {
		_, _ = w.Write(result.Body)
	}
}

func writeJSON(w http.ResponseWriter, r *http.Request, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

type apiError struct {
	Status  int
	Code    string
	Message string
	Details map[string]any
}

func (e *apiError) Error() string { return e.Code + ": " + e.Message }

func validationError(field, message string) error {
	return &apiError{Status: http.StatusUnprocessableEntity, Code: "VALIDATION_ERROR", Message: message, Details: map[string]any{"field": field}}
}

func conflictError(field, message string) error {
	return &apiError{Status: http.StatusConflict, Code: "CONFLICT", Message: message, Details: map[string]any{"field": field}}
}

func rateLimitedError(retryAfterSeconds int) error {
	if retryAfterSeconds < 1 {
		retryAfterSeconds = 1
	}
	return &apiError{
		Status:  http.StatusTooManyRequests,
		Code:    "RATE_LIMITED",
		Message: "请求过于频繁，请稍后再试",
		Details: map[string]any{"retry_after_seconds": retryAfterSeconds},
	}
}

func (s *Server) enforceRateLimit(ctx context.Context, bucketKey string, cooldown time.Duration, maxPerWindow int, window time.Duration) (int, error) {
	if s.RateLimiter != nil {
		return s.RateLimiter.CheckAndHit(ctx, bucketKey, cooldown, maxPerWindow, window, time.Now().UTC())
	}
	return s.Auth.EnforceRateLimit(ctx, bucketKey, cooldown, maxPerWindow, window)
}

func isRateLimitError(err error) bool {
	return errors.Is(err, auth.ErrRateLimited) || errors.Is(err, ratelimit.ErrRateLimited)
}

func authRequired() error {
	return &apiError{Status: http.StatusUnauthorized, Code: "AUTHENTICATION_REQUIRED", Message: "请重新登录"}
}

// clientIP resolves the caller address for rate-limit bucket keys. Forwarded
// headers are client-forgeable, so they are honoured only when the direct
// peer is inside TrustedProxies, and even then the chain is walked right to
// left (rightmost hops are appended by our own proxies). Every return value
// is a parsed IP, which also bounds the bucket-key length.
func (s *Server) clientIP(r *http.Request) string {
	peer, ok := parseRemoteAddr(r.RemoteAddr)
	if !ok {
		return "unknown"
	}
	if !ipInPrefixes(peer, s.TrustedProxies) {
		return peer.String()
	}
	forwarded := strings.Split(r.Header.Get("X-Forwarded-For"), ",")
	for i := len(forwarded) - 1; i >= 0; i-- {
		hop, err := netip.ParseAddr(strings.TrimSpace(forwarded[i]))
		if err != nil {
			continue
		}
		if !ipInPrefixes(hop, s.TrustedProxies) {
			return hop.Unmap().String()
		}
	}
	if realIP, err := netip.ParseAddr(strings.TrimSpace(r.Header.Get("X-Real-IP"))); err == nil {
		return realIP.Unmap().String()
	}
	return peer.String()
}

func parseRemoteAddr(remoteAddr string) (netip.Addr, bool) {
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		host = remoteAddr
	}
	ip, err := netip.ParseAddr(strings.TrimSpace(host))
	if err != nil {
		return netip.Addr{}, false
	}
	return ip.Unmap(), true
}

func ipInPrefixes(ip netip.Addr, prefixes []netip.Prefix) bool {
	for _, prefix := range prefixes {
		if prefix.Contains(ip.Unmap()) {
			return true
		}
	}
	return false
}

func permissionDenied(role string) error {
	return &apiError{
		Status:  http.StatusForbidden,
		Code:    "PERMISSION_DENIED",
		Message: "当前角色没有执行此操作的权限",
		Details: map[string]any{"member_role": role},
	}
}

func writeAPIError(w http.ResponseWriter, r *http.Request, err error) {
	status, code, message := http.StatusInternalServerError, "INTERNAL_ERROR", "服务暂时不可用"
	details := map[string]any{}
	var typed *apiError
	if errors.As(err, &typed) {
		status, code, message, details = typed.Status, typed.Code, typed.Message, typed.Details
	} else {
		switch {
		case errors.Is(err, store.ErrNotFound):
			status, code, message = http.StatusNotFound, "RESOURCE_NOT_FOUND", "资源不存在"
		case errors.Is(err, store.ErrIdempotencyKeyRequired):
			status, code, message = http.StatusBadRequest, "IDEMPOTENCY_KEY_REQUIRED", "写请求需要幂等键"
		case errors.Is(err, store.ErrIdempotencyPayloadMismatch):
			status, code, message = http.StatusConflict, "IDEMPOTENCY_PAYLOAD_MISMATCH", "幂等键对应的载荷不一致"
		case errors.Is(err, store.ErrIdempotencyInProgress):
			status, code, message = http.StatusConflict, "IDEMPOTENCY_IN_PROGRESS", "相同写请求正在处理中"
		case errors.Is(err, store.ErrVersionConflict) || strings.Contains(err.Error(), store.ErrVersionConflict.Error()):
			status, code, message = http.StatusConflict, "VERSION_CONFLICT", "资源版本已变化，请刷新后重试"
			details["current_version"] = extractCurrentVersion(err.Error())
		case errors.Is(err, auth.ErrInvalidCode):
			status, code, message = http.StatusUnauthorized, "VERIFICATION_CODE_INVALID", "验证码不正确"
		case errors.Is(err, auth.ErrVerification):
			status, code, message = http.StatusUnauthorized, "VERIFICATION_CHALLENGE_INVALID", "验证码会话已失效"
		case errors.Is(err, auth.ErrInvalidRefresh):
			status, code, message = http.StatusUnauthorized, "REFRESH_TOKEN_INVALID", "会话已失效，请重新登录"
		case errors.Is(err, auth.ErrInvalidToken), errors.Is(err, auth.ErrExpiredToken), errors.Is(err, auth.ErrRevokedToken):
			status, code, message = http.StatusUnauthorized, "AUTHENTICATION_REQUIRED", "请重新登录"
		case isRateLimitError(err):
			status, code, message = http.StatusTooManyRequests, "RATE_LIMITED", "请求过于频繁，请稍后再试"
		default:
			if strings.Contains(err.Error(), "duplicate") || strings.Contains(err.Error(), "unique") {
				status, code, message = http.StatusConflict, "CONFLICT", "资源状态冲突"
			}
		}
	}
	if status == http.StatusTooManyRequests {
		if retry, ok := details["retry_after_seconds"].(int); ok && retry > 0 {
			w.Header().Set("Retry-After", fmt.Sprintf("%d", retry))
		}
	}
	payload := map[string]any{
		"error": map[string]any{
			"code":             code,
			"message":          message,
			"field_errors":     []any{},
			"recovery_actions": []any{},
			"details":          details,
		},
		"meta": responseMeta(r),
	}
	writeJSON(w, r, status, payload)
}

func writeStoredError(_ http.ResponseWriter, _ *http.Request, _ error) {}

func extractCurrentVersion(message string) int {
	match := regexp.MustCompile(`current=([0-9]+)`).FindStringSubmatch(message)
	if len(match) == 2 {
		var version int
		_, _ = fmt.Sscanf(match[1], "%d", &version)
		return version
	}
	return 0
}

var phonePattern = regexp.MustCompile(`^\+86[1-9][0-9]{10}$`)
var codePattern = regexp.MustCompile(`^[0-9]{6}$`)
