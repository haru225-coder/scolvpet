package store

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestResolveLoginPrincipalAcceptsNewestInviteAndRevocationFallsBack(t *testing.T) {
	databaseURL := os.Getenv("PRINCIPAL_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set PRINCIPAL_TEST_DATABASE_URL or DATABASE_URL to run PostgreSQL principal smoke")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	store := New(pool)
	phoneSeed := time.Now().UnixNano() % 10000000000000
	ownerPhoneA := fmt.Sprintf("+8613%013d", phoneSeed)
	ownerPhoneB := fmt.Sprintf("+8614%013d", phoneSeed)
	memberPhone := fmt.Sprintf("+8615%013d", phoneSeed)
	_, ownerA, err := store.EnsureAccount(ctx, ownerPhoneA)
	if err != nil {
		t.Fatalf("ensure owner A: %v", err)
	}
	_, ownerB, err := store.EnsureAccount(ctx, ownerPhoneB)
	if err != nil {
		t.Fatalf("ensure owner B: %v", err)
	}
	_, memberAccount, err := store.EnsureAccount(ctx, memberPhone)
	if err != nil {
		t.Fatalf("ensure member: %v", err)
	}
	accountIDs := []uuid.UUID{ownerA, ownerB, memberAccount}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id = ANY($1) OR account_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id = ANY($1)`, accountIDs)
	})

	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	ownerOrgA, err := ensureOrganizationTx(ctx, tx, ownerA)
	if err != nil {
		_ = tx.Rollback(ctx)
		t.Fatalf("ensure owner A organization: %v", err)
	}
	ownerOrgB, err := ensureOrganizationTx(ctx, tx, ownerB)
	if err != nil {
		_ = tx.Rollback(ctx)
		t.Fatalf("ensure owner B organization: %v", err)
	}
	memberOrg, err := ensureOrganizationTx(ctx, tx, memberAccount)
	if err != nil {
		_ = tx.Rollback(ctx)
		t.Fatalf("ensure member organization: %v", err)
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatal(err)
	}

	var olderInviteID, newestInviteID uuid.UUID
	memberNumber := memberPhone[3:]
	if err := pool.QueryRow(ctx, `
		INSERT INTO organization_member (
			owner_id, organization_id, phone, role, status, invited_at
		) VALUES ($1,$2,$3,'viewer','invited',$4)
		RETURNING id
	`, ownerA, uuid.MustParse(ownerOrgA.ID), memberNumber, time.Now().Add(-time.Hour)).Scan(&olderInviteID); err != nil {
		t.Fatalf("insert older invite: %v", err)
	}
	if err := pool.QueryRow(ctx, `
		INSERT INTO organization_member (
			owner_id, organization_id, phone, role, status, invited_at
		) VALUES ($1,$2,$3,'staff','invited',$4)
		RETURNING id
	`, ownerB, uuid.MustParse(ownerOrgB.ID), memberNumber, time.Now()).Scan(&newestInviteID); err != nil {
		t.Fatalf("insert newest invite: %v", err)
	}

	loginTx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	principal, organization, err := ResolveLoginPrincipalTx(ctx, loginTx, memberAccount, memberPhone)
	if err != nil {
		_ = loginTx.Rollback(ctx)
		t.Fatalf("resolve login principal: %v", err)
	}
	if err := loginTx.Commit(ctx); err != nil {
		t.Fatal(err)
	}
	if principal.AccountID != memberAccount || principal.OwnerID != ownerB || principal.Role != "staff" {
		t.Fatalf("principal=%+v", principal)
	}
	if organization.ID != ownerOrgB.ID {
		t.Fatalf("organization=%s want %s", organization.ID, ownerOrgB.ID)
	}

	var olderStatus, newestStatus string
	if err := pool.QueryRow(ctx, `SELECT status::text FROM organization_member WHERE id=$1`, olderInviteID).Scan(&olderStatus); err != nil {
		t.Fatal(err)
	}
	if err := pool.QueryRow(ctx, `SELECT status::text FROM organization_member WHERE id=$1`, newestInviteID).Scan(&newestStatus); err != nil {
		t.Fatal(err)
	}
	if olderStatus != "invited" || newestStatus != "active" {
		t.Fatalf("invite statuses older=%s newest=%s", olderStatus, newestStatus)
	}

	resolved, err := store.ResolvePrincipal(ctx, memberAccount)
	if err != nil || resolved.OwnerID != ownerB || resolved.Role != "staff" {
		t.Fatalf("resolved active principal=%+v err=%v", resolved, err)
	}
	if _, err := pool.Exec(ctx, `
		UPDATE organization_member
		SET status='revoked', revoked_at=now(), updated_at=now(), version=version+1
		WHERE id=$1
	`, newestInviteID); err != nil {
		t.Fatal(err)
	}
	resolved, err = store.ResolvePrincipal(ctx, memberAccount)
	if err != nil {
		t.Fatalf("resolve after revoke: %v", err)
	}
	if resolved.OwnerID != memberAccount || resolved.Role != "owner" || resolved.OrganizationID != uuid.MustParse(memberOrg.ID) {
		t.Fatalf("fallback principal=%+v", resolved)
	}
}
