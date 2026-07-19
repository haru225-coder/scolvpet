package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func TestMemberHTTPWritesAreIdempotentAndVersioned(t *testing.T) {
	databaseURL := os.Getenv("MEMBER_HTTP_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set MEMBER_HTTP_TEST_DATABASE_URL or DATABASE_URL to run member HTTP smoke")
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

	dataStore := store.New(pool)
	phoneSeed := time.Now().UnixNano() % 10000000000000
	ownerPhone := fmt.Sprintf("+8616%013d", phoneSeed)
	memberPhone := fmt.Sprintf("+8617%013d", phoneSeed)
	_, ownerID, err := dataStore.EnsureAccount(ctx, ownerPhone)
	if err != nil {
		t.Fatalf("ensure owner: %v", err)
	}
	_, memberAccountID, err := dataStore.EnsureAccount(ctx, memberPhone)
	if err != nil {
		t.Fatalf("ensure member: %v", err)
	}
	accountIDs := []uuid.UUID{ownerID, memberAccountID}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id = ANY($1) OR account_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id = ANY($1)`, accountIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id = ANY($1)`, accountIDs)
	})

	tx, err := pool.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := store.EnsureOrganizationTx(ctx, tx, ownerID); err != nil {
		_ = tx.Rollback(ctx)
		t.Fatalf("ensure organization: %v", err)
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatal(err)
	}

	authService := auth.New("member-http-test", "123456")
	accessToken, _, err := authService.CreateSession(ctx, ownerID)
	if err != nil {
		t.Fatal(err)
	}
	server := NewServer(dataStore, authService, slog.Default())
	handler := server.Handler()

	inviteBody := []byte(fmt.Sprintf(`{"phone":%q,"role":"caretaker","display_name":"小助手"}`, memberPhone))
	first := performMemberRequest(t, handler, http.MethodPost, "/v1/organization-members", accessToken, "member-invite-0001", "", inviteBody)
	if first.Code != http.StatusCreated {
		t.Fatalf("invite status=%d body=%s", first.Code, first.Body.String())
	}
	if first.Header().Get("ETag") != `"1"` {
		t.Fatalf("invite etag=%q", first.Header().Get("ETag"))
	}
	member := decodeMemberResponse(t, first)
	if member.Role != "caretaker" || member.Status != "invited" || member.Version != 1 {
		t.Fatalf("invited member=%+v", member)
	}

	replay := performMemberRequest(t, handler, http.MethodPost, "/v1/organization-members", accessToken, "member-invite-0001", "", inviteBody)
	if replay.Code != http.StatusCreated || replay.Header().Get("Idempotency-Replayed") != "true" {
		t.Fatalf("replay status=%d headers=%v body=%s", replay.Code, replay.Header(), replay.Body.String())
	}
	if replayMember := decodeMemberResponse(t, replay); replayMember.ID != member.ID {
		t.Fatalf("replay member id=%s want %s", replayMember.ID, member.ID)
	}

	updateBody := []byte(`{"role":"breeder","display_name":"繁育助手"}`)
	updated := performMemberRequest(
		t,
		handler,
		http.MethodPatch,
		"/v1/organization-members/"+member.ID.String(),
		accessToken,
		"member-update-0001",
		`"1"`,
		updateBody,
	)
	if updated.Code != http.StatusOK {
		t.Fatalf("update status=%d body=%s", updated.Code, updated.Body.String())
	}
	updatedMember := decodeMemberResponse(t, updated)
	if updatedMember.Role != "breeder" || updatedMember.Version != 2 || updated.Header().Get("ETag") != `"2"` {
		t.Fatalf("updated member=%+v etag=%q", updatedMember, updated.Header().Get("ETag"))
	}

	stale := performMemberRequest(
		t,
		handler,
		http.MethodPatch,
		"/v1/organization-members/"+member.ID.String(),
		accessToken,
		"member-update-0002",
		`"1"`,
		[]byte(`{"role":"viewer"}`),
	)
	if stale.Code != http.StatusConflict {
		t.Fatalf("stale status=%d body=%s", stale.Code, stale.Body.String())
	}

	revoked := performMemberRequest(
		t,
		handler,
		http.MethodPost,
		"/v1/organization-members/"+member.ID.String()+"/revoke",
		accessToken,
		"member-revoke-0001",
		`"2"`,
		nil,
	)
	if revoked.Code != http.StatusOK {
		t.Fatalf("revoke status=%d body=%s", revoked.Code, revoked.Body.String())
	}
	revokedMember := decodeMemberResponse(t, revoked)
	if revokedMember.Status != "revoked" || revokedMember.Version != 3 || revoked.Header().Get("ETag") != `"3"` {
		t.Fatalf("revoked member=%+v etag=%q", revokedMember, revoked.Header().Get("ETag"))
	}
}

func performMemberRequest(
	t *testing.T,
	handler http.Handler,
	method string,
	path string,
	accessToken string,
	idempotencyKey string,
	ifMatch string,
	body []byte,
) *httptest.ResponseRecorder {
	t.Helper()
	request := httptest.NewRequest(method, path, bytes.NewReader(body))
	request.Header.Set("Authorization", "Bearer "+accessToken)
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Idempotency-Key", idempotencyKey)
	if ifMatch != "" {
		request.Header.Set("If-Match", ifMatch)
	}
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	return recorder
}

func decodeMemberResponse(t *testing.T, recorder *httptest.ResponseRecorder) organizationMember {
	t.Helper()
	var response struct {
		Data organizationMember `json:"data"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode member response: %v body=%s", err, recorder.Body.String())
	}
	return response.Data
}
