package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP1PushRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1PushRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/push/devices"},
		{http.MethodPut, "/v1/push/devices"},
		{http.MethodGet, "/v1/push/messages"},
		{http.MethodPost, "/v1/push/messages"},
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

func TestValidPushPlatformProvider(t *testing.T) {
	if !validPushPlatform("ios") || !validPushPlatform("android") {
		t.Fatal("platform")
	}
	if validPushPlatform("windows") {
		t.Fatal("windows invalid")
	}
	if !validPushProvider("log") || validPushProvider("xiaomi") {
		t.Fatal("provider")
	}
}
