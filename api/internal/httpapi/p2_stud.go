package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP2StudRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/stud/listings", s.listStudListings)
	mux.HandleFunc("POST /v1/stud/listings", s.createStudListing)
	mux.HandleFunc("POST /v1/stud/listings/{listing_id}/unpublish", s.unpublishStudListing)

	mux.HandleFunc("GET /v1/stud/deals", s.listStudDeals)
	mux.HandleFunc("POST /v1/stud/deals", s.createStudDeal)
	mux.HandleFunc("POST /v1/stud/deals/{deal_id}/confirm", s.confirmStudDeal)
	mux.HandleFunc("POST /v1/stud/deals/{deal_id}/start", s.startStudDeal)
	mux.HandleFunc("POST /v1/stud/deals/{deal_id}/complete", s.completeStudDeal)
	mux.HandleFunc("POST /v1/stud/deals/{deal_id}/cancel", s.cancelStudDeal)
}

type studListing struct {
	ID           uuid.UUID `json:"id"`
	OwnerID      uuid.UUID `json:"owner_id"`
	SireLabel    string    `json:"sire_label"`
	Title        string    `json:"title"`
	FeeCents     int64     `json:"fee_cents"`
	Currency     string    `json:"currency"`
	Notes        *string   `json:"notes,omitempty"`
	Published    bool      `json:"published"`
	Version      int       `json:"version"`
	UpdatedAt    time.Time `json:"updated_at"`
	CatteryName  string    `json:"cattery_name,omitempty"`
	IsMine       bool      `json:"is_mine"`
}

type studDeal struct {
	ID                 uuid.UUID  `json:"id"`
	ListingID          *uuid.UUID `json:"listing_id,omitempty"`
	Side               string     `json:"side"`
	Status             string     `json:"status"`
	MyHamsterLabel     *string    `json:"my_hamster_label,omitempty"`
	PartnerCatteryName string     `json:"partner_cattery_name"`
	PartnerContact     *string    `json:"partner_contact,omitempty"`
	PartnerAnimalLabel *string    `json:"partner_animal_label,omitempty"`
	FeeCents           int64      `json:"fee_cents"`
	Currency           string     `json:"currency"`
	Notes              *string    `json:"notes,omitempty"`
	ConfirmedAt        *time.Time `json:"confirmed_at,omitempty"`
	StartedAt          *time.Time `json:"started_at,omitempty"`
	CompletedAt        *time.Time `json:"completed_at,omitempty"`
	CancelledAt        *time.Time `json:"cancelled_at,omitempty"`
	Version            int        `json:"version"`
	UpdatedAt          time.Time  `json:"updated_at"`
}

type createStudListingRequest struct {
	SireLabel string  `json:"sire_label"`
	Title     string  `json:"title"`
	FeeCents  int64   `json:"fee_cents"`
	Currency  string  `json:"currency"`
	Notes     *string `json:"notes"`
	Published *bool   `json:"published"`
}

type createStudDealRequest struct {
	ListingID          *string `json:"listing_id"`
	Side               string  `json:"side"`
	MyHamsterLabel     *string `json:"my_hamster_label"`
	PartnerCatteryName string  `json:"partner_cattery_name"`
	PartnerContact     *string `json:"partner_contact"`
	PartnerAnimalLabel *string `json:"partner_animal_label"`
	FeeCents           *int64  `json:"fee_cents"`
	Currency           string  `json:"currency"`
	Notes              *string `json:"notes"`
}

func (s *Server) listStudListings(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	mineOnly := strings.TrimSpace(r.URL.Query().Get("mine")) == "1"
	query := `
		SELECT l.id, l.owner_id, l.sire_label, l.title, l.fee_cents, l.currency, l.notes,
			l.published, l.version, l.updated_at, COALESCE(o.name, '')
		FROM stud_listing l
		LEFT JOIN organization o ON o.owner_id=l.owner_id AND o.id=l.organization_id
		WHERE `
	args := []any{}
	if mineOnly {
		query += `l.owner_id=$1`
		args = append(args, ownerID)
	} else {
		query += `(l.published=true OR l.owner_id=$1)`
		args = append(args, ownerID)
	}
	query += ` ORDER BY l.updated_at DESC, l.id DESC LIMIT 100`
	rows, err := s.Store.Pool.Query(r.Context(), query, args...)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]studListing, 0)
	for rows.Next() {
		var item studListing
		if err := rows.Scan(
			&item.ID, &item.OwnerID, &item.SireLabel, &item.Title, &item.FeeCents, &item.Currency, &item.Notes,
			&item.Published, &item.Version, &item.UpdatedAt, &item.CatteryName,
		); err != nil {
			writeAPIError(w, r, err)
			return
		}
		item.IsMine = item.OwnerID == ownerID
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createStudListing(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createStudListingRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "挂牌请求体格式不正确"))
		return
	}
	sire := strings.TrimSpace(request.SireLabel)
	title := strings.TrimSpace(request.Title)
	if sire == "" {
		writeAPIError(w, r, validationError("sire_label", "种公名称必填"))
		return
	}
	if title == "" {
		title = sire + " 借配"
	}
	if request.FeeCents < 0 {
		writeAPIError(w, r, validationError("fee_cents", "费用不能为负"))
		return
	}
	currency := strings.TrimSpace(request.Currency)
	if currency == "" {
		currency = "CNY"
	}
	published := true
	if request.Published != nil {
		published = *request.Published
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO stud_listing (
			owner_id, organization_id, sire_label, title, fee_cents, currency, notes, published
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
		RETURNING id
	`, ownerID, orgID, sire, title, request.FeeCents, currency, emptyToNil(request.Notes), published).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getStudListing(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) unpublishStudListing(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	listingID, err := uuid.Parse(r.PathValue("listing_id"))
	if err != nil {
		writeAPIError(w, r, validationError("listing_id", "挂牌 ID 无效"))
		return
	}
	tag, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE stud_listing
		SET published=false, version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2
	`, ownerID, listingID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() == 0 {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	item, err := s.getStudListing(r.Context(), ownerID, listingID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listStudDeals(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, listing_id, side::text, status::text, my_hamster_label, partner_cattery_name,
			partner_contact, partner_animal_label, fee_cents, currency, notes,
			confirmed_at, started_at, completed_at, cancelled_at, version, updated_at
		FROM stud_deal
		WHERE owner_id=$1 AND status <> 'cancelled'
		ORDER BY updated_at DESC, id DESC
		LIMIT 100
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]studDeal, 0)
	for rows.Next() {
		item, err := scanStudDeal(rows)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createStudDeal(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createStudDealRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "借配单请求体格式不正确"))
		return
	}
	side := strings.TrimSpace(request.Side)
	if side != "provider" && side != "requester" {
		writeAPIError(w, r, validationError("side", "side 须为 provider 或 requester"))
		return
	}
	partner := strings.TrimSpace(request.PartnerCatteryName)
	if partner == "" {
		writeAPIError(w, r, validationError("partner_cattery_name", "对方熊舍名称必填"))
		return
	}
	if utf8.RuneCountInString(partner) > 160 {
		writeAPIError(w, r, validationError("partner_cattery_name", "对方熊舍名称过长"))
		return
	}
	fee := int64(0)
	if request.FeeCents != nil {
		if *request.FeeCents < 0 {
			writeAPIError(w, r, validationError("fee_cents", "费用不能为负"))
			return
		}
		fee = *request.FeeCents
	}
	currency := strings.TrimSpace(request.Currency)
	if currency == "" {
		currency = "CNY"
	}
	var listingID *uuid.UUID
	if request.ListingID != nil && strings.TrimSpace(*request.ListingID) != "" {
		id, err := uuid.Parse(strings.TrimSpace(*request.ListingID))
		if err != nil {
			writeAPIError(w, r, validationError("listing_id", "挂牌 ID 无效"))
			return
		}
		// Listing may belong to another owner (network).
		var listingFee int64
		var listingCurrency string
		var listingOwner uuid.UUID
		var sireLabel string
		err = s.Store.Pool.QueryRow(r.Context(), `
			SELECT owner_id, sire_label, fee_cents, currency
			FROM stud_listing
			WHERE id=$1 AND (published=true OR owner_id=$2)
		`, id, ownerID).Scan(&listingOwner, &sireLabel, &listingFee, &listingCurrency)
		if errors.Is(err, pgx.ErrNoRows) {
			writeAPIError(w, r, validationError("listing_id", "挂牌不存在或未公开"))
			return
		}
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		listingID = &id
		if request.FeeCents == nil {
			fee = listingFee
			currency = listingCurrency
		}
		if request.PartnerAnimalLabel == nil && side == "requester" {
			request.PartnerAnimalLabel = &sireLabel
		}
		if partner == "" {
			// fill from listing org if requester left empty — already required above
		}
		_ = listingOwner
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	status := "requested"
	if side == "provider" {
		status = "draft"
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO stud_deal (
			owner_id, organization_id, listing_id, side, status, my_hamster_label,
			partner_cattery_name, partner_contact, partner_animal_label,
			fee_cents, currency, notes
		) VALUES ($1,$2,$3,$4::stud_deal_side,$5::stud_deal_status,$6,$7,$8,$9,$10,$11,$12)
		RETURNING id
	`, ownerID, orgID, listingID, side, status, emptyToNil(request.MyHamsterLabel),
		partner, emptyToNil(request.PartnerContact), emptyToNil(request.PartnerAnimalLabel),
		fee, currency, emptyToNil(request.Notes)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getStudDeal(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) confirmStudDeal(w http.ResponseWriter, r *http.Request) {
	s.transitionStudDeal(w, r, "confirmed", []string{"draft", "requested"}, func(ownerID, dealID uuid.UUID, fromStatus string) (int64, error) {
		tag, err := s.Store.Pool.Exec(r.Context(), `
			UPDATE stud_deal
			SET status='confirmed', confirmed_at=now(), version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND status=$3::stud_deal_status
		`, ownerID, dealID, fromStatus)
		return tag.RowsAffected(), err
	})
}

func (s *Server) startStudDeal(w http.ResponseWriter, r *http.Request) {
	s.transitionStudDeal(w, r, "in_progress", []string{"confirmed"}, func(ownerID, dealID uuid.UUID, fromStatus string) (int64, error) {
		tag, err := s.Store.Pool.Exec(r.Context(), `
			UPDATE stud_deal
			SET status='in_progress', started_at=now(), version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND status=$3::stud_deal_status
		`, ownerID, dealID, fromStatus)
		return tag.RowsAffected(), err
	})
}

func (s *Server) completeStudDeal(w http.ResponseWriter, r *http.Request) {
	s.transitionStudDeal(w, r, "completed", []string{"in_progress", "confirmed"}, func(ownerID, dealID uuid.UUID, fromStatus string) (int64, error) {
		tag, err := s.Store.Pool.Exec(r.Context(), `
			UPDATE stud_deal
			SET status='completed', completed_at=now(), version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND status=$3::stud_deal_status
		`, ownerID, dealID, fromStatus)
		return tag.RowsAffected(), err
	})
}

func (s *Server) cancelStudDeal(w http.ResponseWriter, r *http.Request) {
	s.transitionStudDeal(w, r, "cancelled", []string{"draft", "requested", "confirmed", "in_progress"}, func(ownerID, dealID uuid.UUID, fromStatus string) (int64, error) {
		tag, err := s.Store.Pool.Exec(r.Context(), `
			UPDATE stud_deal
			SET status='cancelled', cancelled_at=now(), version=version+1, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND status=$3::stud_deal_status
		`, ownerID, dealID, fromStatus)
		return tag.RowsAffected(), err
	})
}

func (s *Server) transitionStudDeal(
	w http.ResponseWriter,
	r *http.Request,
	next string,
	from []string,
	exec func(ownerID, dealID uuid.UUID, fromStatus string) (int64, error),
) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	dealID, err := uuid.Parse(r.PathValue("deal_id"))
	if err != nil {
		writeAPIError(w, r, validationError("deal_id", "借配单 ID 无效"))
		return
	}
	current, err := s.getStudDeal(r.Context(), ownerID, dealID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	allowed := false
	for _, st := range from {
		if current.Status == st {
			allowed = true
			break
		}
	}
	if !allowed {
		writeAPIError(w, r, validationError("status", "当前状态不可变更为 "+next))
		return
	}
	n, err := exec(ownerID, dealID, current.Status)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if n == 0 {
		writeAPIError(w, r, validationError("status", "状态已变化，请刷新"))
		return
	}
	item, err := s.getStudDeal(r.Context(), ownerID, dealID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) getStudListing(ctx context.Context, viewerID, id uuid.UUID) (studListing, error) {
	var item studListing
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT l.id, l.owner_id, l.sire_label, l.title, l.fee_cents, l.currency, l.notes,
			l.published, l.version, l.updated_at, COALESCE(o.name, '')
		FROM stud_listing l
		LEFT JOIN organization o ON o.owner_id=l.owner_id AND o.id=l.organization_id
		WHERE l.id=$1 AND (l.owner_id=$2 OR l.published=true)
	`, id, viewerID).Scan(
		&item.ID, &item.OwnerID, &item.SireLabel, &item.Title, &item.FeeCents, &item.Currency, &item.Notes,
		&item.Published, &item.Version, &item.UpdatedAt, &item.CatteryName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return studListing{}, store.ErrNotFound
	}
	item.IsMine = item.OwnerID == viewerID
	return item, err
}

func (s *Server) getStudDeal(ctx context.Context, ownerID, id uuid.UUID) (studDeal, error) {
	row := s.Store.Pool.QueryRow(ctx, `
		SELECT id, listing_id, side::text, status::text, my_hamster_label, partner_cattery_name,
			partner_contact, partner_animal_label, fee_cents, currency, notes,
			confirmed_at, started_at, completed_at, cancelled_at, version, updated_at
		FROM stud_deal
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id)
	return scanStudDeal(row)
}

type studDealScanner interface {
	Scan(dest ...any) error
}

func scanStudDeal(row studDealScanner) (studDeal, error) {
	var item studDeal
	err := row.Scan(
		&item.ID, &item.ListingID, &item.Side, &item.Status, &item.MyHamsterLabel, &item.PartnerCatteryName,
		&item.PartnerContact, &item.PartnerAnimalLabel, &item.FeeCents, &item.Currency, &item.Notes,
		&item.ConfirmedAt, &item.StartedAt, &item.CompletedAt, &item.CancelledAt, &item.Version, &item.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return studDeal{}, store.ErrNotFound
	}
	return item, err
}
