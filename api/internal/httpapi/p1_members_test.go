package httpapi

import (
	"errors"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
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

func TestValidateMemberIfMatch(t *testing.T) {
	if err := validateMemberIfMatch("", 3); err != nil {
		t.Fatalf("optional If-Match rejected: %v", err)
	}
	if err := validateMemberIfMatch(`W/"3"`, 3); err != nil {
		t.Fatalf("matching If-Match rejected: %v", err)
	}
	if err := validateMemberIfMatch("bad", 3); err == nil {
		t.Fatal("invalid If-Match accepted")
	}
	if err := validateMemberIfMatch(`"2"`, 3); !errors.Is(err, store.ErrVersionConflict) {
		t.Fatalf("stale If-Match error=%v", err)
	}
}
