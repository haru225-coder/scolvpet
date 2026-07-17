package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP1MemberRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1MemberRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/organization-members"},
		{http.MethodPost, "/v1/organization-members"},
		{http.MethodPatch, "/v1/organization-members/00000000-0000-0000-0000-000000000001"},
		{http.MethodPost, "/v1/organization-members/00000000-0000-0000-0000-000000000001/revoke"},
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

func TestNormalizeMemberPhoneAndRoles(t *testing.T) {
	if got := normalizeMemberPhone("+8613800138000"); got != "13800138000" {
		t.Fatalf("phone = %q", got)
	}
	if !validMemberRole("breeder") || validMemberRole("admin") {
		t.Fatal("role validation failed")
	}
}
