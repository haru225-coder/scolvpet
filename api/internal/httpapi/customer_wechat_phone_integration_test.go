package httpapi

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
	"github.com/scolvpet/scolvpet/api/internal/wechat"
)

func customerWechatTestPool(t *testing.T) *pgxpool.Pool {
	t.Helper()
	databaseURL := os.Getenv("CUSTOMER_WECHAT_TEST_DATABASE_URL")
	if databaseURL == "" {
		databaseURL = os.Getenv("DATABASE_URL")
	}
	if databaseURL == "" {
		t.Skip("set CUSTOMER_WECHAT_TEST_DATABASE_URL or DATABASE_URL to run customer WeChat HTTP integration tests")
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
	return pool
}

func TestCustomerWechatPhoneActiveUniqueIndexExists(t *testing.T) {
	pool := customerWechatTestPool(t)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var indexDefinition string
	err := pool.QueryRow(ctx, `
		SELECT indexdef
		FROM pg_indexes
		WHERE schemaname = current_schema()
		  AND tablename = 'customer_wechat_identity'
		  AND indexname = 'ux_customer_wechat_identity_phone_active'
	`).Scan(&indexDefinition)
	if err != nil {
		t.Fatalf("customer WeChat phone uniqueness index missing; apply migration 0045: %v", err)
	}
	if indexDefinition == "" {
		t.Fatal("customer WeChat phone uniqueness index definition is empty")
	}
}

type customerWechatPhoneProvider struct {
	phone      wechat.Phone
	phoneCalls atomic.Int32
}

func (p *customerWechatPhoneProvider) Code2Session(_ context.Context, _ string) (wechat.Session, error) {
	return wechat.Session{OpenID: "unused"}, nil
}

func (p *customerWechatPhoneProvider) PhoneNumber(_ context.Context, _ string) (wechat.Phone, error) {
	p.phoneCalls.Add(1)
	return p.phone, nil
}

func newCustomerWechatPhoneHandler(pool *pgxpool.Pool, provider wechat.Provider) http.Handler {
	server := NewServer(store.New(pool), auth.New("customer-wechat-phone-test", "123456"), slog.Default())
	server.Wechat = provider
	server.WechatPhoneGlobalPerMinute = 100000
	server.WechatPhoneGlobalPerDay = 100000
	return server.Handler()
}

func insertCustomerWechatTicket(t *testing.T, ctx context.Context, pool *pgxpool.Pool, openID string) string {
	t.Helper()
	rawTicket := "wt_" + uuid.NewString()
	_, err := pool.Exec(ctx, `
		INSERT INTO wechat_bind_ticket (openid, ticket_sha256, expires_at)
		VALUES ($1, $2, now() + interval '10 minutes')
	`, openID, sha256Hex(rawTicket))
	if err != nil {
		t.Fatalf("insert wechat bind ticket: %v", err)
	}
	return rawTicket
}

func postCustomerWechatPhoneBinding(handler http.Handler, ticket, phoneCode string) *httptest.ResponseRecorder {
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/public/customer/wechat-phone-bindings",
		strings.NewReader(fmt.Sprintf(`{"wechat_ticket":%q,"phone_code":%q}`, ticket, phoneCode)))
	request.Header.Set("Content-Type", "application/json")
	request.RemoteAddr = "198.51.100.42:1234"
	handler.ServeHTTP(recorder, request)
	return recorder
}

func customerWechatPhoneTestPhone() string {
	return fmt.Sprintf("+86138%08d", time.Now().UnixNano()%100000000)
}

func TestCustomerWechatPhoneBindingConsumesTicketOnce(t *testing.T) {
	pool := customerWechatTestPool(t)
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	phone := customerWechatPhoneTestPhone()
	openID := "openid-phone-race-" + uuid.NewString()
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM customer_session WHERE phone=$1`, phone)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM customer_wechat_identity WHERE openid=$1`, openID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM wechat_bind_ticket WHERE openid=$1`, openID)
	})

	ticket := insertCustomerWechatTicket(t, ctx, pool, openID)
	provider := &customerWechatPhoneProvider{phone: wechat.Phone{CountryCode: "86", Number: phone}}
	handler := newCustomerWechatPhoneHandler(pool, provider)
	statuses := make(chan int, 2)
	var group sync.WaitGroup
	for range 2 {
		group.Add(1)
		go func() {
			defer group.Done()
			statuses <- postCustomerWechatPhoneBinding(handler, ticket, "phone-code").Code
		}()
	}
	group.Wait()
	close(statuses)
	first, second := <-statuses, <-statuses
	if !((first == http.StatusCreated && second == http.StatusUnprocessableEntity) || (first == http.StatusUnprocessableEntity && second == http.StatusCreated)) {
		t.Fatalf("concurrent statuses=%d,%d", first, second)
	}
	if got := provider.phoneCalls.Load(); got != 1 {
		t.Fatalf("PhoneNumber calls=%d, want 1", got)
	}

	var usedAt *time.Time
	if err := pool.QueryRow(ctx, `SELECT used_at FROM wechat_bind_ticket WHERE openid=$1`, openID).Scan(&usedAt); err != nil || usedAt == nil {
		t.Fatalf("ticket should be consumed: used_at=%v err=%v", usedAt, err)
	}
	var identities, sessions int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM customer_wechat_identity WHERE openid=$1 AND revoked_at IS NULL`, openID).Scan(&identities); err != nil || identities != 1 {
		t.Fatalf("active identities=%d err=%v", identities, err)
	}
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM customer_session WHERE phone=$1`, phone).Scan(&sessions); err != nil || sessions != 1 {
		t.Fatalf("customer sessions=%d err=%v", sessions, err)
	}
}

func TestCustomerWechatPhoneBindingRejectsPhoneBoundToAnotherOpenID(t *testing.T) {
	pool := customerWechatTestPool(t)
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	phone := customerWechatPhoneTestPhone()
	previousOpenID := "openid-existing-" + uuid.NewString()
	newOpenID := "openid-conflict-" + uuid.NewString()
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM customer_session WHERE phone=$1`, phone)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM customer_wechat_identity WHERE openid = ANY($1)`, []string{previousOpenID, newOpenID})
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM wechat_bind_ticket WHERE openid=$1`, newOpenID)
	})
	if _, err := pool.Exec(ctx, `INSERT INTO customer_wechat_identity (openid, phone) VALUES ($1, $2)`, previousOpenID, phone); err != nil {
		t.Fatalf("insert existing identity: %v", err)
	}
	ticket := insertCustomerWechatTicket(t, ctx, pool, newOpenID)
	provider := &customerWechatPhoneProvider{phone: wechat.Phone{CountryCode: "86", Number: phone}}
	recorder := postCustomerWechatPhoneBinding(newCustomerWechatPhoneHandler(pool, provider), ticket, "phone-code")
	if recorder.Code != http.StatusConflict || customerWechatErrorCode(t, recorder) != "PHONE_ALREADY_BOUND" {
		t.Fatalf("phone conflict status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	if got := provider.phoneCalls.Load(); got != 1 {
		t.Fatalf("PhoneNumber calls=%d, want 1", got)
	}
	var activePrevious, activeNew int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM customer_wechat_identity WHERE openid=$1 AND revoked_at IS NULL`, previousOpenID).Scan(&activePrevious); err != nil || activePrevious != 1 {
		t.Fatalf("previous binding was changed: count=%d err=%v", activePrevious, err)
	}
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM customer_wechat_identity WHERE openid=$1 AND revoked_at IS NULL`, newOpenID).Scan(&activeNew); err != nil || activeNew != 0 {
		t.Fatalf("new binding should not exist: count=%d err=%v", activeNew, err)
	}
}

func TestCustomerWechatPhoneBindingRejectsUnsupportedCountryAfterConsumingTicket(t *testing.T) {
	pool := customerWechatTestPool(t)
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	openID := "openid-overseas-" + uuid.NewString()
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cleanupCancel()
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM customer_wechat_identity WHERE openid=$1`, openID)
		_, _ = pool.Exec(cleanupCtx, `DELETE FROM wechat_bind_ticket WHERE openid=$1`, openID)
	})
	ticket := insertCustomerWechatTicket(t, ctx, pool, openID)
	provider := &customerWechatPhoneProvider{phone: wechat.Phone{CountryCode: "1", Number: "+14155550100"}}
	recorder := postCustomerWechatPhoneBinding(newCustomerWechatPhoneHandler(pool, provider), ticket, "phone-code")
	if recorder.Code != http.StatusUnprocessableEntity || customerWechatErrorCode(t, recorder) != "UNSUPPORTED_PHONE_COUNTRY" {
		t.Fatalf("unsupported country status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	var usedAt *time.Time
	if err := pool.QueryRow(ctx, `SELECT used_at FROM wechat_bind_ticket WHERE openid=$1`, openID).Scan(&usedAt); err != nil || usedAt == nil {
		t.Fatalf("unsupported-country ticket should be consumed: used_at=%v err=%v", usedAt, err)
	}
}
