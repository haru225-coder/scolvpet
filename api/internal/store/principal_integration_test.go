package store

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type principalFixture struct {
	pool     *pgxpool.Pool
	store    *Store
	ownerA   uuid.UUID
	ownerB   uuid.UUID
	orgA     uuid.UUID
	orgB     uuid.UUID
	subject  uuid.UUID
	subPhone string
}

// inviteSubject drops a pending invite for the fixture subject's phone into one
// of the two foreign organizations, exactly as inviteOrganizationMember does.
func (f principalFixture) inviteSubject(t *testing.T, ownerID, orgID uuid.UUID, role string, invitedAt time.Time) uuid.UUID {
	t.Helper()
	var id uuid.UUID
	if err := f.pool.QueryRow(context.Background(), `
		INSERT INTO organization_member (
			owner_id, organization_id, phone, role, status, invited_at
		) VALUES ($1,$2,$3,$4::organization_member_role,'invited',$5)
		RETURNING id
	`, ownerID, orgID, f.subPhone[3:], role, invitedAt).Scan(&id); err != nil {
		t.Fatalf("insert %s invite: %v", role, err)
	}
	return id
}

func (f principalFixture) login(t *testing.T) (Principal, uuid.UUID) {
	t.Helper()
	ctx := context.Background()
	tx, err := f.pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	principal, organization, err := ResolveLoginPrincipalTx(ctx, tx, f.subject, f.subPhone)
	if err != nil {
		_ = tx.Rollback(ctx)
		t.Fatalf("resolve login principal: %v", err)
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatal(err)
	}
	return principal, uuid.MustParse(organization.ID)
}

func (f principalFixture) memberStatus(t *testing.T, id uuid.UUID) string {
	t.Helper()
	var status string
	if err := f.pool.QueryRow(context.Background(),
		`SELECT status::text FROM organization_member WHERE id=$1`, id).Scan(&status); err != nil {
		t.Fatalf("read member status: %v", err)
	}
	return status
}

// newPrincipalFixture provisions two unrelated cattery owners plus a subject
// account that has not logged in yet, and registers cleanup.
func newPrincipalFixture(t *testing.T) principalFixture {
	t.Helper()
	databaseURL := os.Getenv("PRINCIPAL_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set PRINCIPAL_TEST_DATABASE_URL or DATABASE_URL to run PostgreSQL principal smoke")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	store := New(pool)
	seed := time.Now().UnixNano() % 10000000000000
	_, ownerA, err := store.EnsureAccount(ctx, fmt.Sprintf("+8613%013d", seed))
	if err != nil {
		t.Fatalf("ensure owner A: %v", err)
	}
	_, ownerB, err := store.EnsureAccount(ctx, fmt.Sprintf("+8614%013d", seed))
	if err != nil {
		t.Fatalf("ensure owner B: %v", err)
	}
	subjectPhone := fmt.Sprintf("+8615%013d", seed)
	_, subject, err := store.EnsureAccount(ctx, subjectPhone)
	if err != nil {
		t.Fatalf("ensure subject: %v", err)
	}
	accountIDs := []uuid.UUID{ownerA, ownerB, subject}
	t.Cleanup(func() {
		cleanupCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id = ANY($1) OR account_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id = ANY($1)`, accountIDs)
	})

	fixture := principalFixture{
		pool: pool, store: store,
		ownerA: ownerA, ownerB: ownerB,
		subject: subject, subPhone: subjectPhone,
	}
	err = withTx(ctx, pool, func(tx pgx.Tx) error {
		orgA, err := ensureOrganizationTx(ctx, tx, ownerA)
		if err != nil {
			return err
		}
		orgB, err := ensureOrganizationTx(ctx, tx, ownerB)
		if err != nil {
			return err
		}
		fixture.orgA = uuid.MustParse(orgA.ID)
		fixture.orgB = uuid.MustParse(orgB.ID)
		return nil
	})
	if err != nil {
		t.Fatalf("provision organizations: %v", err)
	}
	return fixture
}

func withTx(ctx context.Context, pool *pgxpool.Pool, fn func(pgx.Tx) error) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return err
	}
	if err := fn(tx); err != nil {
		_ = tx.Rollback(ctx)
		return err
	}
	return tx.Commit(ctx)
}

// Inviting a member only validates the phone number's shape, so any registered
// user could invite a stranger's number. Login used to auto-accept that invite
// and rank the borrowed membership above the account's own owner row, which
// silently moved a cattery owner's entire session into the inviter's tenant.
func TestResolveLoginPrincipalKeepsOwnCatteryWhenInvited(t *testing.T) {
	fixture := newPrincipalFixture(t)
	// The owner membership row only appears on first login, so establish the
	// subject as a working cattery owner before anyone invites them.
	if principal, _ := fixture.login(t); principal.Role != "owner" {
		t.Fatalf("setup login did not establish own cattery: %+v", principal)
	}
	olderInvite := fixture.inviteSubject(t, fixture.ownerA, fixture.orgA, "viewer", time.Now().Add(-time.Hour))
	newestInvite := fixture.inviteSubject(t, fixture.ownerB, fixture.orgB, "staff", time.Now())

	principal, organizationID := fixture.login(t)

	if principal.OwnerID != fixture.subject || principal.Role != "owner" {
		t.Fatalf("invite hijacked the session: principal=%+v", principal)
	}
	if principal.AccountID != fixture.subject {
		t.Fatalf("unexpected account: %+v", principal)
	}
	var ownOrganizationID uuid.UUID
	if err := fixture.pool.QueryRow(context.Background(),
		`SELECT id FROM organization WHERE owner_id=$1`, fixture.subject).Scan(&ownOrganizationID); err != nil {
		t.Fatalf("read own organization: %v", err)
	}
	if organizationID != ownOrganizationID {
		t.Fatalf("organization=%s want own %s", organizationID, ownOrganizationID)
	}
	// Unaccepted invites must survive as invites rather than being consumed.
	if got := fixture.memberStatus(t, olderInvite); got != "invited" {
		t.Fatalf("older invite status=%s want invited", got)
	}
	if got := fixture.memberStatus(t, newestInvite); got != "invited" {
		t.Fatalf("newest invite status=%s want invited", got)
	}
}

// Onboarding an employee who has no cattery of their own still works: the
// newest invite wins, and revoking it hands the account its own organization.
func TestResolveLoginPrincipalOnboardsAccountWithoutCattery(t *testing.T) {
	fixture := newPrincipalFixture(t)
	olderInvite := fixture.inviteSubject(t, fixture.ownerA, fixture.orgA, "viewer", time.Now().Add(-time.Hour))
	newestInvite := fixture.inviteSubject(t, fixture.ownerB, fixture.orgB, "staff", time.Now())

	principal, organizationID := fixture.login(t)

	if principal.OwnerID != fixture.ownerB || principal.Role != "staff" {
		t.Fatalf("principal=%+v want staff of owner B", principal)
	}
	if organizationID != fixture.orgB {
		t.Fatalf("organization=%s want %s", organizationID, fixture.orgB)
	}
	if got := fixture.memberStatus(t, olderInvite); got != "invited" {
		t.Fatalf("older invite status=%s want invited", got)
	}
	if got := fixture.memberStatus(t, newestInvite); got != "active" {
		t.Fatalf("newest invite status=%s want active", got)
	}

	// Owner B revokes the membership and owner A withdraws the stale invite, so
	// nothing is left to attach the account to a foreign cattery.
	if _, err := fixture.pool.Exec(context.Background(), `
		UPDATE organization_member
		SET status='revoked', revoked_at=now(), updated_at=now(), version=version+1
		WHERE id = ANY($1)
	`, []uuid.UUID{newestInvite, olderInvite}); err != nil {
		t.Fatalf("revoke membership: %v", err)
	}

	principal, organizationID = fixture.login(t)
	if principal.OwnerID != fixture.subject || principal.Role != "owner" {
		t.Fatalf("after revoke principal=%+v want own owner", principal)
	}
	var ownOrganizationID uuid.UUID
	if err := fixture.pool.QueryRow(context.Background(),
		`SELECT id FROM organization WHERE owner_id=$1`, fixture.subject).Scan(&ownOrganizationID); err != nil {
		t.Fatalf("read own organization: %v", err)
	}
	if organizationID != ownOrganizationID {
		t.Fatalf("after revoke organization=%s want own %s", organizationID, ownOrganizationID)
	}
}
