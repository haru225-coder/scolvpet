package httpapi

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
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
