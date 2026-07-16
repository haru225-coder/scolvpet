package objectstore

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
)

func TestLocalFSObjectStoreRejectsPathTraversal(t *testing.T) {
	store, err := NewLocalFS(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	body := []byte("csv")
	hash := sha256Hex(body)
	keys := []string{
		"../outside.csv",
		"nested/../../outside.csv",
		filepath.Join(store.Root, "outside.csv"),
	}
	for _, key := range keys {
		t.Run(key, func(t *testing.T) {
			_, err := store.Put(context.Background(), PutRequest{
				Key:       key,
				Body:      bytes.NewReader(body),
				SizeBytes: int64(len(body)),
				SHA256:    hash,
			})
			if !errors.Is(err, ErrInvalidKey) {
				t.Fatalf("Put(%q) error = %v, want ErrInvalidKey", key, err)
			}
		})
	}
	if _, err := os.Stat(filepath.Join(filepath.Dir(store.Root), "outside.csv")); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("path traversal created an outside object: %v", err)
	}
}

func TestLocalFSObjectStorePutRejectsSizeMismatch(t *testing.T) {
	store, err := NewLocalFS(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	body := []byte("csv")
	_, err = store.Put(context.Background(), PutRequest{
		Key:       "imports/size.csv",
		Body:      bytes.NewReader(body),
		SizeBytes: int64(len(body) + 1),
		SHA256:    sha256Hex(body),
	})
	if !errors.Is(err, ErrSizeMismatch) {
		t.Fatalf("Put size mismatch error = %v, want ErrSizeMismatch", err)
	}
	if _, err := os.Stat(filepath.Join(store.Root, "imports", "size.csv")); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("size-mismatched upload left an object: %v", err)
	}
}

func TestLocalFSObjectStorePutRejectsChecksumMismatch(t *testing.T) {
	store, err := NewLocalFS(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	body := []byte("csv")
	_, err = store.Put(context.Background(), PutRequest{
		Key:       "imports/checksum.csv",
		Body:      bytes.NewReader(body),
		SizeBytes: int64(len(body)),
		SHA256:    sha256Hex([]byte("different")),
	})
	if !errors.Is(err, ErrChecksumMismatch) {
		t.Fatalf("Put checksum mismatch error = %v, want ErrChecksumMismatch", err)
	}
	if _, err := os.Stat(filepath.Join(store.Root, "imports", "checksum.csv")); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("checksum-mismatched upload left an object: %v", err)
	}
}

func TestLocalFSObjectStorePutGetDelete(t *testing.T) {
	store, err := NewLocalFS(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	body := []byte("internal_code,name\nH-001,雪球\n")
	expiresAt := time.Now().UTC().Add(time.Hour).Truncate(time.Second)
	key := "imports/hamsters.csv"
	info, err := store.Put(context.Background(), PutRequest{
		Key:         key,
		Body:        bytes.NewReader(body),
		SizeBytes:   int64(len(body)),
		SHA256:      sha256Hex(body),
		ContentType: "text/csv",
		ExpiresAt:   expiresAt,
	})
	if err != nil {
		t.Fatalf("Put() error = %v", err)
	}
	if info.Key != key || info.SHA256 != sha256Hex(body) || info.SizeBytes != int64(len(body)) || info.ContentType != "text/csv" || !info.ExpiresAt.Equal(expiresAt) {
		t.Fatalf("Put() info = %+v", info)
	}

	reader, got, err := store.Get(context.Background(), key)
	if err != nil {
		t.Fatalf("Get() error = %v", err)
	}
	gotBody, readErr := io.ReadAll(reader)
	closeErr := reader.Close()
	if readErr != nil || closeErr != nil {
		t.Fatalf("reading Get() body: read=%v close=%v", readErr, closeErr)
	}
	if !bytes.Equal(gotBody, body) {
		t.Fatalf("Get() body = %q, want %q", gotBody, body)
	}
	if got.Key != key || got.SizeBytes != int64(len(body)) || got.SHA256 != sha256Hex(body) {
		t.Fatalf("Get() info = %+v", got)
	}

	if err := store.Delete(context.Background(), key); err != nil {
		t.Fatalf("Delete() error = %v", err)
	}
	if err := store.Delete(context.Background(), key); err != nil {
		t.Fatalf("second Delete() error = %v", err)
	}
	if _, _, err := store.Get(context.Background(), key); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("Get() after Delete error = %v, want os.ErrNotExist", err)
	}
}

func TestS3ObjectStorePutGetDeletePathStyleAndSignature(t *testing.T) {
	const key = "imports/hamsters.csv"
	body := []byte("internal_code,name\nH-001,雪球\n")
	expiresAt := time.Now().UTC().Add(time.Hour).Truncate(time.Second)
	objects := map[string][]byte{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !strings.HasPrefix(r.Header.Get("Authorization"), "AWS4-HMAC-SHA256 Credential=test-access/") {
			http.Error(w, "missing AWS Signature V4 authorization", http.StatusUnauthorized)
			return
		}
		if r.Header.Get("X-Amz-Date") == "" || r.Header.Get("X-Amz-Content-Sha256") == "" {
			http.Error(w, "missing AWS signature headers", http.StatusUnauthorized)
			return
		}
		if r.URL.Path != "/scolvpet/"+key {
			http.Error(w, "unexpected path: "+r.URL.Path, http.StatusBadRequest)
			return
		}
		switch r.Method {
		case http.MethodPut:
			gotBody, err := io.ReadAll(r.Body)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			if !bytes.Equal(gotBody, body) || r.Header.Get("X-Amz-Content-Sha256") != sha256Hex(body) {
				http.Error(w, "body or content hash mismatch", http.StatusBadRequest)
				return
			}
			if r.Header.Get("X-Amz-Meta-Sha256") != sha256Hex(body) || r.Header.Get("Content-Type") != "text/csv" {
				http.Error(w, "metadata mismatch", http.StatusBadRequest)
				return
			}
			objects[key] = append([]byte(nil), gotBody...)
			w.WriteHeader(http.StatusOK)
		case http.MethodGet:
			stored, ok := objects[key]
			if !ok {
				http.NotFound(w, r)
				return
			}
			w.Header().Set("Content-Type", "text/csv")
			w.Header().Set("X-Amz-Meta-Sha256", sha256Hex(stored))
			w.Header().Set("X-Amz-Meta-Expires-At", expiresAt.Format(time.RFC3339Nano))
			_, _ = w.Write(stored)
		case http.MethodDelete:
			if _, ok := objects[key]; !ok {
				http.NotFound(w, r)
				return
			}
			delete(objects, key)
			w.WriteHeader(http.StatusNoContent)
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()

	store, err := NewS3(S3Config{
		Endpoint:        server.URL,
		Bucket:          "scolvpet",
		Region:          "us-east-1",
		AccessKeyID:     "test-access",
		SecretAccessKey: "test-secret",
		PathStyle:       true,
	})
	if err != nil {
		t.Fatal(err)
	}
	info, err := store.Put(context.Background(), PutRequest{
		Key:         key,
		Body:        bytes.NewReader(body),
		SizeBytes:   int64(len(body)),
		SHA256:      sha256Hex(body),
		ContentType: "text/csv",
		ExpiresAt:   expiresAt,
	})
	if err != nil {
		t.Fatalf("Put() error = %v", err)
	}
	if info.Key != key || info.SHA256 != sha256Hex(body) || info.SizeBytes != int64(len(body)) || info.ContentType != "text/csv" || !info.ExpiresAt.Equal(expiresAt) {
		t.Fatalf("Put() info = %+v", info)
	}

	reader, got, err := store.Get(context.Background(), key)
	if err != nil {
		t.Fatalf("Get() error = %v", err)
	}
	gotBody, readErr := io.ReadAll(reader)
	closeErr := reader.Close()
	if readErr != nil || closeErr != nil {
		t.Fatalf("reading Get() body: read=%v close=%v", readErr, closeErr)
	}
	if !bytes.Equal(gotBody, body) || got.Key != key || got.SizeBytes != int64(len(body)) || got.SHA256 != sha256Hex(body) || !got.ExpiresAt.Equal(expiresAt) {
		t.Fatalf("Get() body/info = %q / %+v", gotBody, got)
	}

	if err := store.Delete(context.Background(), key); err != nil {
		t.Fatalf("Delete() error = %v", err)
	}
	if err := store.Delete(context.Background(), key); err != nil {
		t.Fatalf("idempotent Delete() error = %v", err)
	}
}

func TestS3ObjectStoreRejectsUploadBeforeRemoteRequest(t *testing.T) {
	called := false
	server := httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) { called = true }))
	defer server.Close()
	store, err := NewS3(S3Config{
		Endpoint:        server.URL,
		Bucket:          "scolvpet",
		Region:          "us-east-1",
		AccessKeyID:     "test-access",
		SecretAccessKey: "test-secret",
		PathStyle:       true,
	})
	if err != nil {
		t.Fatal(err)
	}
	body := []byte("csv")
	_, err = store.Put(context.Background(), PutRequest{
		Key:       "imports/bad.csv",
		Body:      bytes.NewReader(body),
		SizeBytes: int64(len(body) + 1),
		SHA256:    sha256Hex(body),
	})
	if !errors.Is(err, ErrSizeMismatch) {
		t.Fatalf("Put() error = %v, want ErrSizeMismatch", err)
	}
	if called {
		t.Fatal("remote S3 request was sent before local validation completed")
	}
}

func TestS3ObjectStoreVirtualHostedURLAndValidation(t *testing.T) {
	store, err := NewS3(S3Config{
		Endpoint:        "https://s3.example.test/base",
		Bucket:          "scolvpet",
		Region:          "us-east-1",
		AccessKeyID:     "access",
		SecretAccessKey: "secret",
	})
	if err != nil {
		t.Fatal(err)
	}
	target, err := store.objectURL("imports/hamsters.csv")
	if err != nil {
		t.Fatal(err)
	}
	if target.Host != "scolvpet.s3.example.test" || target.Path != "/base/imports/hamsters.csv" {
		t.Fatalf("virtual-hosted URL = %s, want https://scolvpet.s3.example.test/base/imports/hamsters.csv", target)
	}
	if _, err := store.objectURL("../outside.csv"); !errors.Is(err, ErrInvalidKey) {
		t.Fatalf("objectURL traversal error = %v, want ErrInvalidKey", err)
	}
}

func TestNewS3RejectsIncompleteConfig(t *testing.T) {
	_, err := NewS3(S3Config{Endpoint: "https://s3.example.test"})
	if err == nil || !strings.Contains(err.Error(), "S3 bucket is empty") {
		t.Fatalf("expected bucket validation error, got %v", err)
	}
}

// TestS3ObjectStoreLiveSmoke exercises a real S3/MinIO endpoint when the
// OBJECT_STORE_* environment variables are present. Without them the test is
// skipped and reported as 待确认 rather than a false success.
func TestS3ObjectStoreLiveSmoke(t *testing.T) {
	endpoint := strings.TrimSpace(os.Getenv("OBJECT_STORE_ENDPOINT"))
	bucket := strings.TrimSpace(os.Getenv("OBJECT_STORE_BUCKET"))
	region := strings.TrimSpace(os.Getenv("OBJECT_STORE_REGION"))
	accessKey := os.Getenv("OBJECT_STORE_ACCESS_KEY")
	secretKey := os.Getenv("OBJECT_STORE_SECRET_KEY")
	if endpoint == "" || bucket == "" || region == "" || accessKey == "" || secretKey == "" {
		t.Skip("待确认: S3/MinIO live smoke skipped (set OBJECT_STORE_ENDPOINT/BUCKET/REGION/ACCESS_KEY/SECRET_KEY)")
	}
	pathStyle := true
	if raw := strings.TrimSpace(os.Getenv("OBJECT_STORE_PATH_STYLE")); raw != "" {
		parsed, err := strconv.ParseBool(raw)
		if err != nil {
			t.Fatalf("OBJECT_STORE_PATH_STYLE: %v", err)
		}
		pathStyle = parsed
	}
	prefix := strings.Trim(strings.TrimSpace(os.Getenv("OBJECT_STORE_SMOKE_PREFIX")), "/")
	if prefix == "" {
		prefix = "i6-objectstore-smoke"
	}
	store, err := NewS3(S3Config{
		Endpoint:        endpoint,
		Bucket:          bucket,
		Region:          region,
		AccessKeyID:     accessKey,
		SecretAccessKey: secretKey,
		PathStyle:       pathStyle,
	})
	if err != nil {
		t.Fatalf("NewS3: %v", err)
	}
	key := prefix + "/" + time.Now().UTC().Format("20060102T150405.000000000") + ".bin"
	body := []byte("scolvpet-i6-objectstore-smoke\n")
	digest := sha256Hex(body)
	contentType := "application/octet-stream"
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	info, err := store.Put(ctx, PutRequest{
		Key: key, Body: bytes.NewReader(body), SizeBytes: int64(len(body)),
		SHA256: digest, ContentType: contentType, ExpiresAt: time.Now().UTC().Add(time.Hour),
	})
	if err != nil {
		t.Fatalf("Put: %v", err)
	}
	if info.Key != key || info.SizeBytes != int64(len(body)) || !strings.EqualFold(info.SHA256, digest) || info.ContentType != contentType {
		t.Fatalf("Put info = %+v", info)
	}
	reader, got, err := store.Get(ctx, key)
	if err != nil {
		t.Fatalf("Get: %v", err)
	}
	gotBody, readErr := io.ReadAll(reader)
	closeErr := reader.Close()
	if readErr != nil || closeErr != nil {
		t.Fatalf("Get body: read=%v close=%v", readErr, closeErr)
	}
	if !bytes.Equal(gotBody, body) {
		t.Fatalf("Get body mismatch")
	}
	if got.Key != key || got.SizeBytes != int64(len(body)) {
		t.Fatalf("Get info = %+v", got)
	}
	if got.SHA256 != "" && !strings.EqualFold(got.SHA256, digest) {
		t.Fatalf("Get sha256 = %s want %s", got.SHA256, digest)
	}
	if err := store.Delete(ctx, key); err != nil {
		t.Fatalf("Delete: %v", err)
	}
	if _, _, err := store.Get(ctx, key); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("Get after Delete error = %v, want os.ErrNotExist", err)
	}
	style := "virtual-hosted-style"
	if pathStyle {
		style = "path-style"
	}
	t.Logf("objectstore live smoke passed: key=%s size=%d sha256=%s style=%s", key, len(body), digest, style)
}

func sha256Hex(body []byte) string {
	sum := sha256.Sum256(body)
	return hex.EncodeToString(sum[:])
}
