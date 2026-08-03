package httpapi

import (
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

func TestP1DetailEndpointsReturnVersionedResources(t *testing.T) {
	fixture := newP1DetailEndpointFixture(t)
	for _, endpoint := range fixture.endpoints {
		t.Run(endpoint.name, func(t *testing.T) {
			response := performP1DetailRequest(t, fixture.handler, fixture.ownerToken, endpoint.path)
			if response.Code != http.StatusOK {
				t.Fatalf("GET %s status=%d body=%s", endpoint.path, response.Code, response.Body.String())
			}
			if got, want := response.Header().Get("ETag"), store.FormatETag(endpoint.version); got != want {
				t.Fatalf("GET %s ETag=%q want %q", endpoint.path, got, want)
			}
			assertP1DetailResponseID(t, response, endpoint.id)
		})
	}
}

func TestP1DetailEndpointsHideOtherOwnersResources(t *testing.T) {
	fixture := newP1DetailEndpointFixture(t)
	for _, endpoint := range fixture.endpoints {
		t.Run(endpoint.name, func(t *testing.T) {
			response := performP1DetailRequest(t, fixture.handler, fixture.otherOwnerToken, endpoint.path)
			if response.Code != http.StatusNotFound {
				t.Fatalf("GET %s as other owner status=%d body=%s", endpoint.path, response.Code, response.Body.String())
			}
		})
	}
}

func TestP1DocumentDetailEndpointsRejectOtherDocumentKind(t *testing.T) {
	fixture := newP1DetailEndpointFixture(t)
	for _, endpoint := range []struct {
		name string
		path string
	}{
		{name: "合同不作为回执返回", path: "/v1/receipts/" + fixture.contractID.String()},
		{name: "回执不作为合同返回", path: "/v1/contracts/" + fixture.receiptID.String()},
	} {
		t.Run(endpoint.name, func(t *testing.T) {
			response := performP1DetailRequest(t, fixture.handler, fixture.ownerToken, endpoint.path)
			if response.Code != http.StatusNotFound {
				t.Fatalf("GET %s status=%d body=%s", endpoint.path, response.Code, response.Body.String())
			}
		})
	}
}

type p1DetailEndpointFixture struct {
	handler         http.Handler
	ownerToken      string
	otherOwnerToken string
	contractID      uuid.UUID
	receiptID       uuid.UUID
	endpoints       []p1DetailEndpoint
}

type p1DetailEndpoint struct {
	name    string
	path    string
	id      uuid.UUID
	version int
}

func newP1DetailEndpointFixture(t *testing.T) p1DetailEndpointFixture {
	t.Helper()
	databaseURL := os.Getenv("P1_DETAIL_HTTP_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set P1_DETAIL_HTTP_TEST_DATABASE_URL or DATABASE_URL to run P1 detail HTTP integration tests")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	t.Cleanup(cancel)
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect postgres: %v", err)
	}
	t.Cleanup(pool.Close)
	if err := pool.Ping(ctx); err != nil {
		t.Fatalf("ping postgres: %v", err)
	}

	dataStore := store.New(pool)
	seed := time.Now().UnixNano() % 10000000000000
	_, ownerID, err := dataStore.EnsureAccount(ctx, fmt.Sprintf("+8616%013d", seed))
	if err != nil {
		t.Fatalf("ensure owner account: %v", err)
	}
	_, otherOwnerID, err := dataStore.EnsureAccount(ctx, fmt.Sprintf("+8617%013d", seed))
	if err != nil {
		t.Fatalf("ensure other owner account: %v", err)
	}
	ownerIDs := []uuid.UUID{ownerID, otherOwnerID}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM doc_document WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM doc_template WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM crm_handover WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM crm_reservation WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM crm_contact WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM idempotency_record WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM domain_event WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization_member WHERE owner_id = ANY($1) OR account_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM organization WHERE owner_id = ANY($1)`, ownerIDs)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM account WHERE id = ANY($1)`, ownerIDs)
	})

	ownerOrganization, err := dataStore.EnsureOrganization(ctx, ownerID)
	if err != nil {
		t.Fatalf("ensure owner organization: %v", err)
	}
	if _, err := dataStore.EnsureOrganization(ctx, otherOwnerID); err != nil {
		t.Fatalf("ensure other owner organization: %v", err)
	}

	contactID := uuid.New()
	if _, err := pool.Exec(ctx, `
		INSERT INTO crm_contact (id, owner_id, organization_id, name, status, version)
		VALUES ($1,$2,$3,'详情客户','lead',7)
	`, contactID, ownerID, ownerOrganization.ID); err != nil {
		t.Fatalf("seed crm contact: %v", err)
	}
	reservationID := uuid.New()
	if _, err := pool.Exec(ctx, `
		INSERT INTO crm_reservation (id, owner_id, organization_id, contact_id, title, status, version)
		VALUES ($1,$2,$3,$4,'详情预订','held',8)
	`, reservationID, ownerID, ownerOrganization.ID, contactID); err != nil {
		t.Fatalf("seed crm reservation: %v", err)
	}
	handoverID := uuid.New()
	if _, err := pool.Exec(ctx, `
		INSERT INTO crm_handover (id, owner_id, organization_id, contact_id, reservation_id, status, version)
		VALUES ($1,$2,$3,$4,$5,'scheduled',9)
	`, handoverID, ownerID, ownerOrganization.ID, contactID, reservationID); err != nil {
		t.Fatalf("seed crm handover: %v", err)
	}

	contractTemplateID := seedP1DetailDocumentTemplate(t, ctx, pool, ownerID, ownerOrganization.ID, "contract")
	receiptTemplateID := seedP1DetailDocumentTemplate(t, ctx, pool, ownerID, ownerOrganization.ID, "receipt")
	contractID := seedP1DetailDocument(t, ctx, pool, ownerID, ownerOrganization.ID, contractTemplateID, "contract", 10)
	receiptID := seedP1DetailDocument(t, ctx, pool, ownerID, ownerOrganization.ID, receiptTemplateID, "receipt", 11)

	authService := auth.New("p1-detail-http-test", "123456")
	ownerToken, _, err := authService.CreateSession(ctx, ownerID)
	if err != nil {
		t.Fatalf("create owner session: %v", err)
	}
	otherOwnerToken, _, err := authService.CreateSession(ctx, otherOwnerID)
	if err != nil {
		t.Fatalf("create other owner session: %v", err)
	}

	return p1DetailEndpointFixture{
		handler:         NewServer(dataStore, authService, slog.Default()).Handler(),
		ownerToken:      ownerToken,
		otherOwnerToken: otherOwnerToken,
		contractID:      contractID,
		receiptID:       receiptID,
		endpoints: []p1DetailEndpoint{
			{name: "CRM 客户", path: "/v1/crm/contacts/" + contactID.String(), id: contactID, version: 7},
			{name: "CRM 预订", path: "/v1/crm/reservations/" + reservationID.String(), id: reservationID, version: 8},
			{name: "CRM 交付", path: "/v1/crm/handovers/" + handoverID.String(), id: handoverID, version: 9},
			{name: "合同", path: "/v1/contracts/" + contractID.String(), id: contractID, version: 10},
			{name: "回执", path: "/v1/receipts/" + receiptID.String(), id: receiptID, version: 11},
		},
	}
}

func seedP1DetailDocumentTemplate(t *testing.T, ctx context.Context, pool *pgxpool.Pool, ownerID uuid.UUID, organizationID, kind string) uuid.UUID {
	t.Helper()
	templateID := uuid.New()
	if _, err := pool.Exec(ctx, `
		INSERT INTO doc_template (id, owner_id, organization_id, kind, name, body_text)
		VALUES ($1,$2,$3,$4::doc_template_kind,$5,'详情测试模板')
	`, templateID, ownerID, organizationID, kind, kind+" 详情模板"); err != nil {
		t.Fatalf("seed %s template: %v", kind, err)
	}
	return templateID
}

func seedP1DetailDocument(t *testing.T, ctx context.Context, pool *pgxpool.Pool, ownerID uuid.UUID, organizationID string, templateID uuid.UUID, kind string, version int) uuid.UUID {
	t.Helper()
	documentID := uuid.New()
	amountCents := any(nil)
	if kind == "receipt" {
		amountCents = int64(1200)
	}
	if _, err := pool.Exec(ctx, `
		INSERT INTO doc_document (id, owner_id, organization_id, template_id, kind, title, body_filled, amount_cents, status, version)
		VALUES ($1,$2,$3,$4,$5::doc_template_kind,$6,'详情测试正文',$7,'draft',$8)
	`, documentID, ownerID, organizationID, templateID, kind, kind+" 详情单据", amountCents, version); err != nil {
		t.Fatalf("seed %s document: %v", kind, err)
	}
	return documentID
}

func performP1DetailRequest(t *testing.T, handler http.Handler, accessToken, path string) *httptest.ResponseRecorder {
	t.Helper()
	request := httptest.NewRequest(http.MethodGet, path, nil)
	request.Header.Set("Authorization", "Bearer "+accessToken)
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, request)
	return recorder
}

func assertP1DetailResponseID(t *testing.T, recorder *httptest.ResponseRecorder, expectedID uuid.UUID) {
	t.Helper()
	var response struct {
		Data struct {
			ID uuid.UUID `json:"id"`
		} `json:"data"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &response); err != nil {
		t.Fatalf("decode detail response: %v body=%s", err, recorder.Body.String())
	}
	if response.Data.ID != expectedID {
		t.Fatalf("detail response id=%s want %s", response.Data.ID, expectedID)
	}
}
