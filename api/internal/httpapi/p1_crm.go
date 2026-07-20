package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP1CrmRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/crm/contacts", s.listCrmContacts)
	mux.HandleFunc("POST /v1/crm/contacts", s.createCrmContact)
	mux.HandleFunc("GET /v1/crm/reservations", s.listCrmReservations)
	mux.HandleFunc("POST /v1/crm/reservations", s.createCrmReservation)
	mux.HandleFunc("POST /v1/crm/reservations/{reservation_id}/confirm", s.confirmCrmReservation)
	mux.HandleFunc("POST /v1/crm/reservations/{reservation_id}/cancel", s.cancelCrmReservation)
	mux.HandleFunc("GET /v1/crm/handovers", s.listCrmHandovers)
	mux.HandleFunc("POST /v1/crm/handovers", s.createCrmHandover)
	mux.HandleFunc("POST /v1/crm/handovers/{handover_id}/complete", s.completeCrmHandover)
}

type crmContact struct {
	ID      uuid.UUID `json:"id"`
	Name    string    `json:"name"`
	Phone   *string   `json:"phone,omitempty"`
	Wechat  *string   `json:"wechat,omitempty"`
	Notes   *string   `json:"notes,omitempty"`
	Status  string    `json:"status"`
	Version int       `json:"version"`
}

type crmReservation struct {
	ID          uuid.UUID  `json:"id"`
	ContactID   uuid.UUID  `json:"contact_id"`
	HamsterID   *uuid.UUID `json:"hamster_id,omitempty"`
	Title       string     `json:"title"`
	Status      string     `json:"status"`
	ReservedAt  time.Time  `json:"reserved_at"`
	Notes       *string    `json:"notes,omitempty"`
	Version     int        `json:"version"`
	ContactName string     `json:"contact_name,omitempty"`
	HamsterName *string    `json:"hamster_name,omitempty"`
}

type crmHandover struct {
	ID          uuid.UUID  `json:"id"`
	ContactID   uuid.UUID  `json:"contact_id"`
	Reservation *uuid.UUID `json:"reservation_id,omitempty"`
	HamsterID   *uuid.UUID `json:"hamster_id,omitempty"`
	Status      string     `json:"status"`
	ScheduledAt time.Time  `json:"scheduled_at"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
	Notes       *string    `json:"notes,omitempty"`
	Version     int        `json:"version"`
	ContactName string     `json:"contact_name,omitempty"`
	HamsterName *string    `json:"hamster_name,omitempty"`
}

type createContactRequest struct {
	Name   string  `json:"name"`
	Phone  *string `json:"phone"`
	Wechat *string `json:"wechat"`
	Notes  *string `json:"notes"`
	Status string  `json:"status"`
}

type createReservationRequest struct {
	ContactID string  `json:"contact_id"`
	HamsterID *string `json:"hamster_id"`
	Title     string  `json:"title"`
	Notes     *string `json:"notes"`
}

type createHandoverRequest struct {
	ContactID     string  `json:"contact_id"`
	ReservationID *string `json:"reservation_id"`
	HamsterID     *string `json:"hamster_id"`
	Notes         *string `json:"notes"`
	ScheduledAt   *string `json:"scheduled_at"`
}

func (s *Server) listCrmContacts(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, name, phone, wechat, notes, status::text, version
		FROM crm_contact
		WHERE owner_id=$1 AND status <> 'archived'
		ORDER BY updated_at DESC, id DESC
		LIMIT 200
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]crmContact, 0)
	for rows.Next() {
		var item crmContact
		if err := rows.Scan(&item.ID, &item.Name, &item.Phone, &item.Wechat, &item.Notes, &item.Status, &item.Version); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createCrmContact(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createContactRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "客户请求体格式不正确"))
		return
	}
	name := strings.TrimSpace(request.Name)
	if name == "" {
		writeAPIError(w, r, validationError("name", "客户名称必填"))
		return
	}
	status := strings.TrimSpace(request.Status)
	if status == "" {
		status = "lead"
	}
	if status != "lead" && status != "active" && status != "archived" {
		writeAPIError(w, r, validationError("status", "客户状态无效"))
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	phone := normalizeCrmPhone(derefString(request.Phone))
	wechat := normalizeCrmWechat(derefString(request.Wechat))
	tx, err := s.Store.Pool.Begin(r.Context())
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer tx.Rollback(r.Context())
	resolved, err := s.resolveOrCreateCrmContactTx(r.Context(), tx, ownerID, orgID, resolveCrmContactInput{
		Name:   name,
		Phone:  phone,
		Wechat: wechat,
		Notes:  request.Notes,
		Status: status,
	})
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := tx.Commit(r.Context()); err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getCrmContact(r.Context(), ownerID, resolved.ID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	// 201 新建；200 复用已有客户（同一 phone/wechat）。
	statusCode := http.StatusCreated
	if !resolved.Created {
		statusCode = http.StatusOK
	}
	writeJSON(w, r, statusCode, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listCrmReservations(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT r.id, r.contact_id, r.hamster_id, r.title, r.status::text, r.reserved_at, r.notes, r.version,
			c.name,
			CASE WHEN h.id IS NULL THEN NULL ELSE COALESCE(NULLIF(h.name,''), h.internal_code) END
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		LEFT JOIN hamster h ON h.owner_id=r.owner_id AND h.id=r.hamster_id AND h.deleted_at IS NULL
		WHERE r.owner_id=$1 AND r.status <> 'cancelled'
		ORDER BY r.reserved_at DESC, r.id DESC
		LIMIT 200
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]crmReservation, 0)
	for rows.Next() {
		var item crmReservation
		if err := rows.Scan(&item.ID, &item.ContactID, &item.HamsterID, &item.Title, &item.Status, &item.ReservedAt, &item.Notes, &item.Version, &item.ContactName, &item.HamsterName); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createCrmReservation(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createReservationRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "预订请求体格式不正确"))
		return
	}
	contactID, err := uuid.Parse(strings.TrimSpace(request.ContactID))
	if err != nil || contactID == uuid.Nil {
		writeAPIError(w, r, validationError("contact_id", "客户无效"))
		return
	}
	title := strings.TrimSpace(request.Title)
	if title == "" {
		title = "预订"
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if _, err := s.getCrmContact(r.Context(), ownerID, contactID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	var hamsterID *uuid.UUID
	if request.HamsterID != nil && strings.TrimSpace(*request.HamsterID) != "" {
		parsed, parseErr := uuid.Parse(strings.TrimSpace(*request.HamsterID))
		if parseErr != nil {
			writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
			return
		}
		hamsterID = &parsed
		if err := s.ensureCrmHamsterOwned(r.Context(), ownerID, parsed); err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO crm_reservation (
			owner_id, organization_id, contact_id, hamster_id, title, status, notes
		) VALUES ($1,$2,$3,$4,$5,'held',$6)
		RETURNING id
	`, ownerID, orgID, contactID, hamsterID, title, emptyToNil(request.Notes)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getCrmReservation(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) confirmCrmReservation(w http.ResponseWriter, r *http.Request) {
	s.transitionCrmReservation(w, r, "confirmed")
}

func (s *Server) cancelCrmReservation(w http.ResponseWriter, r *http.Request) {
	s.transitionCrmReservation(w, r, "cancelled")
}

func (s *Server) transitionCrmReservation(w http.ResponseWriter, r *http.Request, next string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	reservationID, err := uuid.Parse(r.PathValue("reservation_id"))
	if err != nil || reservationID == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	current, err := s.getCrmReservation(r.Context(), ownerID, reservationID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if current.Status == "handed_over" || current.Status == "cancelled" {
		writeAPIError(w, r, validationError("status", "当前预订不可再变更"))
		return
	}
	_, err = s.Store.Pool.Exec(r.Context(), `
		UPDATE crm_reservation
		SET status=$4::crm_reservation_status, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3
	`, ownerID, reservationID, current.Version, next)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getCrmReservation(r.Context(), ownerID, reservationID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listCrmHandovers(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT h.id, h.contact_id, h.reservation_id, h.hamster_id, h.status::text,
			h.scheduled_at, h.completed_at, h.notes, h.version, c.name,
			CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.status <> 'cancelled'
		ORDER BY h.scheduled_at DESC, h.id DESC
		LIMIT 200
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]crmHandover, 0)
	for rows.Next() {
		var item crmHandover
		if err := rows.Scan(&item.ID, &item.ContactID, &item.Reservation, &item.HamsterID, &item.Status, &item.ScheduledAt, &item.CompletedAt, &item.Notes, &item.Version, &item.ContactName, &item.HamsterName); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createCrmHandover(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createHandoverRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "交付请求体格式不正确"))
		return
	}
	contactID, err := uuid.Parse(strings.TrimSpace(request.ContactID))
	if err != nil || contactID == uuid.Nil {
		writeAPIError(w, r, validationError("contact_id", "客户无效"))
		return
	}
	if _, err := s.getCrmContact(r.Context(), ownerID, contactID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var reservationID *uuid.UUID
	var hamsterID *uuid.UUID
	if request.ReservationID != nil && strings.TrimSpace(*request.ReservationID) != "" {
		parsed, parseErr := uuid.Parse(strings.TrimSpace(*request.ReservationID))
		if parseErr != nil {
			writeAPIError(w, r, validationError("reservation_id", "预订 ID 无效"))
			return
		}
		reservationID = &parsed
		reservation, reservationErr := s.getCrmReservation(r.Context(), ownerID, parsed)
		if reservationErr != nil {
			writeAPIError(w, r, reservationErr)
			return
		}
		if reservation.ContactID != contactID {
			writeAPIError(w, r, validationError("reservation_id", "预订不属于所选客户"))
			return
		}
		if request.HamsterID == nil || strings.TrimSpace(*request.HamsterID) == "" {
			hamsterID = reservation.HamsterID
		}
	}
	var parsedHamsterID *uuid.UUID
	if request.HamsterID != nil && strings.TrimSpace(*request.HamsterID) != "" {
		parsed, parseErr := uuid.Parse(strings.TrimSpace(*request.HamsterID))
		if parseErr != nil {
			writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
			return
		}
		parsedHamsterID = &parsed
		if err := s.ensureCrmHamsterOwned(r.Context(), ownerID, parsed); err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	if parsedHamsterID != nil {
		hamsterID = parsedHamsterID
	}
	scheduledAt := time.Now().UTC()
	if request.ScheduledAt != nil && strings.TrimSpace(*request.ScheduledAt) != "" {
		parsed, parseErr := time.Parse(time.RFC3339, strings.TrimSpace(*request.ScheduledAt))
		if parseErr != nil {
			writeAPIError(w, r, validationError("scheduled_at", "时间格式无效"))
			return
		}
		scheduledAt = parsed.UTC()
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO crm_handover (
			owner_id, organization_id, contact_id, reservation_id, hamster_id, status, scheduled_at, notes
		) VALUES ($1,$2,$3,$4,$5,'scheduled',$6,$7)
		RETURNING id
	`, ownerID, orgID, contactID, reservationID, hamsterID, scheduledAt, emptyToNil(request.Notes)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getCrmHandover(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) completeCrmHandover(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	handoverID, err := uuid.Parse(r.PathValue("handover_id"))
	if err != nil || handoverID == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	current, err := s.getCrmHandover(r.Context(), ownerID, handoverID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if current.Status != "scheduled" {
		writeAPIError(w, r, validationError("status", "仅待交付可完成"))
		return
	}
	tx, err := s.Store.Pool.Begin(r.Context())
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer tx.Rollback(r.Context())
	_, err = tx.Exec(r.Context(), `
		UPDATE crm_handover
		SET status='completed', completed_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND version=$3
	`, ownerID, handoverID, current.Version)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if current.HamsterID != nil {
		_, err = tx.Exec(r.Context(), `
			UPDATE hamster
			SET lifecycle_status='transferred', version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, *current.HamsterID)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	if current.Reservation != nil {
		_, err = tx.Exec(r.Context(), `
			UPDATE crm_reservation
			SET status='handed_over', version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND status IN ('held','confirmed')
		`, ownerID, *current.Reservation)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	_, err = tx.Exec(r.Context(), `
		UPDATE crm_contact
		SET status='active', version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='lead'
	`, ownerID, current.ContactID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := tx.Commit(r.Context()); err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getCrmHandover(r.Context(), ownerID, handoverID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) getCrmContact(ctx context.Context, ownerID, id uuid.UUID) (crmContact, error) {
	var item crmContact
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, name, phone, wechat, notes, status::text, version
		FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, id).Scan(&item.ID, &item.Name, &item.Phone, &item.Wechat, &item.Notes, &item.Status, &item.Version)
	if errors.Is(err, pgx.ErrNoRows) {
		return crmContact{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) getCrmReservation(ctx context.Context, ownerID, id uuid.UUID) (crmReservation, error) {
	var item crmReservation
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT r.id, r.contact_id, r.hamster_id, r.title, r.status::text, r.reserved_at, r.notes, r.version, c.name,
			CASE WHEN h.id IS NULL THEN NULL ELSE COALESCE(NULLIF(h.name,''), h.internal_code) END
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		LEFT JOIN hamster h ON h.owner_id=r.owner_id AND h.id=r.hamster_id AND h.deleted_at IS NULL
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, id).Scan(&item.ID, &item.ContactID, &item.HamsterID, &item.Title, &item.Status, &item.ReservedAt, &item.Notes, &item.Version, &item.ContactName, &item.HamsterName)
	if errors.Is(err, pgx.ErrNoRows) {
		return crmReservation{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) getCrmHandover(ctx context.Context, ownerID, id uuid.UUID) (crmHandover, error) {
	var item crmHandover
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT h.id, h.contact_id, h.reservation_id, h.hamster_id, h.status::text,
			h.scheduled_at, h.completed_at, h.notes, h.version, c.name,
			CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.id=$2
	`, ownerID, id).Scan(&item.ID, &item.ContactID, &item.Reservation, &item.HamsterID, &item.Status, &item.ScheduledAt, &item.CompletedAt, &item.Notes, &item.Version, &item.ContactName, &item.HamsterName)
	if errors.Is(err, pgx.ErrNoRows) {
		return crmHandover{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) ensureCrmHamsterOwned(ctx context.Context, ownerID, hamsterID uuid.UUID) error {
	var exists bool
	if err := s.Store.Pool.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM hamster
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		)
	`, ownerID, hamsterID).Scan(&exists); err != nil {
		return err
	}
	if !exists {
		return validationError("hamster_id", "所选仓鼠不存在")
	}
	return nil
}

// resolveCrmContactInput 客户身份解析输入。
// phone / wechat 应已 normalize；至少一项非空时才能稳定去重。
type resolveCrmContactInput struct {
	Name   string
	Phone  string
	Wechat string
	Notes  *string
	// Status 仅在新建时使用；复用已有客户时不降级 active→lead。
	Status string
}

type resolveCrmContactResult struct {
	ID      uuid.UUID
	Created bool
}

// normalizeCrmPhone 去掉空白与常见分隔，保留数字与前导 +。
func normalizeCrmPhone(raw string) string {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return ""
	}
	var b strings.Builder
	for i, r := range raw {
		if r >= '0' && r <= '9' {
			b.WriteRune(r)
			continue
		}
		if r == '+' && i == 0 {
			b.WriteRune(r)
		}
	}
	return b.String()
}

func normalizeCrmWechat(raw string) string {
	return strings.TrimSpace(raw)
}

func derefString(value *string) string {
	if value == nil {
		return ""
	}
	return *value
}

// resolveOrCreateCrmContactTx 同宠舍下按 phone 优先、其次 wechat 复用客户，避免重复 crm_contact。
// 不发明第二套 Customer；公开留资与后台建客共用。
func (s *Server) resolveOrCreateCrmContactTx(
	ctx context.Context,
	tx pgx.Tx,
	ownerID, orgID uuid.UUID,
	input resolveCrmContactInput,
) (resolveCrmContactResult, error) {
	name := strings.TrimSpace(input.Name)
	if name == "" {
		return resolveCrmContactResult{}, validationError("name", "客户名称必填")
	}
	phone := normalizeCrmPhone(input.Phone)
	wechat := normalizeCrmWechat(input.Wechat)
	status := strings.TrimSpace(input.Status)
	if status == "" {
		status = "lead"
	}
	if status != "lead" && status != "active" && status != "archived" {
		return resolveCrmContactResult{}, validationError("status", "客户状态无效")
	}

	if phone != "" || wechat != "" {
		var (
			id            uuid.UUID
			existingPhone *string
			existingWechat *string
			existingNotes *string
			existingStatus string
			version       int
		)
		// 优先 phone 精确命中；其次 wechat；非归档优先；最近更新优先。
		err := tx.QueryRow(ctx, `
			SELECT id, phone, wechat, notes, status::text, version
			FROM crm_contact
			WHERE owner_id=$1
			  AND (
			    ($2::text <> '' AND phone = $2)
			    OR ($3::text <> '' AND wechat = $3)
			  )
			ORDER BY
			  CASE WHEN status = 'archived' THEN 1 ELSE 0 END,
			  CASE
			    WHEN $2::text <> '' AND phone = $2 THEN 0
			    ELSE 1
			  END,
			  updated_at DESC,
			  id DESC
			LIMIT 1
			FOR UPDATE
		`, ownerID, phone, wechat).Scan(&id, &existingPhone, &existingWechat, &existingNotes, &existingStatus, &version)
		if err == nil {
			nextPhone := existingPhone
			if (nextPhone == nil || strings.TrimSpace(*nextPhone) == "") && phone != "" {
				nextPhone = &phone
			}
			nextWechat := existingWechat
			if (nextWechat == nil || strings.TrimSpace(*nextWechat) == "") && wechat != "" {
				nextWechat = &wechat
			}
			nextNotes := existingNotes
			if notes := emptyToNil(input.Notes); notes != nil && (nextNotes == nil || strings.TrimSpace(*nextNotes) == "") {
				nextNotes = notes
			}
			nextStatus := existingStatus
			if existingStatus == "archived" {
				// 归档客户再次触达：恢复为 lead（公开）或请求状态（后台）。
				if status == "archived" {
					nextStatus = "lead"
				} else {
					nextStatus = status
				}
			}
			_, err = tx.Exec(ctx, `
				UPDATE crm_contact
				SET phone=$3, wechat=$4, notes=$5,
				    status=$6::crm_contact_status,
				    version=version+1, updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND version=$7
			`, ownerID, id, nextPhone, nextWechat, nextNotes, nextStatus, version)
			if err != nil {
				return resolveCrmContactResult{}, err
			}
			return resolveCrmContactResult{ID: id, Created: false}, nil
		}
		if !errors.Is(err, pgx.ErrNoRows) {
			return resolveCrmContactResult{}, err
		}
	}

	var id uuid.UUID
	err := tx.QueryRow(ctx, `
		INSERT INTO crm_contact (owner_id, organization_id, name, phone, wechat, notes, status)
		VALUES ($1,$2,$3,$4,$5,$6,$7::crm_contact_status)
		RETURNING id
	`, ownerID, orgID, name, emptyToNil(&phone), emptyToNil(&wechat), emptyToNil(input.Notes), status).Scan(&id)
	if err != nil {
		return resolveCrmContactResult{}, err
	}
	return resolveCrmContactResult{ID: id, Created: true}, nil
}

func emptyToNil(value *string) *string {
	if value == nil {
		return nil
	}
	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}
	return &trimmed
}
