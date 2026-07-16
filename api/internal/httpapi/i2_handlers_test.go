package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/importcsv"
)

func TestI2CommitUsesCreatedImportBatchKey(t *testing.T) {
	session := &i2ImportSession{Job: importcsv.LocalJob{BatchKey: "created-batch-0001"}}
	if got := i2CommitBatchKey(session, "commit-batch-0001"); got != "created-batch-0001" {
		t.Fatalf("commit batch key = %q, want created job key", got)
	}
}

func TestI2CoreRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	paths := []string{
		"/v1/hamsters",
		"/v1/enclosures",
		"/v1/litters",
		"/v1/weight-records",
		"/v1/data-center/import-jobs",
		"/v1/data-center/import-templates/hamster",
	}
	for _, path := range paths {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(http.MethodGet, path, nil)
		server.Handler().ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s expected 401, got %d", path, recorder.Code)
		}
	}
}

func TestI2ImportUploadRequiresAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/data-center/import-uploads", nil)
	server.Handler().ServeHTTP(recorder, request)
	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("import upload expected 401, got %d", recorder.Code)
	}
}
