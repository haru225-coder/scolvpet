package httpapi

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/importcsv"
	"github.com/scolvpet/scolvpet/api/internal/objectstore"
	"github.com/scolvpet/scolvpet/api/internal/store"
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

func TestI2ImportVersionConflictIs409(t *testing.T) {
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/v1/data-center/import-jobs/job/commit", nil)
	writeI2ImportError(recorder, request, &store.VersionError{Current: 4})
	if recorder.Code != http.StatusConflict {
		t.Fatalf("status = %d, want 409", recorder.Code)
	}
	var body map[string]any
	if err := json.Unmarshal(recorder.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode: %v", err)
	}
	errObj, _ := body["error"].(map[string]any)
	if errObj["code"] != "VERSION_CONFLICT" {
		t.Fatalf("code = %#v", errObj["code"])
	}
	details, _ := errObj["details"].(map[string]any)
	if details["current_version"] != float64(4) {
		t.Fatalf("missing current_version: %#v", body)
	}
}

func TestI2ImportSessionHydratesAfterMemoryClear(t *testing.T) {
	objects, err := objectstore.NewLocalFS(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	owner := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	jobID := "22222222-2222-2222-2222-222222222222"
	server := &Server{ImportObjects: objects}
	csv := []byte("internal_code,name\nH1,哈豆\n")
	session := &i2ImportSession{
		Job: importcsv.LocalJob{
			ID: jobID, OwnerID: owner.String(), BatchKey: "batch-key-01",
		},
		CSV: csv, FileName: "hamsters.csv", Version: 2, Phase: "mapping",
		Template: importcsv.TemplateHamster, Mapping: map[string]string{"name": "name"},
	}
	if err := server.persistI2ImportSession(context.Background(), session); err != nil {
		t.Fatalf("persist: %v", err)
	}
	i2ImportStateLock.Lock()
	delete(i2ImportSessions, jobID)
	i2ImportStateLock.Unlock()

	got, ok := server.loadI2ImportSession(owner, jobID)
	if !ok || got == nil {
		t.Fatal("expected hydrated session")
	}
	if string(got.CSV) != string(csv) {
		t.Fatalf("csv = %q", got.CSV)
	}
	if got.Version != 2 || got.Phase != "mapping" {
		t.Fatalf("meta version=%d phase=%s", got.Version, got.Phase)
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
