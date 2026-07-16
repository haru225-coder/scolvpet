// Package objectstore contains the storage boundary used by data-center imports.
//
// The HTTP layer only depends on ObjectStore. LocalFSObjectStore is intentionally
// small and deterministic for development/tests; a production S3-compatible
// implementation can satisfy the same interface without changing API handlers.
package objectstore

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"sort"
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

// S3Config configures the standard-library S3 Signature V4 client. The
// endpoint may point at AWS S3, MinIO, or another S3-compatible service.
type S3Config struct {
	Endpoint        string
	Bucket          string
	Region          string
	AccessKeyID     string
	SecretAccessKey string
	PathStyle       bool
	HTTPClient      *http.Client
}

// S3ObjectStore implements ObjectStore with AWS Signature V4 over HTTP. It
// deliberately uses only the standard library so the API binary does not
// acquire a vendor-specific SDK dependency.
type S3ObjectStore struct {
	endpoint        url.URL
	bucket          string
	region          string
	accessKeyID     string
	secretAccessKey string
	pathStyle       bool
	httpClient      *http.Client
}

// NewS3 creates an S3-compatible ObjectStore. HTTP endpoints are supported
// for local MinIO development; production configuration validation decides
// whether an endpoint must use HTTPS.
func NewS3(config S3Config) (*S3ObjectStore, error) {
	endpoint := strings.TrimSpace(config.Endpoint)
	if endpoint == "" {
		return nil, errors.New("objectstore: S3 endpoint is empty")
	}
	parsed, err := url.Parse(endpoint)
	if err != nil || parsed.Scheme == "" || parsed.Host == "" || parsed.User != nil {
		return nil, fmt.Errorf("objectstore: invalid S3 endpoint %q", config.Endpoint)
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return nil, fmt.Errorf("objectstore: S3 endpoint scheme must be http or https, got %q", parsed.Scheme)
	}
	bucket := strings.TrimSpace(config.Bucket)
	if bucket == "" || strings.ContainsAny(bucket, "/\\") {
		return nil, errors.New("objectstore: S3 bucket is empty or contains a path separator")
	}
	region := strings.TrimSpace(config.Region)
	if region == "" {
		return nil, errors.New("objectstore: S3 region is empty")
	}
	if strings.TrimSpace(config.AccessKeyID) == "" {
		return nil, errors.New("objectstore: S3 access key is empty")
	}
	if config.SecretAccessKey == "" {
		return nil, errors.New("objectstore: S3 secret key is empty")
	}
	if parsed.Path == "/" {
		parsed.Path = ""
	}
	return &S3ObjectStore{
		endpoint:        *parsed,
		bucket:          bucket,
		region:          region,
		accessKeyID:     config.AccessKeyID,
		secretAccessKey: config.SecretAccessKey,
		pathStyle:       config.PathStyle,
		httpClient:      firstHTTPClient(config.HTTPClient),
	}, nil
}

func firstHTTPClient(client *http.Client) *http.Client {
	if client != nil {
		return client
	}
	return http.DefaultClient
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
	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		_ = file.Close()
		return nil, ObjectInfo{}, fmt.Errorf("objectstore: hash local object: %w", err)
	}
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		_ = file.Close()
		return nil, ObjectInfo{}, fmt.Errorf("objectstore: rewind local object: %w", err)
	}
	return file, ObjectInfo{Key: key, SHA256: hex.EncodeToString(hash.Sum(nil)), SizeBytes: stat.Size()}, nil
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

// Put uploads an object after spooling it to a temporary file. Spooling lets
// the client verify the declared size and SHA-256 before the remote PUT is
// sent, while keeping memory bounded for larger import files.
func (s *S3ObjectStore) Put(ctx context.Context, request PutRequest) (ObjectInfo, error) {
	if err := validateObjectKey(request.Key); err != nil {
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

	tmp, err := os.CreateTemp("", "scolvpet-s3-upload-*")
	if err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: create S3 temporary object: %w", err)
	}
	tmpName := tmp.Name()
	defer func() {
		_ = tmp.Close()
		_ = os.Remove(tmpName)
	}()
	hash := sha256.New()
	count, err := io.Copy(io.MultiWriter(tmp, hash), request.Body)
	if err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: spool S3 object: %w", err)
	}
	if count != request.SizeBytes {
		return ObjectInfo{}, ErrSizeMismatch
	}
	digest := hex.EncodeToString(hash.Sum(nil))
	if !strings.EqualFold(digest, request.SHA256) {
		return ObjectInfo{}, ErrChecksumMismatch
	}
	if _, err := tmp.Seek(0, io.SeekStart); err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: rewind S3 object: %w", err)
	}

	target, err := s.objectURL(request.Key)
	if err != nil {
		return ObjectInfo{}, err
	}
	httpRequest, err := http.NewRequestWithContext(ctx, http.MethodPut, target.String(), tmp)
	if err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: create S3 PUT request: %w", err)
	}
	httpRequest.ContentLength = count
	if contentType := strings.TrimSpace(request.ContentType); contentType != "" {
		httpRequest.Header.Set("Content-Type", contentType)
	}
	httpRequest.Header.Set("X-Amz-Meta-Sha256", digest)
	if !request.ExpiresAt.IsZero() {
		httpRequest.Header.Set("X-Amz-Meta-Expires-At", request.ExpiresAt.UTC().Format(time.RFC3339Nano))
	}
	if err := s.sign(httpRequest, digest, time.Now().UTC()); err != nil {
		return ObjectInfo{}, err
	}
	response, err := s.httpClient.Do(httpRequest)
	if err != nil {
		return ObjectInfo{}, fmt.Errorf("objectstore: S3 PUT %q: %w", request.Key, err)
	}
	defer response.Body.Close()
	if err := checkS3Response("PUT", request.Key, response); err != nil {
		return ObjectInfo{}, err
	}
	return ObjectInfo{
		Key:         request.Key,
		SHA256:      digest,
		SizeBytes:   count,
		ContentType: request.ContentType,
		ExpiresAt:   request.ExpiresAt,
	}, nil
}

func (s *S3ObjectStore) Get(ctx context.Context, key string) (io.ReadCloser, ObjectInfo, error) {
	target, err := s.objectURL(key)
	if err != nil {
		return nil, ObjectInfo{}, err
	}
	httpRequest, err := http.NewRequestWithContext(ctx, http.MethodGet, target.String(), nil)
	if err != nil {
		return nil, ObjectInfo{}, fmt.Errorf("objectstore: create S3 GET request: %w", err)
	}
	if err := s.sign(httpRequest, emptySHA256, time.Now().UTC()); err != nil {
		return nil, ObjectInfo{}, err
	}
	response, err := s.httpClient.Do(httpRequest)
	if err != nil {
		return nil, ObjectInfo{}, fmt.Errorf("objectstore: S3 GET %q: %w", key, err)
	}
	if err := checkS3Response("GET", key, response); err != nil {
		_ = response.Body.Close()
		return nil, ObjectInfo{}, err
	}
	info, err := objectInfoFromResponse(key, response)
	if err != nil {
		_ = response.Body.Close()
		return nil, ObjectInfo{}, err
	}
	return response.Body, info, nil
}

func (s *S3ObjectStore) Delete(ctx context.Context, key string) error {
	target, err := s.objectURL(key)
	if err != nil {
		return err
	}
	httpRequest, err := http.NewRequestWithContext(ctx, http.MethodDelete, target.String(), nil)
	if err != nil {
		return fmt.Errorf("objectstore: create S3 DELETE request: %w", err)
	}
	if err := s.sign(httpRequest, emptySHA256, time.Now().UTC()); err != nil {
		return err
	}
	response, err := s.httpClient.Do(httpRequest)
	if err != nil {
		return fmt.Errorf("objectstore: S3 DELETE %q: %w", key, err)
	}
	defer response.Body.Close()
	if response.StatusCode == http.StatusNotFound {
		return nil
	}
	return checkS3Response("DELETE", key, response)
}

const emptySHA256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

func (s *S3ObjectStore) objectURL(key string) (*url.URL, error) {
	if err := validateObjectKey(key); err != nil {
		return nil, err
	}
	target := s.endpoint
	if s.pathStyle {
		target.Path = joinURLPath(target.Path, s.bucket, key)
	} else {
		target.Host = s.bucket + "." + target.Host
		target.Path = joinURLPath(target.Path, key)
	}
	target.RawPath = ""
	return &target, nil
}

func validateObjectKey(key string) error {
	if strings.TrimSpace(key) == "" || strings.HasPrefix(key, "/") || strings.ContainsRune(key, '\x00') {
		return ErrInvalidKey
	}
	for _, segment := range strings.Split(strings.ReplaceAll(key, "\\", "/"), "/") {
		if segment == "." || segment == ".." {
			return ErrInvalidKey
		}
	}
	return nil
}

func joinURLPath(base string, parts ...string) string {
	segments := make([]string, 0, len(parts)+1)
	if trimmed := strings.Trim(base, "/"); trimmed != "" {
		segments = append(segments, trimmed)
	}
	for _, part := range parts {
		segments = append(segments, strings.Trim(part, "/"))
	}
	return "/" + strings.Join(segments, "/")
}

func (s *S3ObjectStore) sign(request *http.Request, payloadHash string, now time.Time) error {
	if request == nil {
		return errors.New("objectstore: S3 request is nil")
	}
	now = now.UTC()
	date := now.Format("20060102")
	amzDate := now.Format("20060102T150405Z")
	request.Header.Set("X-Amz-Date", amzDate)
	request.Header.Set("X-Amz-Content-Sha256", payloadHash)
	canonicalHeaders, signedHeaders := canonicalHeaders(request)
	canonicalRequest := strings.Join([]string{
		request.Method,
		canonicalURI(request.URL),
		canonicalQuery(request.URL),
		canonicalHeaders,
		signedHeaders,
		payloadHash,
	}, "\n")
	credentialScope := date + "/" + s.region + "/s3/aws4_request"
	stringToSign := strings.Join([]string{
		"AWS4-HMAC-SHA256",
		amzDate,
		credentialScope,
		hexSHA256([]byte(canonicalRequest)),
	}, "\n")
	signingKey := hmacSHA256(
		hmacSHA256(
			hmacSHA256(
				hmacSHA256([]byte("AWS4"+s.secretAccessKey), []byte(date)),
				[]byte(s.region),
			),
			[]byte("s3"),
		),
		[]byte("aws4_request"),
	)
	signature := hex.EncodeToString(hmacSHA256(signingKey, []byte(stringToSign)))
	request.Header.Set("Authorization", fmt.Sprintf(
		"AWS4-HMAC-SHA256 Credential=%s/%s, SignedHeaders=%s, Signature=%s",
		s.accessKeyID, credentialScope, signedHeaders, signature,
	))
	return nil
}

func canonicalHeaders(request *http.Request) (string, string) {
	values := map[string][]string{"host": {request.Host}}
	if values["host"][0] == "" && request.URL != nil {
		values["host"][0] = request.URL.Host
	}
	for name, headers := range request.Header {
		lowerName := strings.ToLower(name)
		if lowerName == "authorization" || lowerName == "host" || lowerName == "content-length" {
			continue
		}
		values[lowerName] = append(values[lowerName], headers...)
	}
	names := make([]string, 0, len(values))
	for name := range values {
		names = append(names, name)
	}
	sort.Strings(names)
	var canonical strings.Builder
	for _, name := range names {
		joined := make([]string, 0, len(values[name]))
		for _, value := range values[name] {
			joined = append(joined, strings.Join(strings.Fields(value), " "))
		}
		canonical.WriteString(name)
		canonical.WriteByte(':')
		canonical.WriteString(strings.Join(joined, ","))
		canonical.WriteByte('\n')
	}
	return canonical.String(), strings.Join(names, ";")
}

func canonicalURI(target *url.URL) string {
	if target == nil {
		return "/"
	}
	path := target.EscapedPath()
	if path == "" {
		return "/"
	}
	return path
}

func canonicalQuery(target *url.URL) string {
	if target == nil || target.RawQuery == "" {
		return ""
	}
	query := target.Query()
	type pair struct{ key, value string }
	pairs := make([]pair, 0)
	for key, values := range query {
		if len(values) == 0 {
			pairs = append(pairs, pair{key: awsURIEncode(key, true), value: ""})
			continue
		}
		for _, value := range values {
			pairs = append(pairs, pair{key: awsURIEncode(key, true), value: awsURIEncode(value, true)})
		}
	}
	sort.Slice(pairs, func(i, j int) bool {
		if pairs[i].key == pairs[j].key {
			return pairs[i].value < pairs[j].value
		}
		return pairs[i].key < pairs[j].key
	})
	parts := make([]string, 0, len(pairs))
	for _, item := range pairs {
		parts = append(parts, item.key+"="+item.value)
	}
	return strings.Join(parts, "&")
}

func awsURIEncode(value string, encodeSlash bool) string {
	const hexDigits = "0123456789ABCDEF"
	var encoded strings.Builder
	for i := 0; i < len(value); i++ {
		character := value[i]
		if (character >= 'a' && character <= 'z') || (character >= 'A' && character <= 'Z') ||
			(character >= '0' && character <= '9') || character == '-' || character == '_' || character == '.' || character == '~' || (!encodeSlash && character == '/') {
			encoded.WriteByte(character)
			continue
		}
		encoded.WriteByte('%')
		encoded.WriteByte(hexDigits[character>>4])
		encoded.WriteByte(hexDigits[character&0x0f])
	}
	return encoded.String()
}

func hmacSHA256(key, value []byte) []byte {
	hasher := hmac.New(sha256.New, key)
	_, _ = hasher.Write(value)
	return hasher.Sum(nil)
}

func hexSHA256(value []byte) string {
	sum := sha256.Sum256(value)
	return hex.EncodeToString(sum[:])
}

func objectInfoFromResponse(key string, response *http.Response) (ObjectInfo, error) {
	info := ObjectInfo{
		Key:         key,
		SizeBytes:   response.ContentLength,
		SHA256:      strings.ToLower(strings.TrimSpace(response.Header.Get("X-Amz-Meta-Sha256"))),
		ContentType: response.Header.Get("Content-Type"),
	}
	if expiresAt := strings.TrimSpace(response.Header.Get("X-Amz-Meta-Expires-At")); expiresAt != "" {
		parsed, err := time.Parse(time.RFC3339Nano, expiresAt)
		if err != nil {
			return ObjectInfo{}, fmt.Errorf("objectstore: invalid S3 expires-at metadata: %w", err)
		}
		info.ExpiresAt = parsed
	}
	return info, nil
}

func checkS3Response(operation, key string, response *http.Response) error {
	if response.StatusCode >= http.StatusOK && response.StatusCode < http.StatusMultipleChoices {
		return nil
	}
	body, _ := io.ReadAll(io.LimitReader(response.Body, 4096))
	return &S3HTTPError{Operation: operation, Key: key, StatusCode: response.StatusCode, Body: strings.TrimSpace(string(body))}
}

// S3HTTPError preserves the remote status code and maps missing objects to
// os.ErrNotExist so callers can use the same check as LocalFSObjectStore.
type S3HTTPError struct {
	Operation  string
	Key        string
	StatusCode int
	Body       string
}

func (e *S3HTTPError) Error() string {
	if e.Body == "" {
		return fmt.Sprintf("objectstore: S3 %s %q returned HTTP %d", e.Operation, e.Key, e.StatusCode)
	}
	return fmt.Sprintf("objectstore: S3 %s %q returned HTTP %d: %s", e.Operation, e.Key, e.StatusCode, e.Body)
}

func (e *S3HTTPError) Unwrap() error {
	if e.StatusCode == http.StatusNotFound {
		return os.ErrNotExist
	}
	return nil
}
