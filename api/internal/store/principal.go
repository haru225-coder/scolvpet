package store

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/domain"
)

// Principal separates the signed-in account from the tenant owner whose data
// the request may access. Owners have AccountID == OwnerID; invited members do
// not.
type Principal struct {
	AccountID      uuid.UUID
	OwnerID        uuid.UUID
	OrganizationID uuid.UUID
	Role           string
}

type principalQueryer interface {
	QueryRow(context.Context, string, ...any) pgx.Row
}

func (s *Store) ResolvePrincipal(ctx context.Context, accountID uuid.UUID) (Principal, error) {
	return resolvePrincipal(ctx, s.Pool, accountID)
}

func ResolvePrincipalTx(ctx context.Context, tx pgx.Tx, accountID uuid.UUID) (Principal, error) {
	return resolvePrincipal(ctx, tx, accountID)
}

func ResolvePrincipalContextTx(
	ctx context.Context,
	tx pgx.Tx,
	accountID uuid.UUID,
) (Principal, domain.Organization, error) {
	principal, err := resolvePrincipal(ctx, tx, accountID)
	if err != nil {
		return Principal{}, domain.Organization{}, err
	}
	organization, err := getOrganization(ctx, tx, principal.OwnerID)
	if err != nil {
		return Principal{}, domain.Organization{}, err
	}
	return principal, organization, nil
}

// ResolveLoginPrincipalTx onboards an account that has no organization yet by
// accepting the newest pending invite for its verified phone, then resolves the
// active principal.
//
// Anyone can invite an arbitrary phone number, so an invite must never move an
// account that already belongs somewhere: that would let a stranger redirect a
// cattery owner's whole session into their own tenant. Accounts that already
// have an active membership keep it, and their pending invites stay 'invited'
// until an explicit accept flow exists.
func ResolveLoginPrincipalTx(
	ctx context.Context,
	tx pgx.Tx,
	accountID uuid.UUID,
	phone string,
) (Principal, domain.Organization, error) {
	normalizedPhone := normalizePrincipalPhone(phone)
	if _, err := tx.Exec(ctx, `
		WITH pending_invite AS (
			SELECT id
			FROM organization_member
			WHERE phone=$2
			  AND status='invited'
			  AND (account_id IS NULL OR account_id=$1)
			  AND NOT EXISTS (
				SELECT 1 FROM organization_member
				WHERE account_id=$1 AND status='active'
			  )
			  AND NOT EXISTS (
				SELECT 1 FROM organization WHERE owner_id=$1
			  )
			ORDER BY invited_at DESC, created_at DESC, id DESC
			LIMIT 1
		)
		UPDATE organization_member
		SET account_id=$1,
			status='active',
			accepted_at=COALESCE(accepted_at, now()),
			version=version+1,
			updated_at=now()
		WHERE id=(SELECT id FROM pending_invite)
	`, accountID, normalizedPhone); err != nil {
		return Principal{}, domain.Organization{}, err
	}

	principal, err := resolvePrincipal(ctx, tx, accountID)
	if errors.Is(err, ErrNotFound) {
		organization, ensureErr := ensureOrganizationTx(ctx, tx, accountID)
		if ensureErr != nil {
			return Principal{}, domain.Organization{}, ensureErr
		}
		principal = Principal{
			AccountID:      accountID,
			OwnerID:        accountID,
			OrganizationID: uuid.MustParse(organization.ID),
			Role:           "owner",
		}
	} else if err != nil {
		return Principal{}, domain.Organization{}, err
	}

	organization, err := getOrganization(ctx, tx, principal.OwnerID)
	if err != nil {
		return Principal{}, domain.Organization{}, err
	}
	if principal.Role == "owner" {
		if err := ensureOwnerPrincipalMemberTx(
			ctx,
			tx,
			principal,
			normalizedPhone,
		); err != nil {
			return Principal{}, domain.Organization{}, err
		}
	}
	return principal, organization, nil
}

func resolvePrincipal(
	ctx context.Context,
	queryer principalQueryer,
	accountID uuid.UUID,
) (Principal, error) {
	var principal Principal
	err := queryer.QueryRow(ctx, `
		SELECT $1::uuid, owner_id, organization_id, role::text
		FROM organization_member
		WHERE account_id=$1 AND status='active'
		ORDER BY
			CASE WHEN role='owner' THEN 0 ELSE 1 END,
			accepted_at DESC NULLS LAST,
			updated_at DESC,
			id DESC
		LIMIT 1
	`, accountID).Scan(
		&principal.AccountID,
		&principal.OwnerID,
		&principal.OrganizationID,
		&principal.Role,
	)
	if err == nil {
		return principal, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return Principal{}, err
	}

	var organizationID uuid.UUID
	err = queryer.QueryRow(ctx, `
		SELECT id FROM organization
		WHERE owner_id=$1 AND deleted_at IS NULL
		ORDER BY created_at ASC, id ASC
		LIMIT 1
	`, accountID).Scan(&organizationID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Principal{}, ErrNotFound
	}
	if err != nil {
		return Principal{}, err
	}
	return Principal{
		AccountID:      accountID,
		OwnerID:        accountID,
		OrganizationID: organizationID,
		Role:           "owner",
	}, nil
}

func ensureOwnerPrincipalMemberTx(
	ctx context.Context,
	tx pgx.Tx,
	principal Principal,
	phone string,
) error {
	var displayName *string
	if err := tx.QueryRow(ctx, `
		SELECT display_name FROM account
		WHERE id=$1 AND deleted_at IS NULL
	`, principal.AccountID).Scan(&displayName); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, `
		INSERT INTO organization_member (
			owner_id, organization_id, account_id, phone, display_name,
			role, status, invited_at, accepted_at
		)
		SELECT $1,$2,$3,$4,$5,'owner','active',$6,$6
		WHERE NOT EXISTS (
			SELECT 1 FROM organization_member
			WHERE owner_id=$1 AND organization_id=$2
			  AND role='owner' AND status='active'
		)
	`,
		principal.OwnerID,
		principal.OrganizationID,
		principal.AccountID,
		phone,
		displayName,
		time.Now().UTC(),
	)
	return err
}

func normalizePrincipalPhone(value string) string {
	value = strings.TrimSpace(value)
	value = strings.TrimPrefix(value, "+86")
	value = strings.TrimPrefix(value, "86")
	return strings.TrimSpace(value)
}
