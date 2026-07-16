// Package objectstore contains the storage boundary used by data-center imports.
//
// The HTTP layer only depends on ObjectStore. LocalFSObjectStore is intentionally
// small and deterministic for development/tests; a production S3-compatible
// implementation can satisfy the same interface without changing API handlers.
package objectstore

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"
)

var (
	ErrInvalidKey       = errors.New("objectstore: invalid object key")
	ErrChecksumMismatch = errors.New("objectstore: checksum mismatch")
	ErrSizeMismatch     = errors.New("objectstore: size mismatch")
)

// ObjectInfo is the verified metadata returned by object stores.
type ObjectInfo struct {
	Key         string
	SHA256      string
	SizeBytes   int64
	ContentType string
	ExpiresAt   time.Time
}

// PutRequest describes an immutable object upload. SHA256 and SizeBytes are
// checked while writing so metadata and content cannot silently diverge.
type PutRequest struct {
	Key         string
	Body        io.Reader
	SizeBytes   int64
	SHA256      string
	ContentType string
	ExpiresAt   time.Time
}

// ObjectStore is the persistence boundary for import file bytes. Implementors
// may be local filesystem, S3, MinIO, or another S3-compatible backend.
type ObjectStore interface {
	Put(context.Context, PutRequest) (ObjectInfo, error)
	Get(context.Context, string) (io.ReadCloser, ObjectInfo, error)
	Delete(context.Context, string) error
}

// LocalFSObjectStore stores objects below Root using the object key as a
// relative path. It is suitable for local development and integration tests;
// production deployments should inject an S3-compatible implementation.
type LocalFSObjectStore struct {
	Root string
}

func NewLocalFS(root string) (*LocalFSObjectStore, error) {
	root = strings.TrimSpace(root)
	if root == "" {
		return nil, errors.New("objectstore: local root is empty")
	}
	if err := os.MkdirAll(root, 0o750); err != nil {
		return nil, fmt.Errorf("objectstore: create root: %w", err)
	}
	return &LocalFSObjectStore{Root: root}, nil
}

func (s *LocalFSObjectStore) path(key string) (string, error) {
	key = strings.TrimSpace(key)
	if key == "" || filepath.IsAbs(key) {
		return "", ErrInvalidKey
	}
	clean := filepath.Clean(filepath.FromSlash(key))
	if clean == "." || clean == ".." || strings.HasPrefix(clean, ".."+string(filepath.Separator)) {
		return "", ErrInvalidKey
	}
	return filepath.Join(s.Root, clean), nil
}

func (s *LocalFSObjectStore) Put(_ context.Context, request PutRequest) (ObjectInfo, error) {
	path, err := s.path(request.Key)
	if err != nil {
		return ObjectInfo{}, err
	}
	if request.Body == nil {
		return ObjectInfo{}, errors.New("objectstore: body is nil")
	}
	if request.SizeBytes < 1 {
		return ObjectInfo{}, ErrSizeMismatch
	}
	if len(strings.TrimSpace(request.SHA256)) != 64 {
		return ObjectInfo{}, ErrChecksumMismatch
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: create object directory: %w", err)
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".upload-*")
	if err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: create temporary object: %w", err)
	}
	tmpName := tmp.Name()
	defer func() { _ = os.Remove(tmpName) }()
	hash := sha256.New()
	count, err := io.Copy(io.MultiWriter(tmp, hash), request.Body)
	if closeErr := tmp.Close(); err == nil {
		err = closeErr
	}
	if err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: write object: %w", err)
	}
	if count != request.SizeBytes {
		return ObjectInfo{}, ErrSizeMismatch
	}
	digest := hex.EncodeToString(hash.Sum(nil))
	if !strings.EqualFold(digest, request.SHA256) {
		return ObjectInfo{}, ErrChecksumMismatch
	}
	if err := os.Rename(tmpName, path); err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: finalize object: %w", err)
	}
	return ObjectInfo{Key: request.Key, SHA256: digest, SizeBytes: count, ContentType: request.ContentType, ExpiresAt: request.ExpiresAt}, nil
}

func (s *LocalFSObjectStore) Get(_ context.Context, key string) (io.ReadCloser, ObjectInfo, error) {
	path, err := s.path(key)
	if err != nil {
		return nil, ObjectInfo{}, err
	}
	file, err := os.Open(path)
	if err != nil {
		return nil, ObjectInfo{}, err
	}
	stat, err := file.Stat()
	if err != nil {
		_ = file.Close()
		return nil, ObjectInfo{}, err
	}
	return file, ObjectInfo{Key: key, SizeBytes: stat.Size()}, nil
}

func (s *LocalFSObjectStore) Delete(_ context.Context, key string) error {
	path, err := s.path(key)
	if err != nil {
		return err
	}
	if err := os.Remove(path); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return nil
}
