package httpapi

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerCustomerRoutes(mux *http.ServeMux) {
	mux.HandleFunc("POST /v1/public/customer/verification-codes", s.sendCustomerVerificationCode)
	mux.HandleFunc("POST /v1/public/customer/sessions", s.createCustomerSession)
	mux.HandleFunc("POST /v1/public/customer/wechat-sessions", s.createCustomerWechatSession)
	mux.HandleFunc("POST /v1/public/customer/wechat-bindings", s.createCustomerWechatBinding)
	mux.HandleFunc("DELETE /v1/customer/wechat-bindings/current", s.deleteCustomerWechatBinding)
	mux.HandleFunc("DELETE /v1/customer/sessions/current", s.deleteCustomerSession)
	mux.HandleFunc("GET /v1/customer/reservations", s.listCustomerReservations)
	mux.HandleFunc("GET /v1/customer/reservations/{reservation_id}", s.getCustomerReservation)
	mux.HandleFunc("POST /v1/customer/reservations/{reservation_id}/cancel", s.cancelCustomerReservation)
}

type customerSessionRequest struct {
	Phone          string    `json:"phone"`
	VerificationID uuid.UUID `json:"verification_id"`
	Code           string    `json:"code"`
}

func (s *Server) sendCustomerVerificationCode(w http.ResponseWriter, r *http.Request) {
	var request verificationRequest
	payload, err := decodeBody(r, &request)
	if err != nil || !phonePattern.MatchString(request.Phone) {
		writeAPIError(w, r, validationError("phone", "请输入有效的中国大陆手机号"))
		return
	}
	// Reuse login purpose challenges; do not create staff accounts.
	request.Purpose = "login"
	key := r.Header.Get("Idempotency-Key")
	if strings.TrimSpace(key) == "" {
		key = "cust-code-" + request.Phone
	}
	result, err := s.Store.RunPublicIdempotent(r.Context(), key, http.MethodPost, r.URL.Path, payload, func(ctx context.Context) (int, any, error) {
		phoneCooldown := 60 * time.Second
		phoneMax := 5
		ipMax := 20
		retryHint := 60
		if env := strings.ToLower(strings.TrimSpace(s.Environment)); env == "" || env == "development" || env == "test" {
			phoneCooldown = 0
			retryHint = 1
		}
		if retry, err := s.enforceRateLimit(ctx, "cust-sms:phone:"+request.Phone, phoneCooldown, phoneMax, time.Hour); err != nil {
			if isRateLimitError(err) {
				return 0, nil, rateLimitedError(retry)
			}
			return 0, nil, err
		}
		if retry, err := s.enforceRateLimit(ctx, "cust-sms:ip:"+s.clientIP(r), 0, ipMax, time.Hour); err != nil {
			if isRateLimitError(err) {
				return 0, nil, rateLimitedError(retry)
			}
			return 0, nil, err
		}
		challenge, err := s.Auth.RequestCode(ctx, request.Phone)
		if err != nil {
			return 0, nil, err
		}
		return http.StatusAccepted, envelope(r, map[string]any{
			"verification_id":     challenge.ID,
			"expires_in_seconds":  300,
			"retry_after_seconds": retryHint,
		}), nil
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) createCustomerSession(w http.ResponseWriter, r *http.Request) {
	var request customerSessionRequest
	if _, err := decodeBody(r, &request); err != nil || !phonePattern.MatchString(request.Phone) || !codePattern.MatchString(request.Code) || request.VerificationID == uuid.Nil {
		writeAPIError(w, r, validationError("login", "请输入完整的客户验证码登录信息"))
		return
	}
	if err := s.Auth.VerifyCode(r.Context(), request.VerificationID, request.Phone, request.Code); err != nil {
		writeAPIError(w, r, err)
		return
	}
	rawToken := "ct_" + uuid.NewString()
	hash := sha256Hex(rawToken)
	expires := time.Now().UTC().Add(30 * 24 * time.Hour)
	_, err := s.Store.Pool.Exec(r.Context(), `
		INSERT INTO customer_session (phone, token_sha256, expires_at)
		VALUES ($1, $2, $3)
	`, request.Phone, hash, expires)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, envelope(r, map[string]any{
		"token_type":         "Bearer",
		"access_token":       rawToken,
		"expires_in_seconds": int(30 * 24 * time.Hour / time.Second),
		"phone":              request.Phone,
	}))
}

type customerPrincipal struct {
	Phone string
	ID    uuid.UUID
}

func (s *Server) authenticateCustomer(r *http.Request) (customerPrincipal, bool) {
	value := strings.TrimSpace(r.Header.Get("Authorization"))
	token := ""
	if len(value) >= 8 && strings.EqualFold(value[:7], "Bearer ") {
		token = strings.TrimSpace(value[7:])
	}
	if token == "" {
		token = strings.TrimSpace(r.Header.Get("X-Customer-Token"))
	}
	if token == "" || !strings.HasPrefix(token, "ct_") {
		return customerPrincipal{}, false
	}
	hash := sha256Hex(token)
	var phone string
	var id uuid.UUID
	var expires time.Time
	var revoked *time.Time
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT id, phone, expires_at, revoked_at
		FROM customer_session
		WHERE token_sha256=$1
	`, hash).Scan(&id, &phone, &expires, &revoked)
	if err != nil || revoked != nil || !time.Now().UTC().Before(expires) {
		return customerPrincipal{}, false
	}
	_, _ = s.Store.Pool.Exec(r.Context(), `
		UPDATE customer_session SET last_used_at=now() WHERE id=$1
	`, id)
	return customerPrincipal{Phone: phone, ID: id}, true
}

func (s *Server) listCustomerReservations(w http.ResponseWriter, r *http.Request) {
	principal, ok := s.authenticateCustomer(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	items, err := s.loadCustomerReservations(r.Context(), principal.Phone, uuid.Nil)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, items))
}

func (s *Server) getCustomerReservation(w http.ResponseWriter, r *http.Request) {
	principal, ok := s.authenticateCustomer(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	reservationID, err := uuid.Parse(r.PathValue("reservation_id"))
	if err != nil || reservationID == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	items, err := s.loadCustomerReservations(r.Context(), principal.Phone, reservationID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if len(items) == 0 {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, items[0]))
}

func (s *Server) deleteCustomerSession(w http.ResponseWriter, r *http.Request) {
	principal, ok := s.authenticateCustomer(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	_, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE customer_session
		SET revoked_at=now()
		WHERE id=$1 AND revoked_at IS NULL
	`, principal.ID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) cancelCustomerReservation(w http.ResponseWriter, r *http.Request) {
	principal, ok := s.authenticateCustomer(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return
	}
	reservationID, err := uuid.Parse(r.PathValue("reservation_id"))
	if err != nil || reservationID == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	var status string
	var phone *string
	err = s.Store.Pool.QueryRow(r.Context(), `
		SELECT r.status::text, c.phone
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		WHERE r.id=$1
	`, reservationID).Scan(&status, &phone)
	if errors.Is(err, pgx.ErrNoRows) {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if phone == nil || *phone != principal.Phone {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if status != "held" {
		writeAPIError(w, r, conflictError("status", "仅待确认预订可取消"))
		return
	}
	tag, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE crm_reservation
		SET status='cancelled', version=version+1, updated_at=now(),
		    notes = CASE
		      WHEN notes IS NULL OR btrim(notes)='' THEN '客户主动取消'
		      ELSE notes || E'\n客户主动取消'
		    END
		WHERE id=$1 AND status='held'
	`, reservationID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() != 1 {
		// Concurrent confirm/cancel — surface real status.
		items, loadErr := s.loadCustomerReservations(r.Context(), principal.Phone, reservationID)
		if loadErr == nil && len(items) > 0 {
			writeAPIError(w, r, conflictError("status", "预订状态已变化，无法取消"))
			return
		}
		writeAPIError(w, r, conflictError("status", "预订状态已变化，无法取消"))
		return
	}
	items, err := s.loadCustomerReservations(r.Context(), principal.Phone, reservationID)
	if err != nil || len(items) == 0 {
		writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{"id": reservationID, "status": "cancelled"}))
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, items[0]))
}

func (s *Server) loadCustomerReservations(ctx context.Context, phone string, onlyID uuid.UUID) ([]map[string]any, error) {
	// Lazy expiry before listing.
	_, _ = s.ReleaseExpiredReservationHolds(ctx)
	query := `
		SELECT r.id, r.owner_id, r.title, r.status::text, r.reserved_at, r.hold_expires_at, r.updated_at,
		       r.hamster_id, COALESCE(p.public_name, h.name, ''), COALESCE(p.summary,''),
		       COALESCE(p.price_label,''), r.version
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		LEFT JOIN hamster h ON h.owner_id=r.owner_id AND h.id=r.hamster_id
		LEFT JOIN hamster_public_profile p ON p.owner_id=r.owner_id AND p.hamster_id=r.hamster_id
		WHERE c.phone=$1
	`
	args := []any{phone}
	if onlyID != uuid.Nil {
		query += ` AND r.id=$2`
		args = append(args, onlyID)
	}
	query += ` ORDER BY r.reserved_at DESC, r.id DESC LIMIT 100`
	rows, err := s.Store.Pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items := make([]map[string]any, 0)
	for rows.Next() {
		var (
			id, ownerID                                    uuid.UUID
			title, status, publicName, summary, priceLabel string
			reservedAt, updatedAt                          time.Time
			holdExpires                                    *time.Time
			hamsterID                                      *uuid.UUID
			version                                        int
		)
		if err := rows.Scan(&id, &ownerID, &title, &status, &reservedAt, &holdExpires, &updatedAt, &hamsterID, &publicName, &summary, &priceLabel, &version); err != nil {
			return nil, err
		}
		// Document public tokens for this reservation if any.
		docLinks := s.customerDocumentLinks(ctx, ownerID, id)
		item := map[string]any{
			"id": id, "title": title, "status": status,
			"reserved_at": reservedAt, "hold_expires_at": holdExpires, "updated_at": updatedAt,
			"version": version,
			"hamster": map[string]any{
				"hamster_id": hamsterID, "public_name": publicName, "summary": summary, "price_label": priceLabel,
			},
			"documents": docLinks,
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (s *Server) customerDocumentLinks(ctx context.Context, ownerID, reservationID uuid.UUID) []map[string]any {
	// Strict isolation: only documents explicitly bound to this reservation.
	// Legacy rows without reservation_id are not exposed on the customer surface.
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT d.id, d.kind::text, d.public_token, d.status::text
		FROM doc_document d
		JOIN crm_reservation r ON r.owner_id=d.owner_id AND r.id=d.reservation_id
		WHERE d.owner_id=$1
		  AND d.reservation_id=$2
		  AND d.contact_id=r.contact_id
		  AND d.public_token IS NOT NULL
		  AND d.status='issued'
		ORDER BY d.created_at DESC
		LIMIT 20
	`, ownerID, reservationID)
	if err != nil {
		return []map[string]any{}
	}
	defer rows.Close()
	out := make([]map[string]any, 0)
	for rows.Next() {
		var id uuid.UUID
		var docType, token, status string
		if err := rows.Scan(&id, &docType, &token, &status); err != nil {
			return out
		}
		out = append(out, map[string]any{
			"id": id, "doc_type": docType, "status": status,
			"public_token": token,
			"web_path":     fmt.Sprintf("/d/%s", token),
		})
	}
	return out
}

func sha256Hex(value string) string {
	sum := sha256.Sum256([]byte(value))
	return hex.EncodeToString(sum[:])
}
