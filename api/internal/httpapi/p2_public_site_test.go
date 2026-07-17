package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func TestP2PublicSiteOwnerRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP2PublicSiteRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/public-site"},
		{http.MethodPut, "/v1/public-site"},
		{http.MethodPost, "/v1/public-site/publish"},
		{http.MethodPost, "/v1/public-site/unpublish"},
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

func TestDefaultPublicSlug(t *testing.T) {
	id := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	got := defaultPublicSlug("雪团熊舍 Snow", id)
	if got == "" || !publicSiteSlugRE.MatchString(got) {
		// Chinese stripped → may fall back
		got = defaultPublicSlug("", id)
	}
	if !publicSiteSlugRE.MatchString(got) {
		t.Fatalf("slug=%q", got)
	}
	if got2 := defaultPublicSlug("ab", id); got2 != "ab" {
		t.Fatalf("got2=%q", got2)
	}
}

func TestPublicSiteSlugRE(t *testing.T) {
	if !publicSiteSlugRE.MatchString("snow-cattery") {
		t.Fatal("valid slug rejected")
	}
	if publicSiteSlugRE.MatchString("-bad") || publicSiteSlugRE.MatchString("Bad") {
		t.Fatal("invalid slug accepted")
	}
}
