package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP3GrowthProtectedRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP3GrowthRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/growth/public-hamsters"},
		{http.MethodPut, "/v1/growth/public-hamsters/11111111-1111-1111-1111-111111111111"},
		{http.MethodGet, "/v1/growth/opportunities"},
		{http.MethodGet, "/v1/growth/campaigns"},
		{http.MethodPost, "/v1/growth/campaigns/generate"},
		{http.MethodGet, "/v1/growth/campaigns/11111111-1111-1111-1111-111111111111"},
		{http.MethodPost, "/v1/growth/campaigns/11111111-1111-1111-1111-111111111111/publish"},
		{http.MethodPost, "/v1/growth/campaigns/11111111-1111-1111-1111-111111111111/archive"},
		{http.MethodGet, "/v1/growth/leads"},
	}
	for _, item := range paths {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(item.method, item.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", item.method, item.path, recorder.Code)
		}
	}
}

func TestAttachCampaignPublicPath(t *testing.T) {
	item := map[string]any{"campaign_code": "c_demo123"}
	attachCampaignPublicPath(item, "snow-cattery")
	if item["public_url_path"] != "/p/snow-cattery?campaign=c_demo123" {
		t.Fatalf("unexpected path: %#v", item["public_url_path"])
	}
	attachCampaignPublicPath(item, "")
	if item["public_url_path"] != nil {
		t.Fatalf("empty slug should clear path, got %#v", item["public_url_path"])
	}
}

func TestNewCampaignCodeFormat(t *testing.T) {
	code := newCampaignCode()
	if len(code) < 10 || code[:2] != "c_" {
		t.Fatalf("unexpected campaign code: %q", code)
	}
}

func TestPublicVarietyProjection(t *testing.T) {
	if got := publicVariety("mesocricetus_auratus|金丝熊"); got != "金丝熊" {
		t.Fatalf("got %q", got)
	}
	if got := publicVariety("金丝熊"); got != "金丝熊" {
		t.Fatalf("got %q", got)
	}
}
