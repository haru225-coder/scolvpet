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
	payload, err := decodeBody(r, &request)
	if err != nil {
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
	result, err := s.Store.RunIdempotent(
		r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			resolved, err := s.resolveOrCreateCrmContactTx(ctx, tx, ownerID, orgID, resolveCrmContactInput{
				Name: name, Phone: phone, Wechat: wechat, Notes: request.Notes, Status: status,
			})
			if err != nil {
				return 0, nil, nil, err
			}
			item, err := getCrmContactTx(ctx, tx, ownerID, resolved.ID)
			if err != nil {
				return 0, nil, nil, err
			}
			statusCode := http.StatusCreated
			if !resolved.Created {
				statusCode = http.StatusOK
			}
			return statusCode, crmEnvelope(r, item), map[string]string{"ETag": store.FormatETag(item.Version)}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
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
	payload, err := decodeBody(r, &request)
	if err != nil {
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
	var hamsterID *uuid.UUID
	if request.HamsterID != nil && strings.TrimSpace(*request.HamsterID) != "" {
		parsed, parseErr := uuid.Parse(strings.TrimSpace(*request.HamsterID))
		if parseErr != nil {
			writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
			return
		}
		hamsterID = &parsed
	}
	result, err := s.Store.RunIdempotent(
		r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			contact, err := getCrmContactTx(ctx, tx, ownerID, contactID)
			if err != nil {
				return 0, nil, nil, err
			}
			if contact.Status == "archived" {
				return 0, nil, nil, validationError("contact_id", "已归档客户不可创建预订")
			}
			id, err := s.createCrmReservationTx(ctx, tx, ownerID, orgID, createCrmReservationInput{
				ContactID: contactID, HamsterID: hamsterID, Title: title, Notes: request.Notes,
				RequirePublic: false,
			})
			if err != nil {
				return 0, nil, nil, err
			}
			item, err := getCrmReservationTx(ctx, tx, ownerID, id, false)
			if err != nil {
				return 0, nil, nil, err
			}
			return http.StatusCreated, crmEnvelope(r, item), map[string]string{"ETag": store.FormatETag(item.Version)}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
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
	payload := []byte(`{"status":"` + next + `"}`)
	result, err := s.Store.RunIdempotent(
		r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			current, err := getCrmReservationTx(ctx, tx, ownerID, reservationID, true)
			if err != nil {
				return 0, nil, nil, err
			}
			if err := requireCrmIfMatch(r.Header.Get("If-Match"), current.Version); err != nil {
				return 0, nil, nil, err
			}
			if err := validateReservationTransition(current.Status, next); err != nil {
				return 0, nil, nil, err
			}
			tag, err := tx.Exec(ctx, `
				UPDATE crm_reservation
				SET status=$4::crm_reservation_status, version=version+1, updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND version=$3
			`, ownerID, reservationID, current.Version, next)
			if err != nil {
				return 0, nil, nil, err
			}
			if tag.RowsAffected() != 1 {
				return 0, nil, nil, store.ErrVersionConflict
			}
			item, err := getCrmReservationTx(ctx, tx, ownerID, reservationID, false)
			if err != nil {
				return 0, nil, nil, err
			}
			return http.StatusOK, crmEnvelope(r, item), map[string]string{"ETag": store.FormatETag(item.Version)}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
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
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeAPIError(w, r, validationError("body", "交付请求体格式不正确"))
		return
	}
	contactID, err := uuid.Parse(strings.TrimSpace(request.ContactID))
	if err != nil || contactID == uuid.Nil {
		writeAPIError(w, r, validationError("contact_id", "客户无效"))
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
	}
	var parsedHamsterID *uuid.UUID
	if request.HamsterID != nil && strings.TrimSpace(*request.HamsterID) != "" {
		parsed, parseErr := uuid.Parse(strings.TrimSpace(*request.HamsterID))
		if parseErr != nil {
			writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
			return
		}
		parsedHamsterID = &parsed
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
	result, err := s.Store.RunIdempotent(
		r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			contact, err := getCrmContactTx(ctx, tx, ownerID, contactID)
			if err != nil {
				return 0, nil, nil, err
			}
			if contact.Status == "archived" {
				return 0, nil, nil, validationError("contact_id", "已归档客户不可安排交付")
			}
			resolvedHamsterID := hamsterID
			if reservationID != nil {
				reservation, err := getCrmReservationTx(ctx, tx, ownerID, *reservationID, true)
				if err != nil {
					return 0, nil, nil, err
				}
				if err := validateHandoverReservation(reservation, contactID, parsedHamsterID); err != nil {
					return 0, nil, nil, err
				}
				resolvedHamsterID = reservation.HamsterID
				var exists bool
				if err := tx.QueryRow(ctx, `
					SELECT EXISTS(
						SELECT 1 FROM crm_handover
						WHERE owner_id=$1 AND reservation_id=$2 AND status <> 'cancelled'
					)
				`, ownerID, *reservationID).Scan(&exists); err != nil {
					return 0, nil, nil, err
				}
				if exists {
					return 0, nil, nil, conflictError("reservation_id", "该预订已有交付单")
				}
			}
			if resolvedHamsterID == nil {
				return 0, nil, nil, validationError("hamster_id", "交付必须关联仓鼠")
			}
			if err := assertCrmHamsterActiveTx(ctx, tx, ownerID, *resolvedHamsterID); err != nil {
				return 0, nil, nil, err
			}
			var id uuid.UUID
			err = tx.QueryRow(ctx, `
				INSERT INTO crm_handover (
					owner_id, organization_id, contact_id, reservation_id, hamster_id, status, scheduled_at, notes
				) VALUES ($1,$2,$3,$4,$5,'scheduled',$6,$7)
				RETURNING id
			`, ownerID, orgID, contactID, reservationID, resolvedHamsterID, scheduledAt, emptyToNil(request.Notes)).Scan(&id)
			if err != nil {
				return 0, nil, nil, err
			}
			item, err := getCrmHandoverTx(ctx, tx, ownerID, id, false)
			if err != nil {
				return 0, nil, nil, err
			}
			return http.StatusCreated, crmEnvelope(r, item), map[string]string{"ETag": store.FormatETag(item.Version)}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
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
	payload := []byte(`{"status":"completed"}`)
	result, err := s.Store.RunIdempotent(
		r.Context(), ownerID, r.Header.Get("Idempotency-Key"), http.MethodPost, r.URL.Path, payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			current, err := getCrmHandoverTx(ctx, tx, ownerID, handoverID, true)
			if err != nil {
				return 0, nil, nil, err
			}
			if err := requireCrmIfMatch(r.Header.Get("If-Match"), current.Version); err != nil {
				return 0, nil, nil, err
			}
			if current.Status != "scheduled" {
				return 0, nil, nil, validationError("status", "仅待交付可完成")
			}
			if current.HamsterID == nil {
				return 0, nil, nil, validationError("hamster_id", "交付必须关联仓鼠")
			}
			if current.Reservation != nil {
				reservation, err := getCrmReservationTx(ctx, tx, ownerID, *current.Reservation, true)
				if err != nil {
					return 0, nil, nil, err
				}
				if reservation.Status != "confirmed" || reservation.ContactID != current.ContactID || reservation.HamsterID == nil || *reservation.HamsterID != *current.HamsterID {
					return 0, nil, nil, conflictError("reservation_id", "交付与已确认预订不一致")
				}
				tag, err := tx.Exec(ctx, `
					UPDATE crm_reservation
					SET status='handed_over', version=version+1, updated_at=now()
					WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='confirmed'
				`, ownerID, reservation.ID, reservation.Version)
				if err != nil {
					return 0, nil, nil, err
				}
				if tag.RowsAffected() != 1 {
					return 0, nil, nil, store.ErrVersionConflict
				}
			}
			tag, err := tx.Exec(ctx, `
				UPDATE hamster
				SET lifecycle_status='transferred', version=version+1, updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL AND lifecycle_status='active'
			`, ownerID, *current.HamsterID)
			if err != nil {
				return 0, nil, nil, err
			}
			if tag.RowsAffected() != 1 {
				return 0, nil, nil, conflictError("hamster_id", "仓鼠当前不可完成交付")
			}
			tag, err = tx.Exec(ctx, `
				UPDATE crm_handover
				SET status='completed', completed_at=now(), version=version+1, updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND version=$3 AND status='scheduled'
			`, ownerID, handoverID, current.Version)
			if err != nil {
				return 0, nil, nil, err
			}
			if tag.RowsAffected() != 1 {
				return 0, nil, nil, store.ErrVersionConflict
			}
			if _, err := tx.Exec(ctx, `
				UPDATE crm_contact
				SET status='active', version=version+1, updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND status='lead'
			`, ownerID, current.ContactID); err != nil {
				return 0, nil, nil, err
			}
			if err := insertHandoverIncomeIfNeeded(ctx, tx, ownerID, current); err != nil {
				return 0, nil, nil, err
			}
			item, err := getCrmHandoverTx(ctx, tx, ownerID, handoverID, false)
			if err != nil {
				return 0, nil, nil, err
			}
			return http.StatusOK, crmEnvelope(r, item), map[string]string{"ETag": store.FormatETag(item.Version)}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
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

func getCrmContactTx(ctx context.Context, tx pgx.Tx, ownerID, id uuid.UUID) (crmContact, error) {
	var item crmContact
	err := tx.QueryRow(ctx, `
		SELECT id, name, phone, wechat, notes, status::text, version
		FROM crm_contact WHERE owner_id=$1 AND id=$2
	`, ownerID, id).Scan(&item.ID, &item.Name, &item.Phone, &item.Wechat, &item.Notes, &item.Status, &item.Version)
	if errors.Is(err, pgx.ErrNoRows) {
		return crmContact{}, store.ErrNotFound
	}
	return item, err
}

func getCrmReservationTx(ctx context.Context, tx pgx.Tx, ownerID, id uuid.UUID, forUpdate bool) (crmReservation, error) {
	query := `
		SELECT r.id, r.contact_id, r.hamster_id, r.title, r.status::text, r.reserved_at, r.notes, r.version, c.name,
			CASE WHEN h.id IS NULL THEN NULL ELSE COALESCE(NULLIF(h.name,''), h.internal_code) END
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		LEFT JOIN hamster h ON h.owner_id=r.owner_id AND h.id=r.hamster_id AND h.deleted_at IS NULL
		WHERE r.owner_id=$1 AND r.id=$2`
	if forUpdate {
		query += ` FOR UPDATE OF r`
	}
	var item crmReservation
	err := tx.QueryRow(ctx, query, ownerID, id).Scan(
		&item.ID, &item.ContactID, &item.HamsterID, &item.Title, &item.Status, &item.ReservedAt,
		&item.Notes, &item.Version, &item.ContactName, &item.HamsterName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return crmReservation{}, store.ErrNotFound
	}
	return item, err
}

func getCrmHandoverTx(ctx context.Context, tx pgx.Tx, ownerID, id uuid.UUID, forUpdate bool) (crmHandover, error) {
	query := `
		SELECT h.id, h.contact_id, h.reservation_id, h.hamster_id, h.status::text,
			h.scheduled_at, h.completed_at, h.notes, h.version, c.name,
			CASE WHEN hamster.id IS NULL THEN NULL ELSE COALESCE(NULLIF(hamster.name,''), hamster.internal_code) END
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.id=$2`
	if forUpdate {
		query += ` FOR UPDATE OF h`
	}
	var item crmHandover
	err := tx.QueryRow(ctx, query, ownerID, id).Scan(
		&item.ID, &item.ContactID, &item.Reservation, &item.HamsterID, &item.Status,
		&item.ScheduledAt, &item.CompletedAt, &item.Notes, &item.Version,
		&item.ContactName, &item.HamsterName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return crmHandover{}, store.ErrNotFound
	}
	return item, err
}

func crmEnvelope(r *http.Request, item any) map[string]any {
	return map[string]any{"data": item, "meta": responseMeta(r)}
}

func requireCrmIfMatch(value string, currentVersion int) error {
	if strings.TrimSpace(value) == "" {
		return validationError("If-Match", "写操作必须提供当前资源版本 ETag")
	}
	version, err := store.ParseETag(value)
	if err != nil {
		return validationError("If-Match", "If-Match 必须是当前资源版本 ETag")
	}
	if version != currentVersion {
		return store.ErrVersionConflict
	}
	return nil
}

func validateReservationTransition(current, next string) error {
	switch next {
	case "confirmed":
		if current != "held" {
			return validationError("status", "仅待确认预订可确认")
		}
	case "cancelled":
		if current != "held" && current != "confirmed" {
			return validationError("status", "当前预订不可取消")
		}
	default:
		return validationError("status", "预订状态无效")
	}
	return nil
}

func validateHandoverReservation(reservation crmReservation, contactID uuid.UUID, requestedHamsterID *uuid.UUID) error {
	if reservation.Status != "confirmed" {
		return validationError("reservation_id", "仅已确认预订可安排交付")
	}
	if reservation.ContactID != contactID {
		return validationError("reservation_id", "预订不属于所选客户")
	}
	if reservation.HamsterID == nil {
		return validationError("reservation_id", "预订未关联仓鼠")
	}
	if requestedHamsterID != nil && *requestedHamsterID != *reservation.HamsterID {
		return validationError("hamster_id", "交付仓鼠必须与预订一致")
	}
	return nil
}

func assertCrmHamsterActiveTx(ctx context.Context, tx pgx.Tx, ownerID, hamsterID uuid.UUID) error {
	var lifecycle string
	err := tx.QueryRow(ctx, `
		SELECT lifecycle_status::text FROM hamster
		WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, hamsterID).Scan(&lifecycle)
	if errors.Is(err, pgx.ErrNoRows) {
		return validationError("hamster_id", "所选仓鼠不存在")
	}
	if err != nil {
		return err
	}
	if lifecycle != "active" {
		return conflictError("hamster_id", "该仓鼠当前不可交付")
	}
	return nil
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

type createCrmReservationInput struct {
	ContactID     uuid.UUID
	HamsterID     *uuid.UUID
	Title         string
	Notes         *string
	RequirePublic bool
}

// createCrmReservationTx 创建 held 预订；hamster 级开放预订排他（held/confirmed）。
func (s *Server) createCrmReservationTx(
	ctx context.Context,
	tx pgx.Tx,
	ownerID, orgID uuid.UUID,
	input createCrmReservationInput,
) (uuid.UUID, error) {
	if input.ContactID == uuid.Nil {
		return uuid.Nil, validationError("contact_id", "客户无效")
	}
	title := strings.TrimSpace(input.Title)
	if title == "" {
		title = "预订"
	}
	if utf8.RuneCountInString(title) > 200 {
		return uuid.Nil, validationError("title", "标题过长")
	}

	if input.HamsterID != nil {
		if err := s.lockAndAssertHamsterReservableTx(ctx, tx, ownerID, *input.HamsterID, input.RequirePublic); err != nil {
			return uuid.Nil, err
		}
		open, err := s.hasOpenReservationForHamsterTx(ctx, tx, ownerID, *input.HamsterID)
		if err != nil {
			return uuid.Nil, err
		}
		if open {
			return uuid.Nil, conflictError("hamster_id", "该仓鼠已被预订，请选择其他个体")
		}
	}

	var id uuid.UUID
	err := tx.QueryRow(ctx, `
		INSERT INTO crm_reservation (
			owner_id, organization_id, contact_id, hamster_id, title, status, notes
		) VALUES ($1,$2,$3,$4,$5,'held',$6)
		RETURNING id
	`, ownerID, orgID, input.ContactID, input.HamsterID, title, emptyToNil(input.Notes)).Scan(&id)
	if err != nil {
		// Unique index 兜底并发。
		if strings.Contains(strings.ToLower(err.Error()), "ux_crm_reservation_open_hamster") ||
			strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return uuid.Nil, conflictError("hamster_id", "该仓鼠已被预订，请选择其他个体")
		}
		return uuid.Nil, err
	}
	return id, nil
}

func (s *Server) lockAndAssertHamsterReservableTx(
	ctx context.Context,
	tx pgx.Tx,
	ownerID, hamsterID uuid.UUID,
	requirePublic bool,
) error {
	var (
		lifecycle string
		deleted   *time.Time
	)
	err := tx.QueryRow(ctx, `
		SELECT lifecycle_status::text, deleted_at
		FROM hamster
		WHERE owner_id=$1 AND id=$2
		FOR UPDATE
	`, ownerID, hamsterID).Scan(&lifecycle, &deleted)
	if errors.Is(err, pgx.ErrNoRows) {
		return validationError("hamster_id", "所选仓鼠不存在")
	}
	if err != nil {
		return err
	}
	if deleted != nil {
		return validationError("hamster_id", "所选仓鼠不存在")
	}
	if lifecycle != "active" {
		return conflictError("hamster_id", "该仓鼠当前不可预订")
	}
	if !requirePublic {
		return nil
	}
	var published, consultable bool
	err = tx.QueryRow(ctx, `
		SELECT published, consultable
		FROM hamster_public_profile
		WHERE owner_id=$1 AND hamster_id=$2
	`, ownerID, hamsterID).Scan(&published, &consultable)
	if errors.Is(err, pgx.ErrNoRows) {
		return conflictError("hamster_id", "该仓鼠未开放公开预订")
	}
	if err != nil {
		return err
	}
	if !published || !consultable {
		return conflictError("hamster_id", "该仓鼠当前不接受预订")
	}
	return nil
}

func (s *Server) hasOpenReservationForHamsterTx(
	ctx context.Context,
	tx pgx.Tx,
	ownerID, hamsterID uuid.UUID,
) (bool, error) {
	var exists bool
	err := tx.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM crm_reservation
			WHERE owner_id=$1 AND hamster_id=$2 AND status IN ('held','confirmed')
		)
	`, ownerID, hamsterID).Scan(&exists)
	return exists, err
}

func (s *Server) openReservedHamsterIDs(ctx context.Context, ownerID uuid.UUID) (map[uuid.UUID]struct{}, error) {
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT DISTINCT hamster_id
		FROM crm_reservation
		WHERE owner_id=$1
		  AND hamster_id IS NOT NULL
		  AND status IN ('held','confirmed')
	`, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make(map[uuid.UUID]struct{})
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		out[id] = struct{}{}
	}
	return out, rows.Err()
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
			id             uuid.UUID
			existingPhone  *string
			existingWechat *string
			existingNotes  *string
			existingStatus string
			version        int
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

// insertHandoverIncomeIfNeeded creates at most one income row when a handover
// completes and an issued receipt with amount > 0 is linked. Notes carry a
// stable handover marker so repeated completion (or future retries) stay
// idempotent without a dedicated FK column.
func insertHandoverIncomeIfNeeded(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID, handover crmHandover) error {
	marker := fmt.Sprintf("handover:%s", handover.ID)
	var exists bool
	if err := tx.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM accounting_record
			WHERE owner_id=$1 AND notes=$2
		)
	`, ownerID, marker).Scan(&exists); err != nil {
		return err
	}
	if exists {
		return nil
	}

	var (
		amountCents int64
		currency    string
		title       string
	)
	err := tx.QueryRow(ctx, `
		SELECT amount_cents, COALESCE(NULLIF(currency,''), 'CNY'), title
		FROM doc_document
		WHERE owner_id=$1
		  AND handover_id=$2
		  AND kind='receipt'::doc_template_kind
		  AND status='issued'
		  AND amount_cents IS NOT NULL
		  AND amount_cents > 0
		ORDER BY issued_at DESC NULLS LAST, updated_at DESC, id DESC
		LIMIT 1
	`, ownerID, handover.ID).Scan(&amountCents, &currency, &title)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil
	}
	if err != nil {
		return err
	}

	var orgID uuid.UUID
	if err := tx.QueryRow(ctx, `
		SELECT id FROM organization
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY created_at LIMIT 1
	`, ownerID).Scan(&orgID); err != nil {
		return err
	}

	incomeTitle := strings.TrimSpace(title)
	if incomeTitle == "" {
		incomeTitle = "交付收入"
	}
	if handover.HamsterName != nil && strings.TrimSpace(*handover.HamsterName) != "" {
		incomeTitle = fmt.Sprintf("%s · %s", incomeTitle, strings.TrimSpace(*handover.HamsterName))
	}
	if utf8.RuneCountInString(incomeTitle) > 200 {
		runes := []rune(incomeTitle)
		incomeTitle = string(runes[:200])
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO accounting_record (
			owner_id, organization_id, category_id, entry_type, amount_cents, currency,
			title, notes, contact_id, occurred_at
		) VALUES (
			$1,$2,NULL,'income'::accounting_entry_type,$3,$4,$5,$6,$7,now()
		)
	`, ownerID, orgID, amountCents, currency, incomeTitle, marker, handover.ContactID)
	return err
}
