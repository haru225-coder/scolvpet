package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP1AccountingRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1AccountingRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/accounting/categories"},
		{http.MethodPost, "/v1/accounting/categories"},
		{http.MethodGet, "/v1/accounting/records"},
		{http.MethodPost, "/v1/accounting/records"},
		{http.MethodGet, "/v1/accounting/summary"},
	}
	for _, test := range paths {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(test.method, test.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", test.method, test.path, recorder.Code)
		}
	}
}

func TestValidAccountingEntryType(t *testing.T) {
	if !validAccountingEntryType("income") || !validAccountingEntryType("expense") {
		t.Fatal("expected income/expense valid")
	}
	if validAccountingEntryType("transfer") {
		t.Fatal("transfer should be invalid")
	}
}
