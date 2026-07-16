package objectstore

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
	"os"
	"path/filepath"
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
	if got.Key != key || got.SizeBytes != int64(len(body)) {
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

func sha256Hex(body []byte) string {
	sum := sha256.Sum256(body)
	return hex.EncodeToString(sum[:])
}
