package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

var memberPhonePattern = regexp.MustCompile(`^[0-9]{6,20}$`)

func (s *Server) registerP1MemberRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/organization-members", s.listOrganizationMembers)
	mux.HandleFunc("POST /v1/organization-members", s.inviteOrganizationMember)
	mux.HandleFunc("PATCH /v1/organization-members/{member_id}", s.updateOrganizationMember)
	mux.HandleFunc("POST /v1/organization-members/{member_id}/revoke", s.revokeOrganizationMember)
}

type organizationMember struct {
	ID             uuid.UUID  `json:"id"`
	OrganizationID uuid.UUID  `json:"organization_id"`
	AccountID      *uuid.UUID `json:"account_id,omitempty"`
	Phone          string     `json:"phone"`
	DisplayName    *string    `json:"display_name,omitempty"`
	Role           string     `json:"role"`
	Status         string     `json:"status"`
	InvitedAt      time.Time  `json:"invited_at"`
	AcceptedAt     *time.Time `json:"accepted_at,omitempty"`
	RevokedAt      *time.Time `json:"revoked_at,omitempty"`
	Version        int        `json:"version"`
}

type inviteMemberRequest struct {
	Phone       string  `json:"phone"`
	Role        string  `json:"role"`
	DisplayName *string `json:"display_name"`
}

type updateMemberRequest struct {
	Role        *string `json:"role"`
	DisplayName *string `json:"display_name"`
}

func (s *Server) listOrganizationMembers(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := s.ensureOwnerMember(r.Context(), ownerID, orgID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, organization_id, account_id, phone, display_name, role::text, status::text,
			invited_at, accepted_at, revoked_at, version
		FROM organization_member
		WHERE owner_id=$1 AND organization_id=$2 AND status <> 'revoked'
		ORDER BY
			CASE role::text
				WHEN 'owner' THEN 0
				WHEN 'breeder' THEN 1
				WHEN 'caretaker' THEN 2
				WHEN 'staff' THEN 3
				ELSE 4
			END,
			invited_at ASC, id ASC
	`, ownerID, orgID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]organizationMember, 0)
	for rows.Next() {
		item, scanErr := scanOrganizationMember(rows)
		if scanErr != nil {
			writeAPIError(w, r, scanErr)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": items,
		"meta": responseMeta(r),
	})
}

func (s *Server) inviteOrganizationMember(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request inviteMemberRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeAPIError(w, r, validationError("body", "邀请请求体格式不正确"))
		return
	}
	phone := normalizeMemberPhone(request.Phone)
	role := strings.TrimSpace(request.Role)
	if !memberPhonePattern.MatchString(phone) {
		writeAPIError(w, r, validationError("phone", "请输入有效手机号"))
		return
	}
	if !validMemberRole(role) || role == "owner" {
		writeAPIError(w, r, validationError("role", "角色无效（不可邀请 owner）"))
		return
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if err := s.ensureOwnerMember(r.Context(), ownerID, orgID); err != nil {
		writeAPIError(w, r, err)
		return
	}
	result, err := s.Store.RunIdempotent(
		r.Context(),
		ownerID,
		r.Header.Get("Idempotency-Key"),
		http.MethodPost,
		r.URL.Path,
		payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			var accountID *uuid.UUID
			var existing uuid.UUID
			err := tx.QueryRow(ctx, `
				SELECT id FROM account
				WHERE phone_number=$1 AND deleted_at IS NULL
				LIMIT 1
			`, phone).Scan(&existing)
			if err == nil {
				accountID = &existing
			} else if !errors.Is(err, pgx.ErrNoRows) {
				return 0, nil, nil, err
			}
			row := tx.QueryRow(ctx, `
				INSERT INTO organization_member (
					owner_id, organization_id, account_id, phone, display_name,
					role, status, invited_at
				) VALUES ($1,$2,$3,$4,$5,$6::organization_member_role,'invited',now())
				RETURNING id, organization_id, account_id, phone, display_name,
					role::text, status::text, invited_at, accepted_at, revoked_at, version
			`, ownerID, orgID, accountID, phone, request.DisplayName, role)
			member, err := scanOrganizationMember(row)
			if err != nil {
				if isUniqueViolation(err) {
					return 0, nil, nil, validationError("phone", "该手机号已在成员列表中")
				}
				return 0, nil, nil, err
			}
			return http.StatusCreated, memberEnvelope(r, member), map[string]string{
				"ETag": store.FormatETag(member.Version),
			}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) updateOrganizationMember(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	memberID, err := uuid.Parse(r.PathValue("member_id"))
	if err != nil || memberID == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	var request updateMemberRequest
	payload, err := decodeBody(r, &request)
	if err != nil {
		writeAPIError(w, r, validationError("body", "更新请求体格式不正确"))
		return
	}
	if request.Role == nil && request.DisplayName == nil {
		writeAPIError(w, r, validationError("body", "至少提供 role 或 display_name"))
		return
	}
	result, err := s.Store.RunIdempotent(
		r.Context(),
		ownerID,
		r.Header.Get("Idempotency-Key"),
		http.MethodPatch,
		r.URL.Path,
		payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			current, err := getOrganizationMemberForUpdate(ctx, tx, ownerID, memberID)
			if err != nil {
				return 0, nil, nil, err
			}
			if err := validateMemberIfMatch(r.Header.Get("If-Match"), current.Version); err != nil {
				return 0, nil, nil, err
			}
			if current.Status == "revoked" {
				return 0, nil, nil, validationError("status", "已撤销成员不可修改")
			}
			if current.Role == "owner" {
				return 0, nil, nil, validationError("role", "不可修改舍主角色")
			}
			role := current.Role
			if request.Role != nil {
				role = strings.TrimSpace(*request.Role)
				if !validMemberRole(role) || role == "owner" {
					return 0, nil, nil, validationError("role", "角色无效")
				}
			}
			displayName := current.DisplayName
			if request.DisplayName != nil {
				displayName = request.DisplayName
			}
			row := tx.QueryRow(ctx, `
				UPDATE organization_member
				SET role=$4::organization_member_role,
					display_name=$5,
					version=version+1,
					updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND version=$3 AND status <> 'revoked'
				RETURNING id, organization_id, account_id, phone, display_name,
					role::text, status::text, invited_at, accepted_at, revoked_at, version
			`, ownerID, memberID, current.Version, role, displayName)
			member, err := scanOrganizationMember(row)
			if errors.Is(err, store.ErrNotFound) {
				return 0, nil, nil, &store.VersionError{Current: current.Version}
			}
			if err != nil {
				return 0, nil, nil, err
			}
			return http.StatusOK, memberEnvelope(r, member), map[string]string{
				"ETag": store.FormatETag(member.Version),
			}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) revokeOrganizationMember(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	memberID, err := uuid.Parse(r.PathValue("member_id"))
	if err != nil || memberID == uuid.Nil {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	payload, _ := json.Marshal(map[string]string{
		"member_id": memberID.String(),
		"if_match":  strings.TrimSpace(r.Header.Get("If-Match")),
	})
	result, err := s.Store.RunIdempotent(
		r.Context(),
		ownerID,
		r.Header.Get("Idempotency-Key"),
		http.MethodPost,
		r.URL.Path,
		payload,
		func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
			current, err := getOrganizationMemberForUpdate(ctx, tx, ownerID, memberID)
			if err != nil {
				return 0, nil, nil, err
			}
			if err := validateMemberIfMatch(r.Header.Get("If-Match"), current.Version); err != nil {
				return 0, nil, nil, err
			}
			if current.Role == "owner" {
				return 0, nil, nil, validationError("role", "不可撤销舍主")
			}
			if current.Status == "revoked" {
				return http.StatusOK, memberEnvelope(r, current), map[string]string{
					"ETag": store.FormatETag(current.Version),
				}, nil
			}
			row := tx.QueryRow(ctx, `
				UPDATE organization_member
				SET status='revoked', revoked_at=now(), version=version+1, updated_at=now()
				WHERE owner_id=$1 AND id=$2 AND version=$3
				RETURNING id, organization_id, account_id, phone, display_name,
					role::text, status::text, invited_at, accepted_at, revoked_at, version
			`, ownerID, memberID, current.Version)
			member, err := scanOrganizationMember(row)
			if errors.Is(err, store.ErrNotFound) {
				return 0, nil, nil, &store.VersionError{Current: current.Version}
			}
			if err != nil {
				return 0, nil, nil, err
			}
			return http.StatusOK, memberEnvelope(r, member), map[string]string{
				"ETag": store.FormatETag(member.Version),
			}, nil
		},
	)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeStored(w, r, result)
}

func (s *Server) authenticateMemberOwner(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}

func (s *Server) currentOrganizationID(ctx context.Context, ownerID uuid.UUID) (uuid.UUID, error) {
	org, err := s.Store.GetCurrentOrganization(ctx, ownerID)
	if err != nil {
		return uuid.Nil, err
	}
	return uuid.Parse(org.ID)
}

func (s *Server) ensureOwnerMember(ctx context.Context, ownerID, orgID uuid.UUID) error {
	var count int
	if err := s.Store.Pool.QueryRow(ctx, `
		SELECT count(*) FROM organization_member
		WHERE owner_id=$1 AND organization_id=$2 AND role='owner' AND status='active'
	`, ownerID, orgID).Scan(&count); err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	var phone string
	var displayName *string
	if err := s.Store.Pool.QueryRow(ctx, `
		SELECT phone_number, display_name FROM account WHERE id=$1 AND deleted_at IS NULL
	`, ownerID).Scan(&phone, &displayName); err != nil {
		return err
	}
	_, err := s.Store.Pool.Exec(ctx, `
		INSERT INTO organization_member (
			owner_id, organization_id, account_id, phone, display_name, role, status, invited_at, accepted_at
		) VALUES ($1,$2,$1,$3,$4,'owner','active',now(),now())
	`, ownerID, orgID, phone, displayName)
	if err != nil && isUniqueViolation(err) {
		return nil
	}
	return err
}

func (s *Server) getOrganizationMember(ctx context.Context, ownerID, memberID uuid.UUID) (organizationMember, error) {
	row := s.Store.Pool.QueryRow(ctx, `
		SELECT id, organization_id, account_id, phone, display_name, role::text, status::text,
			invited_at, accepted_at, revoked_at, version
		FROM organization_member
		WHERE owner_id=$1 AND id=$2
	`, ownerID, memberID)
	return scanOrganizationMember(row)
}

func getOrganizationMemberForUpdate(
	ctx context.Context,
	tx pgx.Tx,
	ownerID uuid.UUID,
	memberID uuid.UUID,
) (organizationMember, error) {
	row := tx.QueryRow(ctx, `
		SELECT id, organization_id, account_id, phone, display_name, role::text, status::text,
			invited_at, accepted_at, revoked_at, version
		FROM organization_member
		WHERE owner_id=$1 AND id=$2
		FOR UPDATE
	`, ownerID, memberID)
	return scanOrganizationMember(row)
}

func validateMemberIfMatch(value string, currentVersion int) error {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil
	}
	version, err := store.ParseETag(value)
	if err != nil {
		return validationError("If-Match", "If-Match 必须是当前成员版本 ETag")
	}
	if version != currentVersion {
		return &store.VersionError{Current: currentVersion}
	}
	return nil
}

func memberEnvelope(r *http.Request, member organizationMember) map[string]any {
	return map[string]any{
		"data": member,
		"meta": responseMeta(r),
	}
}

func scanOrganizationMember(row pgx.Row) (organizationMember, error) {
	var item organizationMember
	err := row.Scan(
		&item.ID, &item.OrganizationID, &item.AccountID, &item.Phone, &item.DisplayName,
		&item.Role, &item.Status, &item.InvitedAt, &item.AcceptedAt, &item.RevokedAt, &item.Version,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return organizationMember{}, store.ErrNotFound
	}
	return item, err
}

func validMemberRole(role string) bool {
	switch role {
	case "owner", "breeder", "caretaker", "staff", "viewer":
		return true
	default:
		return false
	}
}

func normalizeMemberPhone(value string) string {
	value = strings.TrimSpace(value)
	value = strings.TrimPrefix(value, "+86")
	value = strings.TrimPrefix(value, "86")
	return strings.TrimSpace(value)
}

// isUniqueViolation 仅凭 PostgreSQL SQLSTATE(23505/23P01)判定唯一键冲突,
// 不依赖错误文本。errors.As 可穿透任意包装链。
func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	if !errors.As(err, &pgErr) {
		return false
	}
	return pgErr.Code == "23505" || pgErr.Code == "23P01"
}
