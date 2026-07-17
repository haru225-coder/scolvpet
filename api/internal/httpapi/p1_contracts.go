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
}

type createDocTemplateRequest struct {
	Name string `json:"name"`
	Body string `json:"body_text"`
}

type createContractRequest struct {
	TemplateID string  `json:"template_id"`
	ContactID  *string `json:"contact_id"`
	HandoverID *string `json:"handover_id"`
	Title      string  `json:"title"`
	Notes      *string `json:"notes"`
	// Optional overrides for variable fill.
	ContactName *string `json:"contact_name"`
	HamsterName *string `json:"hamster_name"`
}

type createReceiptRequest struct {
	TemplateID  string  `json:"template_id"`
	ContactID   *string `json:"contact_id"`
	Title       string  `json:"title"`
	AmountCents int64   `json:"amount_cents"`
	Currency    string  `json:"currency"`
	Notes       *string `json:"notes"`
	ContactName *string `json:"contact_name"`
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
	if handoverID != nil {
		if err := s.ensureHandoverOwned(r.Context(), ownerID, *handoverID); err != nil {
			writeAPIError(w, r, err)
			return
		}
	}
	title := strings.TrimSpace(request.Title)
	if title == "" {
		title = tpl.Name
	}
	hamsterName := ""
	if request.HamsterName != nil {
		hamsterName = strings.TrimSpace(*request.HamsterName)
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
	title := strings.TrimSpace(request.Title)
	if title == "" {
		title = tpl.Name
	}
	amountYuan := fmt.Sprintf("%.2f", float64(request.AmountCents)/100.0)
	filled := fillDocTemplate(tpl.Body, map[string]string{
		"contact_name": contactName,
		"title":        title,
		"hamster_name": "",
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
			owner_id, organization_id, template_id, kind, contact_id,
			title, body_filled, amount_cents, currency, notes
		) VALUES ($1,$2,$3,'receipt',$4,$5,$6,$7,$8,$9)
		RETURNING id
	`, ownerID, orgID, templateID, contactID, title, filled, amount, currency, emptyToNil(request.Notes)).Scan(&id)
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
			COALESCE(c.name, '')
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
		if err := rows.Scan(
			&item.ID, &item.TemplateID, &item.Kind, &item.ContactID, &item.HandoverID, &item.Title, &item.BodyFilled,
			&item.AmountCents, &item.Currency, &item.Status, &item.IssuedAt, &item.Notes, &item.Version,
			&item.ContactName,
		); err != nil {
			writeAPIError(w, r, err)
			return
		}
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
	_, err = s.Store.Pool.Exec(r.Context(), `
		UPDATE doc_document
		SET status='issued', issued_at=now(), version=version+1, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND kind=$3::doc_template_kind AND status='draft' AND version=$4
	`, ownerID, documentID, kind, current.Version)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getDocDocument(r.Context(), ownerID, documentID, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": item, "meta": responseMeta(r)})
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
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT d.id, d.template_id, d.kind::text, d.contact_id, d.handover_id, d.title, d.body_filled,
			d.amount_cents, d.currency, d.status::text, d.issued_at, d.notes, d.version,
			COALESCE(c.name, '')
		FROM doc_document d
		LEFT JOIN crm_contact c ON c.owner_id=d.owner_id AND c.id=d.contact_id
		WHERE d.owner_id=$1 AND d.id=$2 AND d.kind=$3::doc_template_kind
	`, ownerID, id, kind).Scan(
		&item.ID, &item.TemplateID, &item.Kind, &item.ContactID, &item.HandoverID, &item.Title, &item.BodyFilled,
		&item.AmountCents, &item.Currency, &item.Status, &item.IssuedAt, &item.Notes, &item.Version,
		&item.ContactName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return docDocument{}, store.ErrNotFound
	}
	return item, err
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

func fillDocTemplate(body string, vars map[string]string) string {
	out := body
	for key, value := range vars {
		out = strings.ReplaceAll(out, "{{"+key+"}}", value)
	}
	return out
}

func defaultDocTemplateBody(kind string) string {
	if kind == "receipt" {
		return "回执\n\n客户：{{contact_name}}\n项目：{{title}}\n金额：{{amount}}\n日期：{{date}}\n备注：{{notes}}\n\n已确认收款。"
	}
	return "交接协议\n\n客户：{{contact_name}}\n项目：{{title}}\n个体：{{hamster_name}}\n日期：{{date}}\n\n双方确认交付事项。\n备注：{{notes}}"
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
