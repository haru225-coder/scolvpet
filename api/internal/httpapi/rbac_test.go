package httpapi

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
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
