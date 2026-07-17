package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP2MiniprogramRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP2MiniprogramRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/miniprogram/config"},
		{http.MethodPut, "/v1/miniprogram/config"},
		{http.MethodGet, "/v1/miniprogram/releases"},
		{http.MethodPost, "/v1/miniprogram/releases"},
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

func TestMiniprogramPipelineNote(t *testing.T) {
	if miniprogramPipelineNote() == "" {
		t.Fatal("empty note")
	}
}
