package httpapi

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestPrincipalCanRequestRoleMatrix(t *testing.T) {
	tests := []struct {
		name   string
		role   string
		method string
		path   string
		want   bool
	}{
		{name: "owner manages members", role: "owner", method: http.MethodPost, path: "/v1/organization-members", want: true},
		{name: "viewer reads", role: "viewer", method: http.MethodGet, path: "/v1/hamsters", want: true},
		{name: "viewer cannot read contracts with public tokens", role: "viewer", method: http.MethodGet, path: "/v1/contracts", want: false},
		{name: "viewer cannot read receipts with public tokens", role: "viewer", method: http.MethodGet, path: "/v1/receipts/receipt-id/pdf", want: false},
		{name: "viewer cannot read financial records", role: "viewer", method: http.MethodGet, path: "/v1/accounting/records", want: false},
		{name: "viewer cannot read member PII", role: "viewer", method: http.MethodGet, path: "/v1/organization-members", want: false},
		{name: "viewer cannot read backup metadata", role: "viewer", method: http.MethodGet, path: "/v1/data-center/backup-jobs", want: false},
		{name: "unknown role cannot read protected data", role: "unknown", method: http.MethodGet, path: "/v1/hamsters", want: false},
		{name: "viewer cannot write", role: "viewer", method: http.MethodPatch, path: "/v1/hamsters/hamster-id", want: false},
		{name: "viewer may log out", role: "viewer", method: http.MethodDelete, path: "/v1/auth/sessions/current", want: true},
		{name: "breeder writes breeding", role: "breeder", method: http.MethodPost, path: "/v1/breeding-plans", want: true},
		{name: "breeder cannot manage members", role: "breeder", method: http.MethodPost, path: "/v1/organization-members", want: false},
		{name: "breeder cannot write crm", role: "breeder", method: http.MethodPost, path: "/v1/crm/customers", want: false},
		{name: "caretaker writes enclosures", role: "caretaker", method: http.MethodPatch, path: "/v1/enclosures/enclosure-id", want: true},
		{name: "caretaker cannot write breeding", role: "caretaker", method: http.MethodPost, path: "/v1/breeding-plans", want: false},
		{name: "staff writes crm", role: "staff", method: http.MethodPost, path: "/v1/crm/customers", want: true},
		{name: "staff writes contracts", role: "staff", method: http.MethodPost, path: "/v1/contracts", want: true},
		{name: "staff writes public site", role: "staff", method: http.MethodPut, path: "/v1/public-site", want: true},
		{name: "staff cannot write accounting", role: "staff", method: http.MethodPost, path: "/v1/accounting/entries", want: false},
		{name: "unknown role cannot write", role: "unknown", method: http.MethodPost, path: "/v1/hamsters", want: false},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := principalCanRequest(test.role, test.method, test.path); got != test.want {
				t.Fatalf("principalCanRequest(%q, %q, %q)=%v want %v", test.role, test.method, test.path, got, test.want)
			}
		})
	}
}

func TestPermissionDeniedWritesForbiddenResponse(t *testing.T) {
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/crm/customers", nil)

	writeAPIError(recorder, request, permissionDenied("viewer"))

	if recorder.Code != http.StatusForbidden {
		t.Fatalf("status=%d want %d", recorder.Code, http.StatusForbidden)
	}
	var response struct {
		Error struct {
			Code    string         `json:"code"`
			Details map[string]any `json:"details"`
		} `json:"error"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &response); err != nil {
		t.Fatal(err)
	}
	if response.Error.Code != "PERMISSION_DENIED" {
		t.Fatalf("code=%q", response.Error.Code)
	}
	if response.Error.Details["member_role"] != "viewer" {
		t.Fatalf("details=%v", response.Error.Details)
	}
}

func TestRBACRejectsMalformedAuthorizationHeader(t *testing.T) {
	server := NewServer(nil, auth.New("test-secret", "123456"), slog.Default())
	next := http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	handler := server.rbacMiddleware(next)

	for _, authorization := range []string{"Basic abc", "Bearer", "Bearer not-a-token"} {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(http.MethodPost, "/v1/hamsters", nil)
		request.Header.Set("Authorization", authorization)
		handler.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("authorization %q status=%d want %d", authorization, recorder.Code, http.StatusUnauthorized)
		}
	}
}

func TestRBACAllowsMissingAuthorizationToContinue(t *testing.T) {
	server := NewServer(nil, auth.New("test-secret", "123456"), slog.Default())
	next := http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/v1/hamsters", nil)
	server.rbacMiddleware(next).ServeHTTP(recorder, request)
	if recorder.Code != http.StatusNoContent {
		t.Fatalf("missing authorization status=%d want %d", recorder.Code, http.StatusNoContent)
	}
}
