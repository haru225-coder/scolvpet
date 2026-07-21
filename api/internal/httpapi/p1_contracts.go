package httpapi

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP1ContractRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/contracts/templates", s.listContractTemplates)
	mux.HandleFunc("POST /v1/contracts/templates", s.createContractTemplate)
	mux.HandleFunc("GET /v1/contracts", s.listContracts)
	mux.HandleFunc("POST /v1/contracts", s.createContract)
	mux.HandleFunc("POST /v1/contracts/{document_id}/issue", s.issueContract)

	mux.HandleFunc("GET /v1/receipts/templates", s.listReceiptTemplates)
	mux.HandleFunc("POST /v1/receipts/templates", s.createReceiptTemplate)
	mux.HandleFunc("GET /v1/receipts", s.listReceipts)
	mux.HandleFunc("POST /v1/receipts", s.createReceipt)
	mux.HandleFunc("POST /v1/receipts/{document_id}/issue", s.issueReceipt)

	// 客户侧只读：已签发合同/回执（能力令牌，无鉴权）
	mux.HandleFunc("GET /v1/public/documents/{token}", s.getPublicDocument)
}

type docTemplate struct {
	ID      uuid.UUID `json:"id"`
	Kind    string    `json:"kind"`
	Name    string    `json:"name"`
	Body    string    `json:"body_text"`
	Version int       `json:"version"`
}

type docDocument struct {
	ID          uuid.UUID  `json:"id"`
	TemplateID  uuid.UUID  `json:"template_id"`
	Kind        string     `json:"kind"`
	ContactID   *uuid.UUID `json:"contact_id,omitempty"`
	HandoverID  *uuid.UUID `json:"handover_id,omitempty"`
	Title       string     `json:"title"`
	BodyFilled  string     `json:"body_filled"`
	AmountCents *int64     `json:"amount_cents,omitempty"`
	Currency    string     `json:"currency"`
	Status      string     `json:"status"`
	IssuedAt    *time.Time `json:"issued_at,omitempty"`
	Notes       *string    `json:"notes,omitempty"`
	Version     int        `json:"version"`
	ContactName string     `json:"contact_name,omitempty"`
	// 仅已签发单据有；客户侧能力链接。
	PublicToken *string `json:"public_token,omitempty"`
	PublicPath  *string `json:"public_path,omitempty"`
}

type createDocTemplateRequest struct {
	Name string `json:"name"`
	Body string `json:"body_text"`
}

type createContractRequest struct {
	TemplateID    string  `json:"template_id"`
	ContactID     *string `json:"contact_id"`
	HandoverID    *string `json:"handover_id"`
	ReservationID *string `json:"reservation_id"`
	Title         string  `json:"title"`
	Notes         *string `json:"notes"`
	// Optional overrides for variable fill.
	ContactName *string `json:"contact_name"`
	HamsterName *string `json:"hamster_name"`
}

type createReceiptRequest struct {
	TemplateID    string  `json:"template_id"`
	ContactID     *string `json:"contact_id"`
	HandoverID    *string `json:"handover_id"`
	ReservationID *string `json:"reservation_id"`
	Title         string  `json:"title"`
	AmountCents   int64   `json:"amount_cents"`
	Currency      string  `json:"currency"`
	Notes         *string `json:"notes"`
	ContactName   *string `json:"contact_name"`
	HamsterName   *string `json:"hamster_name"`
}

func (s *Server) listContractTemplates(w http.ResponseWriter, r *http.Request) {
	s.listDocTemplates(w, r, "contract")
}

func (s *Server) createContractTemplate(w http.ResponseWriter, r *http.Request) {
	s.createDocTemplate(w, r, "contract")
}

func (s *Server) listReceiptTemplates(w http.ResponseWriter, r *http.Request) {
	s.listDocTemplates(w, r, "receipt")
}

func (s *Server) createReceiptTemplate(w http.ResponseWriter, r *http.Request) {
	s.createDocTemplate(w, r, "receipt")
}

func (s *Server) listContracts(w http.ResponseWriter, r *http.Request) {
	s.listDocDocuments(w, r, "contract")
}

func (s *Server) createContract(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createContractRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "合同请求体格式不正确"))
		return
	}
	templateID, err := uuid.Parse(strings.TrimSpace(request.TemplateID))
	if err != nil {
		writeAPIError(w, r, validationError("template_id", "模板 ID 无效"))
		return
	}
	tpl, err := s.getDocTemplate(r.Context(), ownerID, templateID, "contract")
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	contactID, contactName, err := s.resolveContactRef(r.Context(), ownerID, request.ContactID, request.ContactName)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	handoverID, err := parseOptionalUUID(request.HandoverID)
	if err != nil {
		writeAPIError(w, r, validationError("handover_id", "交付单 ID 无效"))
		return
	}
	reservationID, err := parseOptionalUUID(request.ReservationID)
	if err != nil {
		writeAPIError(w, r, validationError("reservation_id", "预订 ID 无效"))
		return
	}
	hamsterName := stringOrEmpty(request.HamsterName)
	// 优先从 Reservation 继承客户/个体（Golden Path：确认预订后直接生成合同）。
	if reservationID != nil {
		context, contextErr := s.getDocReservationContext(r.Context(), ownerID, *reservationID)
		if contextErr != nil {
			writeAPIError(w, r, contextErr)
			return
		}
		if contactID == nil {
			contact := context.ContactID
			contactID = &contact
		}
		if contactName == "" {
			contactName = context.ContactName
		}
		if hamsterName == "" {
			hamsterName = context.HamsterName
		}
		if handoverID == nil && context.HandoverID != nil {
			handoverID = context.HandoverID
		}
	}
	if handoverID != nil {
		context, contextErr := s.getDocHandoverContext(r.Context(), ownerID, *handoverID)
		if contextErr != nil {
			writeAPIError(w, r, contextErr)
			return
		}
		if contactID == nil {
			contact := context.ContactID
			contactID = &contact
		}
		if contactName == "" {
			contactName = context.ContactName
		}
		if hamsterName == "" {
			hamsterName = context.HamsterName
		}
		if err := s.ensureHandoverOwned(r.Context(), ownerID, *handoverID); err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	title := strings.TrimSpace(request.Title)
	if title == "" {
		if hamsterName != "" {
			title = "交接协议 · " + hamsterName
		} else {
			title = tpl.Name
		}
	}
	filled := fillDocTemplate(tpl.Body, map[string]string{
		"contact_name": contactName,
		"title":        title,
		"hamster_name": hamsterName,
		"amount":       "",
		"date":         time.Now().In(time.Local).Format("2006-01-02"),
		"notes":        stringOrEmpty(request.Notes),
	})
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO doc_document (
			owner_id, organization_id, template_id, kind, contact_id, handover_id,
			title, body_filled, currency, notes
		) VALUES ($1,$2,$3,'contract',$4,$5,$6,$7,'CNY',$8)
		RETURNING id
	`, ownerID, orgID, templateID, contactID, handoverID, title, filled, emptyToNil(request.Notes)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getDocDocument(r.Context(), ownerID, id, "contract")
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) issueContract(w http.ResponseWriter, r *http.Request) {
	s.issueDocDocument(w, r, "contract")
}

func (s *Server) listReceipts(w http.ResponseWriter, r *http.Request) {
	s.listDocDocuments(w, r, "receipt")
}

func (s *Server) createReceipt(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createReceiptRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "回执请求体格式不正确"))
		return
	}
	templateID, err := uuid.Parse(strings.TrimSpace(request.TemplateID))
	if err != nil {
		writeAPIError(w, r, validationError("template_id", "模板 ID 无效"))
		return
	}
	tpl, err := s.getDocTemplate(r.Context(), ownerID, templateID, "receipt")
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if request.AmountCents < 0 {
		writeAPIError(w, r, validationError("amount_cents", "金额不能为负"))
		return
	}
	currency := strings.TrimSpace(request.Currency)
	if currency == "" {
		currency = "CNY"
	}
	contactID, contactName, err := s.resolveContactRef(r.Context(), ownerID, request.ContactID, request.ContactName)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	handoverID, err := parseOptionalUUID(request.HandoverID)
	if err != nil {
		writeAPIError(w, r, validationError("handover_id", "交付单 ID 无效"))
		return
	}
	reservationID, err := parseOptionalUUID(request.ReservationID)
	if err != nil {
		writeAPIError(w, r, validationError("reservation_id", "预订 ID 无效"))
		return
	}
	hamsterName := stringOrEmpty(request.HamsterName)
	// 预订优先：继承客户/个体，并尽量关联已有交付单。
	if reservationID != nil {
		context, contextErr := s.getDocReservationContext(r.Context(), ownerID, *reservationID)
		if contextErr != nil {
			writeAPIError(w, r, contextErr)
			return
		}
		if contactID == nil {
			contact := context.ContactID
			contactID = &contact
		}
		if contactName == "" {
			contactName = context.ContactName
		}
		if hamsterName == "" {
			hamsterName = context.HamsterName
		}
		if handoverID == nil && context.HandoverID != nil {
			handoverID = context.HandoverID
		}
	}
	if handoverID != nil {
		context, contextErr := s.getDocHandoverContext(r.Context(), ownerID, *handoverID)
		if contextErr != nil {
			writeAPIError(w, r, contextErr)
			return
		}
		if contactID == nil {
			contact := context.ContactID
			contactID = &contact
		}
		if contactName == "" {
			contactName = context.ContactName
		}
		if hamsterName == "" {
			hamsterName = context.HamsterName
		}
	}
	title := strings.TrimSpace(request.Title)
	if title == "" {
		if hamsterName != "" {
			title = "收款回执 · " + hamsterName
		} else {
			title = tpl.Name
		}
	}
	amountYuan := fmt.Sprintf("%.2f", float64(request.AmountCents)/100.0)
	filled := fillDocTemplate(tpl.Body, map[string]string{
		"contact_name": contactName,
		"title":        title,
		"hamster_name": hamsterName,
		"amount":       amountYuan + " " + currency,
		"date":         time.Now().In(time.Local).Format("2006-01-02"),
		"notes":        stringOrEmpty(request.Notes),
	})
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	amount := request.AmountCents
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO doc_document (
			owner_id, organization_id, template_id, kind, contact_id, handover_id,
			title, body_filled, amount_cents, currency, notes
		) VALUES ($1,$2,$3,'receipt',$4,$5,$6,$7,$8,$9,$10)
		RETURNING id
	`, ownerID, orgID, templateID, contactID, handoverID, title, filled, amount, currency, emptyToNil(request.Notes)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getDocDocument(r.Context(), ownerID, id, "receipt")
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) issueReceipt(w http.ResponseWriter, r *http.Request) {
	s.issueDocDocument(w, r, "receipt")
}

func (s *Server) listDocTemplates(w http.ResponseWriter, r *http.Request, kind string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, kind::text, name, body_text, version
		FROM doc_template
		WHERE owner_id=$1 AND kind=$2::doc_template_kind
		ORDER BY updated_at DESC, id DESC
		LIMIT 200
	`, ownerID, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]docTemplate, 0)
	for rows.Next() {
		var item docTemplate
		if err := rows.Scan(&item.ID, &item.Kind, &item.Name, &item.Body, &item.Version); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createDocTemplate(w http.ResponseWriter, r *http.Request, kind string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createDocTemplateRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "模板请求体格式不正确"))
		return
	}
	name := strings.TrimSpace(request.Name)
	if name == "" {
		writeAPIError(w, r, validationError("name", "模板名称必填"))
		return
	}
	body := strings.TrimSpace(request.Body)
	if body == "" {
		body = defaultDocTemplateBody(kind)
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO doc_template (owner_id, organization_id, kind, name, body_text)
		VALUES ($1,$2,$3::doc_template_kind,$4,$5)
		RETURNING id
	`, ownerID, orgID, kind, name, body).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getDocTemplate(r.Context(), ownerID, id, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listDocDocuments(w http.ResponseWriter, r *http.Request, kind string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT d.id, d.template_id, d.kind::text, d.contact_id, d.handover_id, d.title, d.body_filled,
			d.amount_cents, d.currency, d.status::text, d.issued_at, d.notes, d.version,
			COALESCE(c.name, ''), d.public_token
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.owner_id=$1 AND d.kind=$2::doc_template_kind AND d.status <> 'archived'
		ORDER BY d.updated_at DESC, d.id DESC
		LIMIT 200
	`, ownerID, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]docDocument, 0)
	for rows.Next() {
		var item docDocument
		var publicToken *string
		if err := rows.Scan(
			&item.ID, &item.TemplateID, &item.Kind, &item.ContactID, &item.HandoverID, &item.Title, &item.BodyFilled,
			&item.AmountCents, &item.Currency, &item.Status, &item.IssuedAt, &item.Notes, &item.Version,
			&item.ContactName, &publicToken,
		); err != nil {
			writeAPIError(w, r, err)
			return
		}
		attachDocPublicShare(&item, publicToken)
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) issueDocDocument(w http.ResponseWriter, r *http.Request, kind string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	documentID, err := uuid.Parse(r.PathValue("document_id"))
	if err != nil {
		writeAPIError(w, r, validationError("document_id", "单据 ID 无效"))
		return
	}
	current, err := s.getDocDocument(r.Context(), ownerID, documentID, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if current.Status != "draft" {
		writeAPIError(w, r, validationError("status", "仅草稿可签发"))
		return
	}
	if match := strings.TrimSpace(r.Header.Get("If-Match")); match != "" {
		version, parseErr := store.ParseETag(match)
		if parseErr != nil {
			writeAPIError(w, r, validationError("If-Match", "版本号无效"))
			return
		}
		if version != current.Version {
			writeAPIError(w, r, store.ErrVersionConflict)
			return
		}
	}
	token := newDocPublicToken()
	tag, err := s.Store.Pool.Exec(r.Context(), `
		UPDATE doc_document
		SET status='issued', issued_at=now(),
			public_token=COALESCE(public_token, $5),
			version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND kind=$3::doc_template_kind AND status='draft' AND version=$4
	`, ownerID, documentID, kind, current.Version, token)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if tag.RowsAffected() != 1 {
		writeAPIError(w, r, store.ErrVersionConflict)
		return
	}
	item, err := s.getDocDocument(r.Context(), ownerID, documentID, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
}

// getPublicDocument 客户只读：仅已签发单据，无内部 ID/组织信息。
func (s *Server) getPublicDocument(w http.ResponseWriter, r *http.Request) {
	token := strings.TrimSpace(r.PathValue("token"))
	if token == "" || len(token) > 64 || strings.ContainsAny(token, "/\\") {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	var (
		kind, title, body, currency, contactName string
		amountCents                              *int64
		issuedAt                                 *time.Time
	)
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT d.kind::text, d.title, d.body_filled, d.amount_cents, d.currency, d.issued_at,
			COALESCE(c.name, '')
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.public_token=$1 AND d.status='issued'
	`, token).Scan(&kind, &title, &body, &amountCents, &currency, &issuedAt, &contactName)
	if errors.Is(err, pgx.ErrNoRows) {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	kindLabel := "合同"
	if kind == "receipt" {
		kindLabel = "回执"
	}
	data := map[string]any{
		"kind":         kind,
		"kind_label":   kindLabel,
		"title":        title,
		"body_filled":  body,
		"currency":     currency,
		"contact_name": contactName,
		"issued_at":    issuedAt,
		"status":       "issued",
	}
	if amountCents != nil {
		data["amount_cents"] = *amountCents
		data["amount_label"] = fmt.Sprintf("%.2f %s", float64(*amountCents)/100.0, currency)
	}
	w.Header().Set("Cache-Control", "no-store")
	writeJSON(w, r, http.StatusOK, envelope(r, data))
}

func (s *Server) getDocTemplate(ctx context.Context, ownerID, id uuid.UUID, kind string) (docTemplate, error) {
	var item docTemplate
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, kind::text, name, body_text, version
		FROM doc_template
		WHERE owner_id=$1 AND id=$2 AND kind=$3::doc_template_kind
	`, ownerID, id, kind).Scan(&item.ID, &item.Kind, &item.Name, &item.Body, &item.Version)
	if errors.Is(err, pgx.ErrNoRows) {
		return docTemplate{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) getDocDocument(ctx context.Context, ownerID, id uuid.UUID, kind string) (docDocument, error) {
	var item docDocument
	var publicToken *string
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT d.id, d.template_id, d.kind::text, d.contact_id, d.handover_id, d.title, d.body_filled,
			d.amount_cents, d.currency, d.status::text, d.issued_at, d.notes, d.version,
			COALESCE(c.name, ''), d.public_token
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.owner_id=$1 AND d.id=$2 AND d.kind=$3::doc_template_kind
	`, ownerID, id, kind).Scan(
		&item.ID, &item.TemplateID, &item.Kind, &item.ContactID, &item.HandoverID, &item.Title, &item.BodyFilled,
		&item.AmountCents, &item.Currency, &item.Status, &item.IssuedAt, &item.Notes, &item.Version,
		&item.ContactName, &publicToken,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return docDocument{}, store.ErrNotFound
	}
	if err != nil {
		return docDocument{}, err
	}
	attachDocPublicShare(&item, publicToken)
	return item, nil
}

func attachDocPublicShare(item *docDocument, publicToken *string) {
	if item == nil || publicToken == nil || strings.TrimSpace(*publicToken) == "" {
		return
	}
	if item.Status != "issued" {
		return
	}
	token := strings.TrimSpace(*publicToken)
	item.PublicToken = &token
	path := "/d/" + token
	item.PublicPath = &path
}

func newDocPublicToken() string {
	// 能力令牌：doc_ + 32 hex（足够不可猜测）
	return "doc_" + strings.ReplaceAll(uuid.NewString(), "-", "")
}

func (s *Server) resolveContactRef(ctx context.Context, ownerID uuid.UUID, contactIDRaw, contactNameOverride *string) (*uuid.UUID, string, error) {
	contactName := ""
	if contactNameOverride != nil {
		contactName = strings.TrimSpace(*contactNameOverride)
	}
	if contactIDRaw == nil || strings.TrimSpace(*contactIDRaw) == "" {
		return nil, contactName, nil
	}
	contactID, err := uuid.Parse(strings.TrimSpace(*contactIDRaw))
	if err != nil {
		return nil, "", validationError("contact_id", "客户 ID 无效")
	}
	var name string
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT name FROM crm_contact
		WHERE owner_id=$1 AND id=$2 AND status <> 'archived'
	`, ownerID, contactID).Scan(&name)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, "", validationError("contact_id", "客户不存在")
	}
	if err != nil {
		return nil, "", err
	}
	if contactName == "" {
		contactName = name
	}
	return &contactID, contactName, nil
}

func (s *Server) ensureHandoverOwned(ctx context.Context, ownerID, handoverID uuid.UUID) error {
	var count int
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM crm_handover WHERE owner_id=$1 AND id=$2
	`, ownerID, handoverID).Scan(&count)
	if err != nil {
		return err
	}
	if count == 0 {
		return validationError("handover_id", "交付单不存在")
	}
	return nil
}

type docHandoverContext struct {
	ContactID   uuid.UUID
	ContactName string
	HamsterName string
}

type docReservationContext struct {
	ContactID   uuid.UUID
	ContactName string
	HamsterName string
	// 若该预订已有未取消交付单，附带便于合同关联。
	HandoverID *uuid.UUID
}

func (s *Server) getDocHandoverContext(ctx context.Context, ownerID, handoverID uuid.UUID) (docHandoverContext, error) {
	var value docHandoverContext
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT h.contact_id, c.name,
			COALESCE(NULLIF(hamster.name,''), hamster.internal_code, '')
		FROM crm_handover h
		JOIN crm_contact c ON c.owner_id=h.owner_id AND c.id=h.contact_id
		LEFT JOIN hamster ON hamster.owner_id=h.owner_id AND hamster.id=h.hamster_id AND hamster.deleted_at IS NULL
		WHERE h.owner_id=$1 AND h.id=$2
	`, ownerID, handoverID).Scan(
		&value.ContactID,
		&value.ContactName,
		&value.HamsterName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return docHandoverContext{}, validationError("handover_id", "交付单不存在")
	}
	return value, err
}

func (s *Server) getDocReservationContext(ctx context.Context, ownerID, reservationID uuid.UUID) (docReservationContext, error) {
	var value docReservationContext
	var status string
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT r.contact_id, c.name,
			COALESCE(NULLIF(hamster.name,''), hamster.internal_code, ''),
			r.status::text
		FROM crm_reservation r
		JOIN crm_contact c ON c.owner_id=r.owner_id AND c.id=r.contact_id
		LEFT JOIN hamster ON hamster.owner_id=r.owner_id AND hamster.id=r.hamster_id AND hamster.deleted_at IS NULL
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, reservationID).Scan(
		&value.ContactID,
		&value.ContactName,
		&value.HamsterName,
		&status,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return docReservationContext{}, validationError("reservation_id", "预订不存在")
	}
	if err != nil {
		return docReservationContext{}, err
	}
	if status == "cancelled" {
		return docReservationContext{}, validationError("reservation_id", "已取消的预订不能生成合同")
	}
	var handoverID uuid.UUID
	err = s.Store.Pool.QueryRow(ctx, `
		SELECT id FROM crm_handover
		WHERE owner_id=$1 AND reservation_id=$2 AND status <> 'cancelled'
		ORDER BY scheduled_at DESC, id DESC
		LIMIT 1
	`, ownerID, reservationID).Scan(&handoverID)
	if err == nil {
		value.HandoverID = &handoverID
	} else if !errors.Is(err, pgx.ErrNoRows) {
		return docReservationContext{}, err
	}
	return value, nil
}

func fillDocTemplate(body string, vars map[string]string) string {
	out := body
	for key, value := range vars {
		out = strings.ReplaceAll(out, "{{"+key+"}}", value)
	}
	return out
}

func defaultDocTemplateBody(kind string) string {
	if kind == "receipt" {
		return "订金收款回执\n\n客户：{{contact_name}}\n收款项目：{{title}}\n关联个体：{{hamster_name}}\n收款金额：{{amount}}\n收款日期：{{date}}\n\n现确认收到以上款项。本回执用于记录本次收款，后续交付内容以双方确认的预订和交接记录为准。\n\n备注：{{notes}}\n\n经办确认：________________\n客户确认：________________"
	}
	return "仓鼠交接协议\n\n客户：{{contact_name}}\n交接事项：{{title}}\n交接个体：{{hamster_name}}\n交接日期：{{date}}\n\n一、熊舍已向客户说明该个体的基础档案、近期观察、日常饮食与饲养注意事项。\n二、客户已核对交接个体，并确认收到双方约定的随附用品和资料。\n三、交接后的环境、饮食和作息调整应循序渐进；如出现异常，应及时联系熊舍并寻求专业兽医意见。\n四、双方确认本协议记录的信息真实、完整，未填写事项以双方另行确认的记录为准。\n\n补充约定：{{notes}}\n\n熊舍确认：________________\n客户确认：________________"
}

func stringOrEmpty(value *string) string {
	if value == nil {
		return ""
	}
	return strings.TrimSpace(*value)
}

func parseOptionalUUID(raw *string) (*uuid.UUID, error) {
	if raw == nil || strings.TrimSpace(*raw) == "" {
		return nil, nil
	}
	id, err := uuid.Parse(strings.TrimSpace(*raw))
	if err != nil {
		return nil, err
	}
	return &id, nil
}
