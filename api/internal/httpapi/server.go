package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/domain"
	"github.com/scolvpet/scolvpet/api/internal/objectstore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

type Server struct {
	Store         *store.Store
	Auth          *auth.Service
	Logger        *slog.Logger
	ImportObjects objectstore.ObjectStore
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
	return &Server{Store: store, Auth: authService, Logger: logger, ImportObjects: objects}
}

func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", s.health)
	mux.HandleFunc("GET /readyz", s.ready)
	mux.HandleFunc("POST /v1/auth/verification-codes", s.sendVerificationCode)
	mux.HandleFunc("POST /v1/auth/sessions", s.createSession)
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
	return requestIDMiddleware(s.Logger, mux)
}

func (s *Server) health(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, r, http.StatusOK, map[string]any{"status": "ok", "service": "scolvpet-api"})
}

func (s *Server) ready(w http.ResponseWriter, r *http.Request) {
	if err := s.Store.Ping(r.Context()); err != nil {
		writeJSON(w, r, http.StatusServiceUnavailable, map[string]any{"status": "not_ready", "error": "database unavailable"})
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"status": "ready"})
}

func (s *Server) sendVerificationCode(w http.ResponseWriter, r *http.Request) {
	var request verificationRequest
	payload, err := decodeBody(r, &request)
	if err != nil || !phonePattern.MatchString(request.Phone) || request.Purpose != "login" {
		writeAPIError(w, r, validationError("phone/purpose", "请输入有效的中国大陆手机号和 login 用途"))
		return
	}
	_, ownerID, err := s.Store.EnsureAccount(r.Context(), request.Phone)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	key := r.Header.Get("Idempotency-Key")
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, _ pgx.Tx) (int, any, map[string]string, error) {
		challenge := s.Auth.RequestCode(request.Phone)
		return http.StatusAccepted, envelope(r, map[string]any{
			"verification_id":     challenge.ID,
			"expires_in_seconds":  300,
			"retry_after_seconds": 60,
		}), map[string]string{}, nil
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
	account, ownerID, err := s.Store.EnsureAccount(r.Context(), request.Phone)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	key := r.Header.Get("Idempotency-Key")
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		if err := s.Auth.VerifyCode(request.VerificationID, request.Phone, request.Code); err != nil {
			return 0, nil, nil, err
		}
		organization, err := store.EnsureOrganizationTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		accessToken, refreshToken := s.Auth.CreateSession(ownerID)
		return http.StatusCreated, envelope(r, map[string]any{
			"token_type":           "Bearer",
			"access_token":         accessToken,
			"expires_in_seconds":   3600,
			"refresh_token":        refreshToken,
			"account":              account,
			"current_organization": organization,
		}), map[string]string{}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) refreshSession(w http.ResponseWriter, r *http.Request) {
	var request refreshRequest
	payload, err := decodeBody(r, &request)
	if err != nil || request.RefreshToken == "" {
		writeAPIError(w, r, validationError("refresh_token", "刷新令牌不能为空"))
		return
	}
	ownerID, err := s.Auth.OwnerForRefresh(request.RefreshToken)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	account, err := s.Store.GetAccount(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		organization, err := store.EnsureOrganizationTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		accessToken, nextRefreshToken, err := s.Auth.Refresh(request.RefreshToken)
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
	payload := []byte(`{"action":"logout"}`)
	result, err := s.Store.RunIdempotent(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodDelete, r.URL.Path, payload, func(context.Context, pgx.Tx) (int, any, map[string]string, error) {
		s.Auth.Revoke(accessToken)
		return http.StatusNoContent, nil, map[string]string{}, nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	for key, value := range result.Headers {
		w.Header().Set(key, value)
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
	account, err := s.Store.GetAccount(r.Context(), ownerID)
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
		"capabilities":         []string{"owner_scope", "species_rules", "offline_read_cache"},
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
	ownerID, err := s.Auth.ParseAccessToken(token)
	return ownerID, token, err == nil
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

func authRequired() error {
	return &apiError{Status: http.StatusUnauthorized, Code: "AUTHENTICATION_REQUIRED", Message: "请重新登录"}
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
		default:
			if strings.Contains(err.Error(), "duplicate") || strings.Contains(err.Error(), "unique") {
				status, code, message = http.StatusConflict, "CONFLICT", "资源状态冲突"
			}
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
