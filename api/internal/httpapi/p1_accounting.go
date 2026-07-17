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

func (s *Server) registerP1AccountingRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/accounting/categories", s.listAccountingCategories)
	mux.HandleFunc("POST /v1/accounting/categories", s.createAccountingCategory)
	mux.HandleFunc("GET /v1/accounting/records", s.listAccountingRecords)
	mux.HandleFunc("POST /v1/accounting/records", s.createAccountingRecord)
	mux.HandleFunc("GET /v1/accounting/summary", s.getAccountingSummary)
}

type accountingCategory struct {
	ID        uuid.UUID `json:"id"`
	EntryType string    `json:"entry_type"`
	Name      string    `json:"name"`
	SortOrder int       `json:"sort_order"`
	Version   int       `json:"version"`
}

type accountingRecord struct {
	ID           uuid.UUID  `json:"id"`
	CategoryID   *uuid.UUID `json:"category_id,omitempty"`
	EntryType    string     `json:"entry_type"`
	AmountCents  int64      `json:"amount_cents"`
	Currency     string     `json:"currency"`
	Title        string     `json:"title"`
	Notes        *string    `json:"notes,omitempty"`
	ContactID    *uuid.UUID `json:"contact_id,omitempty"`
	OccurredAt   time.Time  `json:"occurred_at"`
	Version      int        `json:"version"`
	CategoryName string     `json:"category_name,omitempty"`
	ContactName  string     `json:"contact_name,omitempty"`
}

type accountingSummary struct {
	From           time.Time                `json:"from"`
	To             time.Time                `json:"to"`
	IncomeCents    int64                    `json:"income_cents"`
	ExpenseCents   int64                    `json:"expense_cents"`
	NetCents       int64                    `json:"net_cents"`
	Currency       string                   `json:"currency"`
	RecordCount    int                      `json:"record_count"`
	ByCategory     []accountingCategorySum  `json:"by_category"`
}

type accountingCategorySum struct {
	CategoryID   *uuid.UUID `json:"category_id,omitempty"`
	CategoryName string     `json:"category_name"`
	EntryType    string     `json:"entry_type"`
	AmountCents  int64      `json:"amount_cents"`
	Count        int        `json:"count"`
}

type createAccountingCategoryRequest struct {
	EntryType string `json:"entry_type"`
	Name      string `json:"name"`
	SortOrder *int   `json:"sort_order"`
}

type createAccountingRecordRequest struct {
	CategoryID  *string `json:"category_id"`
	EntryType   string  `json:"entry_type"`
	AmountCents int64   `json:"amount_cents"`
	Currency    string  `json:"currency"`
	Title       string  `json:"title"`
	Notes       *string `json:"notes"`
	ContactID   *string `json:"contact_id"`
	OccurredAt  *string `json:"occurred_at"`
}

func (s *Server) listAccountingCategories(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	entryType := strings.TrimSpace(r.URL.Query().Get("entry_type"))
	query := `
		SELECT id, entry_type::text, name, sort_order, version
		FROM accounting_category
		WHERE owner_id=$1
	`
	args := []any{ownerID}
	if entryType != "" {
		if !validAccountingEntryType(entryType) {
			writeAPIError(w, r, validationError("entry_type", "类型无效"))
			return
		}
		query += ` AND entry_type=$2::accounting_entry_type`
		args = append(args, entryType)
	}
	query += ` ORDER BY sort_order ASC, name ASC, id ASC LIMIT 200`
	rows, err := s.Store.Pool.Query(r.Context(), query, args...)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]accountingCategory, 0)
	for rows.Next() {
		var item accountingCategory
		if err := rows.Scan(&item.ID, &item.EntryType, &item.Name, &item.SortOrder, &item.Version); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createAccountingCategory(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createAccountingCategoryRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "分类请求体格式不正确"))
		return
	}
	entryType := strings.TrimSpace(request.EntryType)
	if !validAccountingEntryType(entryType) {
		writeAPIError(w, r, validationError("entry_type", "类型须为 income 或 expense"))
		return
	}
	name := strings.TrimSpace(request.Name)
	if name == "" {
		writeAPIError(w, r, validationError("name", "分类名称必填"))
		return
	}
	sortOrder := 0
	if request.SortOrder != nil {
		sortOrder = *request.SortOrder
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO accounting_category (owner_id, organization_id, entry_type, name, sort_order)
		VALUES ($1,$2,$3::accounting_entry_type,$4,$5)
		RETURNING id
	`, ownerID, orgID, entryType, name, sortOrder).Scan(&id)
	if err != nil {
		if isUniqueViolation(err) {
			writeAPIError(w, r, validationError("name", "同类型分类名称已存在"))
			return
		}
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getAccountingCategory(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) listAccountingRecords(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	entryType := strings.TrimSpace(r.URL.Query().Get("entry_type"))
	query := `
		SELECT r.id, r.category_id, r.entry_type::text, r.amount_cents, r.currency, r.title, r.notes,
			r.contact_id, r.occurred_at, r.version,
			COALESCE(c.name, ''), COALESCE(ct.name, '')
		FROM accounting_record r
		LEFT JOIN accounting_category c ON c.owner_id=r.owner_id AND c.id=r.category_id
		LEFT JOIN crm_contact ct ON ct.owner_id=r.owner_id AND ct.id=r.contact_id
		WHERE r.owner_id=$1
	`
	args := []any{ownerID}
	argN := 2
	if entryType != "" {
		if !validAccountingEntryType(entryType) {
			writeAPIError(w, r, validationError("entry_type", "类型无效"))
			return
		}
		query += fmt.Sprintf(` AND r.entry_type=$%d::accounting_entry_type`, argN)
		args = append(args, entryType)
		argN++
	}
	if fromRaw := strings.TrimSpace(r.URL.Query().Get("from")); fromRaw != "" {
		from, err := time.Parse(time.RFC3339, fromRaw)
		if err != nil {
			// also allow date-only
			from, err = time.ParseInLocation("2006-01-02", fromRaw, time.Local)
			if err != nil {
				writeAPIError(w, r, validationError("from", "起始时间格式无效"))
				return
			}
		}
		query += fmt.Sprintf(` AND r.occurred_at >= $%d`, argN)
		args = append(args, from.UTC())
		argN++
	}
	if toRaw := strings.TrimSpace(r.URL.Query().Get("to")); toRaw != "" {
		to, err := time.Parse(time.RFC3339, toRaw)
		if err != nil {
			to, err = time.ParseInLocation("2006-01-02", toRaw, time.Local)
			if err != nil {
				writeAPIError(w, r, validationError("to", "结束时间格式无效"))
				return
			}
			to = to.Add(24*time.Hour - time.Nanosecond)
		}
		query += fmt.Sprintf(` AND r.occurred_at <= $%d`, argN)
		args = append(args, to.UTC())
	}
	query += ` ORDER BY r.occurred_at DESC, r.id DESC LIMIT 200`
	rows, err := s.Store.Pool.Query(r.Context(), query, args...)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]accountingRecord, 0)
	for rows.Next() {
		var item accountingRecord
		if err := rows.Scan(
			&item.ID, &item.CategoryID, &item.EntryType, &item.AmountCents, &item.Currency, &item.Title, &item.Notes,
			&item.ContactID, &item.OccurredAt, &item.Version, &item.CategoryName, &item.ContactName,
		); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createAccountingRecord(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createAccountingRecordRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "记账请求体格式不正确"))
		return
	}
	entryType := strings.TrimSpace(request.EntryType)
	if !validAccountingEntryType(entryType) {
		writeAPIError(w, r, validationError("entry_type", "类型须为 income 或 expense"))
		return
	}
	if request.AmountCents <= 0 {
		writeAPIError(w, r, validationError("amount_cents", "金额须大于 0"))
		return
	}
	title := strings.TrimSpace(request.Title)
	if title == "" {
		writeAPIError(w, r, validationError("title", "标题必填"))
		return
	}
	currency := strings.TrimSpace(request.Currency)
	if currency == "" {
		currency = "CNY"
	}
	var categoryID *uuid.UUID
	if request.CategoryID != nil && strings.TrimSpace(*request.CategoryID) != "" {
		id, err := uuid.Parse(strings.TrimSpace(*request.CategoryID))
		if err != nil {
			writeAPIError(w, r, validationError("category_id", "分类 ID 无效"))
			return
		}
		cat, err := s.getAccountingCategory(r.Context(), ownerID, id)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		if cat.EntryType != entryType {
			writeAPIError(w, r, validationError("category_id", "分类收支类型不匹配"))
			return
		}
		categoryID = &id
	}
	contactID, _, err := s.resolveContactRef(r.Context(), ownerID, request.ContactID, nil)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	occurredAt := time.Now().UTC()
	if request.OccurredAt != nil && strings.TrimSpace(*request.OccurredAt) != "" {
		parsed, parseErr := time.Parse(time.RFC3339, strings.TrimSpace(*request.OccurredAt))
		if parseErr != nil {
			parsed, parseErr = time.ParseInLocation("2006-01-02", strings.TrimSpace(*request.OccurredAt), time.Local)
			if parseErr != nil {
				writeAPIError(w, r, validationError("occurred_at", "发生时间格式无效"))
				return
			}
		}
		occurredAt = parsed.UTC()
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO accounting_record (
			owner_id, organization_id, category_id, entry_type, amount_cents, currency,
			title, notes, contact_id, occurred_at
		) VALUES ($1,$2,$3,$4::accounting_entry_type,$5,$6,$7,$8,$9,$10)
		RETURNING id
	`, ownerID, orgID, categoryID, entryType, request.AmountCents, currency, title, emptyToNil(request.Notes), contactID, occurredAt).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getAccountingRecord(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) getAccountingSummary(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	now := time.Now().In(time.Local)
	from := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.Local)
	to := from.AddDate(0, 1, 0).Add(-time.Nanosecond)
	if fromRaw := strings.TrimSpace(r.URL.Query().Get("from")); fromRaw != "" {
		parsed, err := time.Parse(time.RFC3339, fromRaw)
		if err != nil {
			parsed, err = time.ParseInLocation("2006-01-02", fromRaw, time.Local)
			if err != nil {
				writeAPIError(w, r, validationError("from", "起始时间格式无效"))
				return
			}
		}
		from = parsed
	}
	if toRaw := strings.TrimSpace(r.URL.Query().Get("to")); toRaw != "" {
		parsed, err := time.Parse(time.RFC3339, toRaw)
		if err != nil {
			parsed, err = time.ParseInLocation("2006-01-02", toRaw, time.Local)
			if err != nil {
				writeAPIError(w, r, validationError("to", "结束时间格式无效"))
				return
			}
			parsed = parsed.Add(24*time.Hour - time.Nanosecond)
		}
		to = parsed
	}
	var income, expense int64
	var count int
	err := s.Store.Pool.QueryRow(r.Context(), `
		SELECT
			COALESCE(SUM(CASE WHEN entry_type='income' THEN amount_cents ELSE 0 END), 0),
			COALESCE(SUM(CASE WHEN entry_type='expense' THEN amount_cents ELSE 0 END), 0),
			COUNT(*)
		FROM accounting_record
		WHERE owner_id=$1 AND occurred_at >= $2 AND occurred_at <= $3
	`, ownerID, from.UTC(), to.UTC()).Scan(&income, &expense, &count)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT r.category_id, COALESCE(c.name, '未分类'), r.entry_type::text,
			SUM(r.amount_cents), COUNT(*)
		FROM accounting_record r
		LEFT JOIN accounting_category c ON c.owner_id=r.owner_id AND c.id=r.category_id
		WHERE r.owner_id=$1 AND r.occurred_at >= $2 AND r.occurred_at <= $3
		GROUP BY r.category_id, c.name, r.entry_type
		ORDER BY SUM(r.amount_cents) DESC
	`, ownerID, from.UTC(), to.UTC())
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	byCategory := make([]accountingCategorySum, 0)
	for rows.Next() {
		var item accountingCategorySum
		if err := rows.Scan(&item.CategoryID, &item.CategoryName, &item.EntryType, &item.AmountCents, &item.Count); err != nil {
			writeAPIError(w, r, err)
			return
		}
		byCategory = append(byCategory, item)
	}
	summary := accountingSummary{
		From:         from.UTC(),
		To:           to.UTC(),
		IncomeCents:  income,
		ExpenseCents: expense,
		NetCents:     income - expense,
		Currency:     "CNY",
		RecordCount:  count,
		ByCategory:   byCategory,
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": summary, "meta": responseMeta(r)})
}

func (s *Server) getAccountingCategory(ctx context.Context, ownerID, id uuid.UUID) (accountingCategory, error) {
	var item accountingCategory
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, entry_type::text, name, sort_order, version
		FROM accounting_category
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id).Scan(&item.ID, &item.EntryType, &item.Name, &item.SortOrder, &item.Version)
	if errors.Is(err, pgx.ErrNoRows) {
		return accountingCategory{}, store.ErrNotFound
	}
	return item, err
}

func (s *Server) getAccountingRecord(ctx context.Context, ownerID, id uuid.UUID) (accountingRecord, error) {
	var item accountingRecord
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT r.id, r.category_id, r.entry_type::text, r.amount_cents, r.currency, r.title, r.notes,
			r.contact_id, r.occurred_at, r.version,
			COALESCE(c.name, ''), COALESCE(ct.name, '')
		FROM accounting_record r
		LEFT JOIN accounting_category c ON c.owner_id=r.owner_id AND c.id=r.category_id
		LEFT JOIN crm_contact ct ON ct.owner_id=r.owner_id AND ct.id=r.contact_id
		WHERE r.owner_id=$1 AND r.id=$2
	`, ownerID, id).Scan(
		&item.ID, &item.CategoryID, &item.EntryType, &item.AmountCents, &item.Currency, &item.Title, &item.Notes,
		&item.ContactID, &item.OccurredAt, &item.Version, &item.CategoryName, &item.ContactName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return accountingRecord{}, store.ErrNotFound
	}
	return item, err
}

func validAccountingEntryType(value string) bool {
	return value == "income" || value == "expense"
}
