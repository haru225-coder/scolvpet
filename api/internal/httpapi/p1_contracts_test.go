package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP1ContractRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1ContractRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/contracts/templates"},
		{http.MethodPost, "/v1/contracts/templates"},
		{http.MethodGet, "/v1/contracts"},
		{http.MethodPost, "/v1/contracts"},
		{http.MethodGet, "/v1/receipts/templates"},
		{http.MethodPost, "/v1/receipts/templates"},
		{http.MethodGet, "/v1/receipts"},
		{http.MethodPost, "/v1/receipts"},
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

func TestFillDocTemplate(t *testing.T) {
	got := fillDocTemplate("客户{{contact_name}} 金额{{amount}}", map[string]string{
		"contact_name": "阿花",
		"amount":       "100.00 CNY",
	})
	want := "客户阿花 金额100.00 CNY"
	if got != want {
		t.Fatalf("got %q want %q", got, want)
	}
}
