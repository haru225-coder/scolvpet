package i6media

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/objectstore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

var (
	ErrValidation = errors.New("media validation error")
	ErrNotFound   = errors.New("media resource not found")
	ErrConflict   = errors.New("media resource conflict")
)

type Service struct {
	Store   *store.Store
	Objects objectstore.ObjectStore
}

type WriteResult[T any] struct {
	Value    T
	Status   int
	Headers  map[string]string
	Replayed bool
}

func NewService(s *store.Store, objects objectstore.ObjectStore) *Service {
	return &Service{Store: s, Objects: objects}
}

func runWrite[T any](ctx context.Context, db *store.Store, ownerID uuid.UUID, key, method, path string, payload []byte, fn store.IdempotentFn) (WriteResult[T], error) {
	result, err := db.RunIdempotent(ctx, ownerID, key, method, path, payload, fn)
	if err != nil {
		return WriteResult[T]{}, err
	}
	var value T
	if err := json.Unmarshal(result.Body, &value); err != nil {
		return WriteResult[T]{}, err
	}
	return WriteResult[T]{Value: value, Status: result.Status, Headers: result.Headers, Replayed: result.Replayed}, nil
}

type PresignInput struct {
	FileName    string `json:"file_name"`
	ContentType string `json:"content_type"`
	SizeBytes   int64  `json:"size_bytes"`
	SHA256      string `json:"sha256"`
	Purpose     string `json:"purpose"`
}

type CompleteInput struct {
	ObjectETag string     `json:"object_etag"`
	SizeBytes  int64      `json:"size_bytes"`
	SHA256     string     `json:"sha256"`
	CapturedAt *time.Time `json:"captured_at"`
	Timezone   *string    `json:"timezone"`
}

type ShareInput struct {
	SubjectType string      `json:"subject_type"`
	SubjectID   uuid.UUID   `json:"subject_id"`
	Fields      []string    `json:"fields"`
	MediaIDs    []uuid.UUID `json:"media_ids"`
	ExpiresAt   *time.Time  `json:"expires_at"`
}

type EditRecipeInput struct {
	Operations   []map[string]any `json:"operations"`
	OutputFormat string           `json:"output_format"`
}
type RetryProcessingInput struct {
	Scope      string      `json:"scope"`
	VariantIDs []uuid.UUID `json:"variant_ids"`
	Reason     string      `json:"reason"`
}
type CoverInput struct {
	TimeOffsetSeconds *float64   `json:"time_offset_seconds"`
	MediaVariantID    *uuid.UUID `json:"media_variant_id"`
}
type ProcessingJob struct {
	ID              uuid.UUID `json:"id"`
	Status          string    `json:"status"`
	JobType         string    `json:"job_type"`
	ProgressPercent float64   `json:"progress_percent"`
	Version         int       `json:"version"`
}

type UploadSession struct {
	ID           uuid.UUID         `json:"id"`
	UploadURL    string            `json:"upload_url"`
	Method       string            `json:"method"`
	Headers      map[string]string `json:"headers"`
	ObjectKey    string            `json:"object_key"`
	ExpiresAt    time.Time         `json:"expires_at"`
	Version      int               `json:"version"`
	Status       string            `json:"-"`
	OriginalName string            `json:"-"`
	ContentType  string            `json:"-"`
	SizeBytes    int64             `json:"-"`
	SHA256       string            `json:"-"`
	Kind         string            `json:"-"`
	OwnerID      uuid.UUID         `json:"-"`
	OrgID        uuid.UUID         `json:"-"`
}

type MediaAsset struct {
	ID        uuid.UUID `json:"id"`
	Kind      string    `json:"kind"`
	Status    string    `json:"status"`
	ObjectKey string    `json:"object_key"`
	FileName  string    `json:"file_name"`
	MimeType  string    `json:"mime_type"`
	SizeBytes int64     `json:"size_bytes"`
	SHA256    string    `json:"sha256"`
	Version   int       `json:"version"`
	CreatedAt time.Time `json:"created_at"`
}

// MediaView is the OpenAPI MediaAsset shape clients consume (urls + variants).
type MediaView struct {
	ID             uuid.UUID          `json:"id"`
	OwnerID        uuid.UUID          `json:"owner_id"`
	MediaType      string             `json:"media_type"`
	ContentType    string             `json:"content_type"`
	SizeBytes      int64              `json:"size_bytes"`
	SHA256         string             `json:"sha256"`
	Status         string             `json:"status"`
	OriginalURL    *string            `json:"original_url"`
	CoverVariantID *string            `json:"cover_variant_id,omitempty"`
	Variants       []MediaVariantView `json:"variants"`
	Version        int                `json:"version"`
	CreatedAt      time.Time          `json:"created_at"`
	UpdatedAt      time.Time          `json:"updated_at"`
}

type MediaVariantView struct {
	ID              uuid.UUID `json:"id"`
	Kind            string    `json:"kind"`
	Status          string    `json:"status"`
	URL             *string   `json:"url"`
	Width           *int      `json:"width,omitempty"`
	Height          *int      `json:"height,omitempty"`
	DurationSeconds *float64  `json:"duration_seconds,omitempty"`
}

func privateMediaContentPath(mediaID uuid.UUID, variantID *uuid.UUID) string {
	path := "/v1/media/" + mediaID.String() + "/content"
	if variantID != nil && *variantID != uuid.Nil {
		return path + "?variant_id=" + variantID.String()
	}
	return path
}

func mapMediaType(kind string) string {
	if kind == "video" {
		return "video"
	}
	return "image"
}

func mapMediaStatus(status string) string {
	switch status {
	case "ready":
		return "ready"
	case "failed", "quarantined":
		return "failed"
	default:
		return "processing"
	}
}

func mapVariantKind(kind string) string {
	switch kind {
	case "thumbnail":
		return "thumbnail"
	case "preview", "share_render":
		return "preview"
	case "image_edit", "edited":
		return "edited"
	case "video_720p":
		return "video_720p"
	case "video_1080p":
		return "video_1080p"
	case "video_cover", "cover":
		return "cover"
	case "video_transcode":
		return "video_720p"
	default:
		return "preview"
	}
}

func mapVariantStatus(status string) string {
	switch status {
	case "ready":
		return "ready"
	case "failed":
		return "failed"
	case "processing":
		return "processing"
	default:
		return "queued"
	}
}

type Share struct {
	ID          uuid.UUID   `json:"id"`
	SubjectType string      `json:"subject_type"`
	SubjectID   uuid.UUID   `json:"subject_id"`
	Token       string      `json:"token,omitempty"`
	TokenPrefix string      `json:"token_prefix"`
	Fields      []string    `json:"fields"`
	MediaIDs    []uuid.UUID `json:"media_ids"`
	ExpiresAt   *time.Time  `json:"expires_at"`
	RevokedAt   *time.Time  `json:"revoked_at"`
	Version     int         `json:"version"`
	CreatedAt   time.Time   `json:"created_at"`
}

func (s *Service) Presign(ctx context.Context, ownerID uuid.UUID, key, path string, payload []byte, input PresignInput) (WriteResult[UploadSession], error) {
	if err := validatePresign(input); err != nil {
		return WriteResult[UploadSession]{}, err
	}
	return runWrite[UploadSession](ctx, s.Store, ownerID, key, http.MethodPost, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		organizationID, err := organizationIDTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		id := uuid.New()
		now := time.Now().UTC()
		expires := now.Add(15 * time.Minute)
		kind := mediaKind(input.ContentType)
		objectKey := fmt.Sprintf("%s/media/%s/%s", ownerID, id, safeFileName(input.FileName))
		if _, err := tx.Exec(ctx, `
			INSERT INTO media_upload_session
			(id, owner_id, organization_id, kind, status, object_key, original_filename, mime_type, byte_size, sha256, expires_at)
			VALUES ($1,$2,$3,$4,'pending_upload',$5,$6,$7,$8,$9,$10)
		`, id, ownerID, organizationID, kind, objectKey, input.FileName, input.ContentType, input.SizeBytes, input.SHA256, expires); err != nil {
			return 0, nil, nil, err
		}
		if err := appendEventTx(ctx, tx, ownerID, organizationID, id, "media_upload_session", "MEDIA_UPLOAD_SESSION_CREATED", map[string]any{
			"object_key": objectKey, "kind": kind, "size_bytes": input.SizeBytes, "sha256": input.SHA256,
		}, key); err != nil {
			return 0, nil, nil, err
		}
		result := UploadSession{ID: id, UploadURL: "/v1/media/uploads/" + id.String() + "/content", Method: "PUT", Headers: map[string]string{"Content-Type": input.ContentType}, ObjectKey: objectKey, ExpiresAt: expires, Version: 1, OriginalName: input.FileName, ContentType: input.ContentType, SizeBytes: input.SizeBytes, SHA256: input.SHA256, Kind: kind, OwnerID: ownerID, OrgID: organizationID}
		return http.StatusCreated, result, map[string]string{"ETag": store.FormatETag(result.Version), "Location": "/v1/media/uploads/" + id.String()}, nil
	})
}

func (s *Service) GetUpload(ctx context.Context, ownerID, uploadID uuid.UUID) (UploadSession, error) {
	var result UploadSession
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, owner_id, organization_id, kind, status, object_key, original_filename, mime_type, byte_size, sha256, version, expires_at
		FROM media_upload_session WHERE owner_id=$1 AND id=$2
	`, ownerID, uploadID).Scan(&result.ID, &result.OwnerID, &result.OrgID, &result.Kind, &result.Status, &result.ObjectKey, &result.OriginalName, &result.ContentType, &result.SizeBytes, &result.SHA256, &result.Version, &result.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return UploadSession{}, ErrNotFound
	}
	if err != nil {
		return UploadSession{}, err
	}
	return result, nil
}

func (s *Service) PutUpload(ctx context.Context, ownerID, uploadID uuid.UUID, key, path string, body io.Reader) (WriteResult[objectstore.ObjectInfo], error) {
	if body == nil {
		return WriteResult[objectstore.ObjectInfo]{}, fmt.Errorf("%w: upload body is required", ErrValidation)
	}
	if s.Objects == nil {
		return WriteResult[objectstore.ObjectInfo]{}, errors.New("media object store unavailable")
	}
	upload, err := s.GetUpload(ctx, ownerID, uploadID)
	if err != nil {
		return WriteResult[objectstore.ObjectInfo]{}, err
	}
	temporary, err := os.CreateTemp("", "scolvpet-media-upload-*")
	if err != nil {
		return WriteResult[objectstore.ObjectInfo]{}, fmt.Errorf("create media upload spool: %w", err)
	}
	temporaryName := temporary.Name()
	defer os.Remove(temporaryName)
	defer temporary.Close()
	hasher := sha256.New()
	count, err := io.Copy(io.MultiWriter(temporary, hasher), io.LimitReader(body, upload.SizeBytes+1))
	if err != nil {
		return WriteResult[objectstore.ObjectInfo]{}, fmt.Errorf("spool media upload: %w", err)
	}
	digest := hex.EncodeToString(hasher.Sum(nil))
	requestPayload, err := json.Marshal(map[string]any{"size_bytes": count, "sha256": digest})
	if err != nil {
		return WriteResult[objectstore.ObjectInfo]{}, err
	}
	return runWrite[objectstore.ObjectInfo](ctx, s.Store, ownerID, key, http.MethodPut, path, requestPayload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		if upload.Status != "pending_upload" || upload.ExpiresAt.Before(time.Now().UTC()) {
			return 0, nil, nil, ErrConflict
		}
		if _, err := temporary.Seek(0, io.SeekStart); err != nil {
			return 0, nil, nil, fmt.Errorf("rewind media upload spool: %w", err)
		}
		info, err := s.Objects.Put(ctx, objectstore.PutRequest{
			Key: upload.ObjectKey, Body: temporary, SizeBytes: upload.SizeBytes,
			SHA256: upload.SHA256, ContentType: upload.ContentType, ExpiresAt: upload.ExpiresAt,
		})
		if err != nil {
			return 0, nil, nil, err
		}
		return http.StatusOK, info, map[string]string{"ETag": store.FormatETag(upload.Version)}, nil
	})
}

func (s *Service) Complete(ctx context.Context, ownerID, uploadID uuid.UUID, key, path string, payload []byte, ifMatch string, input CompleteInput, info objectstore.ObjectInfo) (WriteResult[MediaAsset], error) {
	if err := validateComplete(input); err != nil {
		return WriteResult[MediaAsset]{}, err
	}
	expectedVersion, err := store.ParseETag(ifMatch)
	if err != nil {
		return WriteResult[MediaAsset]{}, fmt.Errorf("%w: invalid If-Match", ErrValidation)
	}
	return runWrite[MediaAsset](ctx, s.Store, ownerID, key, http.MethodPost, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		upload, err := getUploadTx(ctx, tx, ownerID, uploadID, true)
		if err != nil {
			return 0, nil, nil, err
		}
		if upload.Version != expectedVersion {
			return 0, nil, nil, &store.VersionError{Current: upload.Version}
		}
		if upload.ExpiresAt.Before(time.Now().UTC()) || upload.Kind == "" || upload.Status != "pending_upload" {
			return 0, nil, nil, ErrConflict
		}
		if input.SizeBytes != upload.SizeBytes || !strings.EqualFold(input.SHA256, upload.SHA256) || info.Key != upload.ObjectKey || info.SizeBytes != upload.SizeBytes || !strings.EqualFold(info.SHA256, upload.SHA256) {
			return 0, nil, nil, objectstore.ErrChecksumMismatch
		}
		organizationID := upload.OrgID
		assetID := uuid.New()
		var createdAt time.Time
		if err := tx.QueryRow(ctx, `
			INSERT INTO media_asset (id, owner_id, organization_id, kind, status, original_object_key, original_filename, mime_type, byte_size, sha256, captured_at, created_by, updated_by)
			VALUES ($1,$2,$3,$4,'ready',$5,$6,$7,$8,$9,$10,$2,$2)
			RETURNING created_at
		`, assetID, ownerID, organizationID, upload.Kind, upload.ObjectKey, upload.OriginalName, upload.ContentType, upload.SizeBytes, upload.SHA256, input.CapturedAt).Scan(&createdAt); err != nil {
			return 0, nil, nil, err
		}
		processingJobID, variantID := uuid.New(), uuid.New()
		variantKind, variantKey := "preview", "preview"
		if upload.Kind == "video" {
			variantKind, variantKey = "video_transcode", "original"
		}
		processingPayload, _ := json.Marshal(map[string]any{
			"source_media_id": assetID, "variant_kind": variantKind, "variant_key": variantKey,
		})
		if _, err := tx.Exec(ctx, `
			INSERT INTO async_job (id, owner_id, organization_id, job_type, status, request_payload, idempotency_key, created_by)
			VALUES ($1,$2,$3,'media_transform','queued',$4,$5,$2)
		`, processingJobID, ownerID, organizationID, processingPayload, "media-upload-"+assetID.String()); err != nil {
			return 0, nil, nil, err
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO media_variant (id, owner_id, media_asset_id, async_job_id, variant_kind, variant_key, status, edit_recipe)
			VALUES ($1,$2,$3,$4,$5,$6,'queued',$7)
		`, variantID, ownerID, assetID, processingJobID, variantKind, variantKey, processingPayload); err != nil {
			return 0, nil, nil, err
		}
		if _, err := tx.Exec(ctx, `UPDATE media_upload_session SET status='uploaded', version=version+1, updated_at=now() WHERE owner_id=$1 AND id=$2 AND version=$3`, ownerID, uploadID, expectedVersion); err != nil {
			return 0, nil, nil, err
		}
		if err := appendEventTx(ctx, tx, ownerID, organizationID, assetID, "media_asset", "MEDIA_UPLOAD_COMPLETED", map[string]any{
			"upload_session_id": uploadID, "object_key": upload.ObjectKey, "kind": upload.Kind, "size_bytes": upload.SizeBytes, "sha256": upload.SHA256,
			"processing_job_id": processingJobID, "variant_id": variantID,
		}, key); err != nil {
			return 0, nil, nil, err
		}
		asset := MediaAsset{ID: assetID, Kind: upload.Kind, Status: "ready", ObjectKey: upload.ObjectKey, FileName: upload.OriginalName, MimeType: upload.ContentType, SizeBytes: upload.SizeBytes, SHA256: upload.SHA256, Version: 1, CreatedAt: createdAt}
		return http.StatusAccepted, asset, map[string]string{"ETag": store.FormatETag(asset.Version), "Location": "/v1/media/" + asset.ID.String()}, nil
	})
}

func (s *Service) GetMedia(ctx context.Context, ownerID, mediaID uuid.UUID) (MediaAsset, error) {
	var asset MediaAsset
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, kind, status, original_object_key, original_filename, mime_type, byte_size, sha256, version, created_at
		FROM media_asset WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, mediaID).Scan(&asset.ID, &asset.Kind, &asset.Status, &asset.ObjectKey, &asset.FileName, &asset.MimeType, &asset.SizeBytes, &asset.SHA256, &asset.Version, &asset.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return MediaAsset{}, ErrNotFound
	}
	return asset, err
}

func (s *Service) GetMediaView(ctx context.Context, ownerID, mediaID uuid.UUID) (MediaView, error) {
	var view MediaView
	var kind, status string
	err := s.Store.Pool.QueryRow(ctx, `
		SELECT id, owner_id, kind::text, status::text, mime_type, byte_size, sha256, version, created_at, updated_at
		FROM media_asset WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
	`, ownerID, mediaID).Scan(
		&view.ID, &view.OwnerID, &kind, &status, &view.ContentType, &view.SizeBytes, &view.SHA256,
		&view.Version, &view.CreatedAt, &view.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return MediaView{}, ErrNotFound
	}
	if err != nil {
		return MediaView{}, err
	}
	view.MediaType = mapMediaType(kind)
	view.Status = mapMediaStatus(status)
	if view.Status == "ready" {
		url := privateMediaContentPath(mediaID, nil)
		view.OriginalURL = &url
	}
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT id, variant_kind::text, status::text, width_px, height_px, duration_ms, object_key
		FROM media_variant
		WHERE owner_id=$1 AND media_asset_id=$2 AND deleted_at IS NULL
		ORDER BY created_at ASC, id ASC
	`, ownerID, mediaID)
	if err != nil {
		return MediaView{}, err
	}
	defer rows.Close()
	view.Variants = make([]MediaVariantView, 0)
	for rows.Next() {
		var item MediaVariantView
		var variantKind, variantStatus string
		var width, height *int
		var durationMS *int64
		var objectKey *string
		if err := rows.Scan(&item.ID, &variantKind, &variantStatus, &width, &height, &durationMS, &objectKey); err != nil {
			return MediaView{}, err
		}
		item.Kind = mapVariantKind(variantKind)
		item.Status = mapVariantStatus(variantStatus)
		item.Width = width
		item.Height = height
		if durationMS != nil {
			seconds := float64(*durationMS) / 1000
			item.DurationSeconds = &seconds
		}
		if item.Status == "ready" && objectKey != nil && strings.TrimSpace(*objectKey) != "" {
			vid := item.ID
			url := privateMediaContentPath(mediaID, &vid)
			item.URL = &url
		}
		view.Variants = append(view.Variants, item)
	}
	if err := rows.Err(); err != nil {
		return MediaView{}, err
	}
	return view, nil
}

func (s *Service) OpenMediaContent(ctx context.Context, ownerID, mediaID uuid.UUID, variantID *uuid.UUID) (io.ReadCloser, objectstore.ObjectInfo, string, error) {
	if s.Objects == nil {
		return nil, objectstore.ObjectInfo{}, "", errors.New("media object store unavailable")
	}
	var objectKey, contentType string
	if variantID != nil && *variantID != uuid.Nil {
		err := s.Store.Pool.QueryRow(ctx, `
			SELECT v.object_key, COALESCE(v.mime_type, a.mime_type)
			FROM media_variant v
			JOIN media_asset a ON a.owner_id=v.owner_id AND a.id=v.media_asset_id AND a.deleted_at IS NULL
			WHERE v.owner_id=$1 AND v.media_asset_id=$2 AND v.id=$3 AND v.deleted_at IS NULL
				AND v.status='ready' AND v.object_key IS NOT NULL
		`, ownerID, mediaID, *variantID).Scan(&objectKey, &contentType)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, objectstore.ObjectInfo{}, "", ErrNotFound
		}
		if err != nil {
			return nil, objectstore.ObjectInfo{}, "", err
		}
	} else {
		err := s.Store.Pool.QueryRow(ctx, `
			SELECT original_object_key, mime_type
			FROM media_asset
			WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL AND status='ready'
		`, ownerID, mediaID).Scan(&objectKey, &contentType)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, objectstore.ObjectInfo{}, "", ErrNotFound
		}
		if err != nil {
			return nil, objectstore.ObjectInfo{}, "", err
		}
	}
	if strings.TrimSpace(objectKey) == "" {
		return nil, objectstore.ObjectInfo{}, "", ErrNotFound
	}
	reader, info, err := s.Objects.Get(ctx, objectKey)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil, objectstore.ObjectInfo{}, "", ErrNotFound
		}
		return nil, objectstore.ObjectInfo{}, "", err
	}
	return reader, info, contentType, nil
}

func (s *Service) CreateEditRecipe(ctx context.Context, ownerID, mediaID uuid.UUID, key, path string, payload []byte, ifMatch string, input EditRecipeInput) (WriteResult[map[string]any], error) {
	if len(input.Operations) == 0 || (input.OutputFormat != "" && input.OutputFormat != "jpeg" && input.OutputFormat != "png" && input.OutputFormat != "webp") {
		return WriteResult[map[string]any]{}, ErrValidation
	}
	expectedVersion, err := store.ParseETag(ifMatch)
	if err != nil {
		return WriteResult[map[string]any]{}, fmt.Errorf("%w: invalid If-Match", ErrValidation)
	}
	return runWrite[map[string]any](ctx, s.Store, ownerID, key, http.MethodPost, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		asset, err := getMediaTx(ctx, tx, ownerID, mediaID, true)
		if err != nil {
			return 0, nil, nil, err
		}
		if asset.Version != expectedVersion {
			return 0, nil, nil, &store.VersionError{Current: asset.Version}
		}
		if asset.Kind != "image" || asset.Status != "ready" {
			return 0, nil, nil, ErrValidation
		}
		organizationID, err := organizationIDTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		jobID, recipeID := uuid.New(), uuid.New()
		recipe, _ := json.Marshal(map[string]any{"operations": input.Operations, "output_format": input.OutputFormat})
		if _, err := tx.Exec(ctx, `INSERT INTO async_job (id, owner_id, organization_id, job_type, status, request_payload, idempotency_key, created_by) VALUES ($1,$2,$3,'media_transform','queued',$4,$5,$2)`, jobID, ownerID, organizationID, recipe, key); err != nil {
			return 0, nil, nil, err
		}
		if _, err := tx.Exec(ctx, `INSERT INTO media_variant (id, owner_id, media_asset_id, async_job_id, variant_kind, variant_key, status, edit_recipe) VALUES ($1,$2,$3,$4,'image_edit',$5,'queued',$6)`, recipeID, ownerID, mediaID, jobID, "recipe-"+recipeID.String(), recipe); err != nil {
			return 0, nil, nil, err
		}
		updatedAsset, err := bumpMediaVersionTx(ctx, tx, ownerID, mediaID, expectedVersion)
		if err != nil {
			return 0, nil, nil, err
		}
		if err := appendEventTx(ctx, tx, ownerID, organizationID, mediaID, "media_asset", "MEDIA_EDIT_RECIPE_CREATED", map[string]any{"recipe_id": recipeID, "job_id": jobID}, key); err != nil {
			return 0, nil, nil, err
		}
		result := map[string]any{"source_media_id": mediaID, "recipe_id": recipeID, "job": ProcessingJob{ID: jobID, Status: "queued", JobType: "media_transform", Version: 1}}
		return http.StatusAccepted, result, map[string]string{"ETag": store.FormatETag(updatedAsset.Version), "Location": "/v1/media/" + mediaID.String() + "/transcode-status"}, nil
	})
}

func (s *Service) ProcessingStatus(ctx context.Context, ownerID, mediaID uuid.UUID) (ProcessingJob, error) {
	var job ProcessingJob
	err := s.Store.Pool.QueryRow(ctx, `SELECT j.id, j.status::text, j.job_type::text, j.progress_percent::float8, j.version FROM media_variant v JOIN async_job j ON j.owner_id=v.owner_id AND j.id=v.async_job_id WHERE v.owner_id=$1 AND v.media_asset_id=$2 AND v.deleted_at IS NULL ORDER BY j.created_at DESC LIMIT 1`, ownerID, mediaID).Scan(&job.ID, &job.Status, &job.JobType, &job.ProgressPercent, &job.Version)
	if errors.Is(err, pgx.ErrNoRows) {
		return ProcessingJob{}, ErrNotFound
	}
	return job, err
}

func (s *Service) RetryProcessing(ctx context.Context, ownerID, mediaID uuid.UUID, key, path string, payload []byte, ifMatch string, input RetryProcessingInput) (WriteResult[map[string]any], error) {
	if strings.TrimSpace(input.Reason) == "" || (input.Scope != "failed_variants" && input.Scope != "video_transcode" && input.Scope != "image_derivatives") {
		return WriteResult[map[string]any]{}, ErrValidation
	}
	expectedVersion, err := store.ParseETag(ifMatch)
	if err != nil {
		return WriteResult[map[string]any]{}, fmt.Errorf("%w: invalid If-Match", ErrValidation)
	}
	return runWrite[map[string]any](ctx, s.Store, ownerID, key, http.MethodPost, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		asset, err := getMediaTx(ctx, tx, ownerID, mediaID, true)
		if err != nil {
			return 0, nil, nil, err
		}
		if asset.Version != expectedVersion {
			return 0, nil, nil, &store.VersionError{Current: asset.Version}
		}
		organizationID, err := organizationIDTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		jobID := uuid.New()
		jobPayload, _ := json.Marshal(map[string]any{"scope": input.Scope, "reason": input.Reason, "variant_ids": input.VariantIDs})
		if _, err := tx.Exec(ctx, `INSERT INTO async_job (id, owner_id, organization_id, job_type, status, request_payload, idempotency_key, created_by) VALUES ($1,$2,$3,'media_transform','queued',$4,$5,$2)`, jobID, ownerID, organizationID, jobPayload, key); err != nil {
			return 0, nil, nil, err
		}
		query := `UPDATE media_variant SET status='queued', async_job_id=$3, failure_code=NULL, failure_detail=NULL, version=version+1, updated_at=now() WHERE owner_id=$1 AND media_asset_id=$2 AND status='failed' AND deleted_at IS NULL`
		args := []any{ownerID, mediaID, jobID}
		if len(input.VariantIDs) > 0 {
			query += ` AND id = ANY($4)`
			args = append(args, input.VariantIDs)
		}
		command, err := tx.Exec(ctx, query, args...)
		if err != nil {
			return 0, nil, nil, err
		}
		if command.RowsAffected() == 0 {
			return 0, nil, nil, ErrConflict
		}
		updatedAsset, err := bumpMediaVersionTx(ctx, tx, ownerID, mediaID, expectedVersion)
		if err != nil {
			return 0, nil, nil, err
		}
		if err := appendEventTx(ctx, tx, ownerID, organizationID, mediaID, "media_asset", "MEDIA_PROCESSING_RETRIED", map[string]any{"job_id": jobID, "scope": input.Scope, "variant_ids": input.VariantIDs, "reason": input.Reason}, key); err != nil {
			return 0, nil, nil, err
		}
		result := map[string]any{"media": updatedAsset, "job": ProcessingJob{ID: jobID, Status: "queued", JobType: "media_transform", Version: 1}}
		return http.StatusAccepted, result, map[string]string{"ETag": store.FormatETag(updatedAsset.Version), "Location": "/v1/media/" + mediaID.String() + "/transcode-status"}, nil
	})
}

func (s *Service) SetCover(ctx context.Context, ownerID, mediaID uuid.UUID, key, path string, payload []byte, ifMatch string, input CoverInput) (WriteResult[MediaAsset], error) {
	if (input.TimeOffsetSeconds == nil && input.MediaVariantID == nil) || (input.TimeOffsetSeconds != nil && input.MediaVariantID != nil) || (input.TimeOffsetSeconds != nil && *input.TimeOffsetSeconds < 0) {
		return WriteResult[MediaAsset]{}, ErrValidation
	}
	expectedVersion, err := store.ParseETag(ifMatch)
	if err != nil {
		return WriteResult[MediaAsset]{}, fmt.Errorf("%w: invalid If-Match", ErrValidation)
	}
	return runWrite[MediaAsset](ctx, s.Store, ownerID, key, http.MethodPut, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		asset, err := getMediaTx(ctx, tx, ownerID, mediaID, true)
		if err != nil {
			return 0, nil, nil, err
		}
		if asset.Version != expectedVersion {
			return 0, nil, nil, &store.VersionError{Current: asset.Version}
		}
		organizationID, err := organizationIDTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		if input.MediaVariantID != nil {
			var exists bool
			if err := tx.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM media_variant WHERE owner_id=$1 AND media_asset_id=$2 AND id=$3 AND deleted_at IS NULL)`, ownerID, mediaID, *input.MediaVariantID).Scan(&exists); err != nil {
				return 0, nil, nil, err
			}
			if !exists {
				return 0, nil, nil, ErrNotFound
			}
			_, err = tx.Exec(ctx, `UPDATE media_asset SET metadata=jsonb_set(metadata,'{cover_variant_id}',to_jsonb($3::text),true), version=version+1, updated_at=now() WHERE owner_id=$1 AND id=$2 AND version=$4`, ownerID, mediaID, input.MediaVariantID.String(), expectedVersion)
		} else {
			_, err = tx.Exec(ctx, `UPDATE media_asset SET metadata=jsonb_set(metadata,'{cover_time_offset_seconds}',to_jsonb($3::float8),true), version=version+1, updated_at=now() WHERE owner_id=$1 AND id=$2 AND version=$4`, ownerID, mediaID, *input.TimeOffsetSeconds, expectedVersion)
		}
		if err != nil {
			return 0, nil, nil, err
		}
		updated, err := getMediaTx(ctx, tx, ownerID, mediaID, false)
		if err != nil {
			return 0, nil, nil, err
		}
		if err := appendEventTx(ctx, tx, ownerID, organizationID, mediaID, "media_asset", "MEDIA_COVER_SET", map[string]any{"media_variant_id": input.MediaVariantID, "time_offset_seconds": input.TimeOffsetSeconds}, key); err != nil {
			return 0, nil, nil, err
		}
		return http.StatusOK, updated, map[string]string{"ETag": store.FormatETag(updated.Version)}, nil
	})
}

func (s *Service) CreateShare(ctx context.Context, ownerID uuid.UUID, key, path string, payload []byte, input ShareInput) (WriteResult[Share], error) {
	if err := validateShareInput(input); err != nil {
		return WriteResult[Share]{}, fmt.Errorf("%w: share subject and fields are required", ErrValidation)
	}
	return runWrite[Share](ctx, s.Store, ownerID, key, http.MethodPost, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		organizationID, err := organizationIDTx(ctx, tx, ownerID)
		if err != nil {
			return 0, nil, nil, err
		}
		for _, mediaID := range input.MediaIDs {
			if _, err := getMediaTx(ctx, tx, ownerID, mediaID, false); err != nil {
				return 0, nil, nil, err
			}
		}
		token := uuid.NewString() + uuid.NewString()
		digest := sha256.Sum256([]byte(token))
		fields, _ := json.Marshal(input.Fields)
		mediaIDs, _ := json.Marshal(input.MediaIDs)
		id := uuid.New()
		var createdAt time.Time
		var version int
		if err := tx.QueryRow(ctx, `
			INSERT INTO share_page (id, owner_id, organization_id, target_type, target_id, token_hash, token_prefix, selected_fields, presentation, expires_at, created_by)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,jsonb_build_object('media_ids',$9::jsonb),$10,$2)
			RETURNING version, created_at
		`, id, ownerID, organizationID, input.SubjectType, input.SubjectID, digest[:], token[:8], fields, string(mediaIDs), input.ExpiresAt).Scan(&version, &createdAt); err != nil {
			return 0, nil, nil, err
		}
		if err := appendEventTx(ctx, tx, ownerID, organizationID, id, "share_page", "SHARE_CREATED", map[string]any{"subject_type": input.SubjectType, "subject_id": input.SubjectID, "media_ids": input.MediaIDs, "fields": input.Fields, "expires_at": input.ExpiresAt}, key); err != nil {
			return 0, nil, nil, err
		}
		share := Share{ID: id, SubjectType: input.SubjectType, SubjectID: input.SubjectID, Token: token, TokenPrefix: token[:8], Fields: input.Fields, MediaIDs: input.MediaIDs, ExpiresAt: input.ExpiresAt, Version: version, CreatedAt: createdAt}
		return http.StatusCreated, share, map[string]string{"ETag": store.FormatETag(share.Version), "Location": "/v1/shares/" + share.ID.String()}, nil
	})
}

func (s *Service) ListShares(ctx context.Context, ownerID uuid.UUID) ([]Share, error) {
	rows, err := s.Store.Pool.Query(ctx, `SELECT id, target_type, target_id, token_prefix, selected_fields, expires_at, revoked_at, version, created_at FROM share_page WHERE owner_id=$1 ORDER BY created_at DESC LIMIT 100`, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	result := make([]Share, 0)
	for rows.Next() {
		var item Share
		var fields []byte
		if err := rows.Scan(&item.ID, &item.SubjectType, &item.SubjectID, &item.TokenPrefix, &fields, &item.ExpiresAt, &item.RevokedAt, &item.Version, &item.CreatedAt); err != nil {
			return nil, err
		}
		_ = json.Unmarshal(fields, &item.Fields)
		result = append(result, item)
	}
	return result, rows.Err()
}

func (s *Service) RevokeShare(ctx context.Context, ownerID, shareID uuid.UUID, key, path string, payload []byte, ifMatch, reason string) (WriteResult[Share], error) {
	if strings.TrimSpace(reason) == "" {
		return WriteResult[Share]{}, fmt.Errorf("%w: revoke reason is required", ErrValidation)
	}
	expectedVersion, err := store.ParseETag(ifMatch)
	if err != nil {
		return WriteResult[Share]{}, fmt.Errorf("%w: invalid If-Match", ErrValidation)
	}
	return runWrite[Share](ctx, s.Store, ownerID, key, http.MethodPost, path, payload, func(ctx context.Context, tx pgx.Tx) (int, any, map[string]string, error) {
		var currentVersion int
		var organizationID uuid.UUID
		var targetType string
		var targetID uuid.UUID
		var tokenPrefix string
		var fields []byte
		var presentation []byte
		var expiresAt, revokedAt *time.Time
		var createdAt time.Time
		if err := tx.QueryRow(ctx, `SELECT organization_id, target_type::text, target_id, token_prefix, selected_fields, presentation, expires_at, revoked_at, version, created_at FROM share_page WHERE owner_id=$1 AND id=$2 FOR UPDATE`, ownerID, shareID).Scan(&organizationID, &targetType, &targetID, &tokenPrefix, &fields, &presentation, &expiresAt, &revokedAt, &currentVersion, &createdAt); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return 0, nil, nil, ErrNotFound
			}
			return 0, nil, nil, err
		}
		if currentVersion != expectedVersion {
			return 0, nil, nil, &store.VersionError{Current: currentVersion}
		}
		if revokedAt != nil {
			return 0, nil, nil, ErrConflict
		}
		now := time.Now().UTC()
		if _, err := tx.Exec(ctx, `UPDATE share_page SET revoked_at=$3, revoked_by=$1, revoke_reason=$4, cache_purge_requested_at=$3, version=version+1, updated_at=now() WHERE owner_id=$1 AND id=$2 AND version=$5`, ownerID, shareID, now, reason, expectedVersion); err != nil {
			return 0, nil, nil, err
		}
		updatedVersion := expectedVersion + 1
		if err := appendEventTx(ctx, tx, ownerID, organizationID, shareID, "share_page", "SHARE_REVOKED", map[string]any{"reason": reason, "cache_purge": true}, key); err != nil {
			return 0, nil, nil, err
		}
		var selected []string
		var display map[string]any
		_ = json.Unmarshal(fields, &selected)
		_ = json.Unmarshal(presentation, &display)
		var mediaIDs []uuid.UUID
		if raw, ok := display["media_ids"]; ok {
			data, _ := json.Marshal(raw)
			_ = json.Unmarshal(data, &mediaIDs)
		}
		share := Share{ID: shareID, SubjectType: targetType, SubjectID: targetID, TokenPrefix: tokenPrefix, Fields: selected, MediaIDs: mediaIDs, ExpiresAt: expiresAt, RevokedAt: &now, Version: updatedVersion, CreatedAt: createdAt}
		return http.StatusOK, share, map[string]string{"ETag": store.FormatETag(share.Version)}, nil
	})
}

func (s *Service) PublicShare(ctx context.Context, token string) (map[string]any, error) {
	digest := sha256.Sum256([]byte(strings.TrimSpace(token)))
	var id, ownerID uuid.UUID
	var targetType string
	var targetID uuid.UUID
	var fields []byte
	var presentation []byte
	var expiresAt *time.Time
	err := s.Store.Pool.QueryRow(ctx, `SELECT id, owner_id, target_type, target_id, selected_fields, presentation, expires_at FROM share_page WHERE token_hash=$1 AND revoked_at IS NULL AND (expires_at IS NULL OR expires_at > now())`, digest[:]).Scan(&id, &ownerID, &targetType, &targetID, &fields, &presentation, &expiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	var selected []string
	_ = json.Unmarshal(fields, &selected)
	mediaIDs := presentationMediaIDs(presentation)
	return s.publicProjection(ctx, ownerID, id, token, targetType, targetID, selected, mediaIDs, expiresAt)
}

func (s *Service) PreviewShareDraft(ctx context.Context, ownerID uuid.UUID, input ShareInput) (map[string]any, error) {
	if err := validateShareInput(input); err != nil {
		return nil, ErrValidation
	}
	return s.publicProjection(ctx, ownerID, uuid.Nil, "", input.SubjectType, input.SubjectID, input.Fields, input.MediaIDs, nil)
}

func (s *Service) PreviewShare(ctx context.Context, ownerID, shareID uuid.UUID) (map[string]any, error) {
	var targetType string
	var targetID uuid.UUID
	var fields, presentation []byte
	err := s.Store.Pool.QueryRow(ctx, `SELECT target_type, target_id, selected_fields, presentation FROM share_page WHERE owner_id=$1 AND id=$2`, ownerID, shareID).Scan(&targetType, &targetID, &fields, &presentation)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	var selected []string
	_ = json.Unmarshal(fields, &selected)
	return s.publicProjection(ctx, ownerID, shareID, "", targetType, targetID, selected, presentationMediaIDs(presentation), nil)
}

func (s *Service) publicProjection(ctx context.Context, ownerID, shareID uuid.UUID, token, subjectType string, subjectID uuid.UUID, fields []string, mediaIDs []uuid.UUID, expiresAt *time.Time) (map[string]any, error) {
	display, err := s.projectSubject(ctx, ownerID, subjectType, subjectID, fields)
	if err != nil {
		return nil, err
	}
	media, err := s.projectMedia(ctx, ownerID, token, mediaIDs)
	if err != nil {
		return nil, err
	}
	display["subject_id"] = subjectID.String()
	return map[string]any{"share_id": shareID, "subject_type": subjectType, "display": display, "media": media, "fields": fields, "expires_at": expiresAt}, nil
}

func (s *Service) projectSubject(ctx context.Context, ownerID uuid.UUID, subjectType string, subjectID uuid.UUID, fields []string) (map[string]any, error) {
	display := map[string]any{"subject_id": subjectID.String()}
	switch subjectType {
	case "hamster":
		var name, variety *string
		var sex string
		var birthDate *time.Time
		if err := s.Store.Pool.QueryRow(ctx, `SELECT name, variety_code, sex::text, birth_date FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, subjectID).Scan(&name, &variety, &sex, &birthDate); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return nil, ErrNotFound
			}
			return nil, err
		}
		for _, field := range fields {
			switch field {
			case "name":
				display[field] = nullableStringValue(name)
			case "sex":
				display[field] = sex
			case "birth_date":
				if birthDate == nil {
					display[field] = nil
				} else {
					display[field] = birthDate.Format("2006-01-02")
				}
			case "variety":
				display[field] = nullableStringValue(variety)
			case "parents":
				parents, err := s.hamsterParents(ctx, ownerID, subjectID)
				if err != nil {
					return nil, err
				}
				display[field] = parents
			case "pedigree_summary":
				var count int
				if err := s.Store.Pool.QueryRow(ctx, `SELECT count(*) FROM pedigree_parentage WHERE owner_id=$1 AND child_id=$2 AND status='accepted' AND valid_to IS NULL`, ownerID, subjectID).Scan(&count); err != nil {
					return nil, err
				}
				display[field] = map[string]any{"parent_count": count}
			case "cover":
				display[field] = nil
			}
		}
	case "litter":
		var code string
		var bornAt *time.Time
		if err := s.Store.Pool.QueryRow(ctx, `SELECT code, born_at FROM litter WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`, ownerID, subjectID).Scan(&code, &bornAt); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return nil, ErrNotFound
			}
			return nil, err
		}
		for _, field := range fields {
			switch field {
			case "litter_code":
				display[field] = code
			case "born_at":
				display[field] = bornAt
			case "parents":
				parents, err := s.litterParents(ctx, ownerID, subjectID)
				if err != nil {
					return nil, err
				}
				display[field] = parents
			case "member_count":
				var count int
				if err := s.Store.Pool.QueryRow(ctx, `SELECT count(*) FROM litter_member WHERE owner_id=$1 AND litter_id=$2 AND status='accepted' AND valid_to IS NULL`, ownerID, subjectID).Scan(&count); err != nil {
					return nil, err
				}
				display[field] = count
			case "pedigree_summary", "name", "sex", "birth_date", "variety", "cover":
				display[field] = nil
			}
		}
	default:
		return nil, ErrValidation
	}
	return display, nil
}

func (s *Service) projectMedia(ctx context.Context, ownerID uuid.UUID, token string, mediaIDs []uuid.UUID) ([]any, error) {
	media := make([]any, 0, len(mediaIDs))
	for _, mediaID := range mediaIDs {
		var id uuid.UUID
		var assetKind, assetStatus, variantKind, variantStatus, objectKey, contentType string
		var width, height *int
		var durationMS *int64
		var size int64
		if err := s.Store.Pool.QueryRow(ctx, `
			SELECT COALESCE(v.id,a.id), a.kind::text, a.status::text,
				COALESCE(v.variant_kind::text,'preview'), COALESCE(v.status::text,a.status::text),
				COALESCE(v.object_key,a.original_object_key), COALESCE(v.mime_type,a.mime_type),
				COALESCE(v.byte_size,a.byte_size), v.width_px, v.height_px, v.duration_ms
			FROM media_asset a
			LEFT JOIN LATERAL (
				SELECT id, variant_kind, status, object_key, mime_type, byte_size, width_px, height_px, duration_ms, created_at
				FROM media_variant
				WHERE owner_id=a.owner_id AND media_asset_id=a.id AND deleted_at IS NULL
				ORDER BY CASE WHEN status='ready' THEN 0 ELSE 1 END, created_at DESC, id DESC
				LIMIT 1
			) v ON true
			WHERE a.owner_id=$1 AND a.id=$2 AND a.deleted_at IS NULL
		`, ownerID, mediaID).Scan(&id, &assetKind, &assetStatus, &variantKind, &variantStatus, &objectKey, &contentType, &size, &width, &height, &durationMS); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return nil, ErrNotFound
			}
			return nil, err
		}
		status := variantStatus
		if status == "" {
			status = assetStatus
		}
		item := map[string]any{
			"id": id, "kind": publicMediaKind(assetKind, variantKind), "status": status,
			"url": nil, "width": width, "height": height,
		}
		if durationMS != nil {
			item["duration_seconds"] = float64(*durationMS) / 1000
		} else {
			item["duration_seconds"] = nil
		}
		if token != "" && status == "ready" && objectKey != "" {
			item["url"] = "/v1/public/shares/" + url.PathEscape(token) + "/media/" + mediaID.String()
		}
		_ = contentType
		_ = size
		media = append(media, item)
	}
	return media, nil
}

func (s *Service) PublicMedia(ctx context.Context, token string, mediaID uuid.UUID) (io.ReadCloser, objectstore.ObjectInfo, string, error) {
	if s.Objects == nil {
		return nil, objectstore.ObjectInfo{}, "", errors.New("media object store unavailable")
	}
	digest := sha256.Sum256([]byte(strings.TrimSpace(token)))
	var ownerID uuid.UUID
	var presentation []byte
	if err := s.Store.Pool.QueryRow(ctx, `SELECT owner_id, presentation FROM share_page WHERE token_hash=$1 AND revoked_at IS NULL AND (expires_at IS NULL OR expires_at > now())`, digest[:]).Scan(&ownerID, &presentation); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, objectstore.ObjectInfo{}, "", ErrNotFound
		}
		return nil, objectstore.ObjectInfo{}, "", err
	}
	allowed := false
	for _, allowedID := range presentationMediaIDs(presentation) {
		if allowedID == mediaID {
			allowed = true
			break
		}
	}
	if !allowed {
		return nil, objectstore.ObjectInfo{}, "", ErrNotFound
	}
	var objectKey, contentType string
	if err := s.Store.Pool.QueryRow(ctx, `
		SELECT COALESCE(v.object_key,a.original_object_key), COALESCE(v.mime_type,a.mime_type)
		FROM media_asset a
		LEFT JOIN LATERAL (
			SELECT object_key, mime_type
			FROM media_variant
			WHERE owner_id=a.owner_id AND media_asset_id=a.id AND deleted_at IS NULL
			ORDER BY CASE WHEN status='ready' THEN 0 ELSE 1 END, created_at DESC, id DESC
			LIMIT 1
		) v ON true
		WHERE a.owner_id=$1 AND a.id=$2 AND a.deleted_at IS NULL
	`, ownerID, mediaID).Scan(&objectKey, &contentType); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, objectstore.ObjectInfo{}, "", ErrNotFound
		}
		return nil, objectstore.ObjectInfo{}, "", err
	}
	reader, info, err := s.Objects.Get(ctx, objectKey)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil, objectstore.ObjectInfo{}, "", ErrNotFound
		}
		return nil, objectstore.ObjectInfo{}, "", err
	}
	return reader, info, contentType, nil
}

func validateShareInput(input ShareInput) error {
	if input.SubjectID == uuid.Nil || (input.SubjectType != "hamster" && input.SubjectType != "litter") || len(input.Fields) == 0 {
		return ErrValidation
	}
	for _, field := range input.Fields {
		switch field {
		case "name", "cover", "sex", "birth_date", "variety", "pedigree_summary", "litter_code", "born_at", "parents", "member_count":
		default:
			return ErrValidation
		}
	}
	return nil
}

func presentationMediaIDs(presentation []byte) []uuid.UUID {
	var display map[string]any
	if json.Unmarshal(presentation, &display) != nil {
		return nil
	}
	raw, ok := display["media_ids"]
	if !ok {
		return nil
	}
	data, _ := json.Marshal(raw)
	var ids []uuid.UUID
	_ = json.Unmarshal(data, &ids)
	return ids
}

func nullableStringValue(value *string) any {
	if value == nil {
		return nil
	}
	return *value
}

func (s *Service) hamsterParents(ctx context.Context, ownerID, hamsterID uuid.UUID) ([]any, error) {
	rows, err := s.Store.Pool.Query(ctx, `SELECT role::text, parent_id FROM pedigree_parentage WHERE owner_id=$1 AND child_id=$2 AND status='accepted' AND valid_to IS NULL ORDER BY role`, ownerID, hamsterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	parents := make([]any, 0)
	for rows.Next() {
		var role string
		var parentID uuid.UUID
		if err := rows.Scan(&role, &parentID); err != nil {
			return nil, err
		}
		parents = append(parents, map[string]any{"role": role, "hamster_id": parentID})
	}
	return parents, rows.Err()
}

func (s *Service) litterParents(ctx context.Context, ownerID, litterID uuid.UUID) ([]any, error) {
	rows, err := s.Store.Pool.Query(ctx, `SELECT role::text, parent_id FROM litter_parent WHERE owner_id=$1 AND litter_id=$2 AND status='accepted' AND valid_to IS NULL ORDER BY role`, ownerID, litterID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	parents := make([]any, 0)
	for rows.Next() {
		var role string
		var parentID uuid.UUID
		if err := rows.Scan(&role, &parentID); err != nil {
			return nil, err
		}
		parents = append(parents, map[string]any{"role": role, "hamster_id": parentID})
	}
	return parents, rows.Err()
}

func publicMediaKind(assetKind, variantKind string) string {
	switch variantKind {
	case "image_edit":
		return "edited"
	case "video_transcode":
		return "video_720p"
	case "thumbnail", "preview", "video_cover", "share_render":
		return variantKind
	default:
		if assetKind == "video" {
			return "video_720p"
		}
		return "preview"
	}
}

type rowScanner interface {
	Scan(...any) error
}

func organizationIDTx(ctx context.Context, tx pgx.Tx, ownerID uuid.UUID) (uuid.UUID, error) {
	var id uuid.UUID
	err := tx.QueryRow(ctx, `SELECT id FROM organization WHERE owner_id=$1 AND deleted_at IS NULL ORDER BY created_at LIMIT 1`, ownerID).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return uuid.Nil, ErrNotFound
	}
	return id, err
}

func getUploadTx(ctx context.Context, tx pgx.Tx, ownerID, uploadID uuid.UUID, forUpdate bool) (UploadSession, error) {
	query := `SELECT id, owner_id, organization_id, kind::text, status::text, object_key, original_filename, mime_type, byte_size, sha256, version, expires_at FROM media_upload_session WHERE owner_id=$1 AND id=$2`
	if forUpdate {
		query += " FOR UPDATE"
	}
	var result UploadSession
	err := tx.QueryRow(ctx, query, ownerID, uploadID).Scan(&result.ID, &result.OwnerID, &result.OrgID, &result.Kind, &result.Status, &result.ObjectKey, &result.OriginalName, &result.ContentType, &result.SizeBytes, &result.SHA256, &result.Version, &result.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return UploadSession{}, ErrNotFound
	}
	if err != nil {
		return UploadSession{}, err
	}
	result.UploadURL = "/v1/media/uploads/" + result.ID.String() + "/content"
	result.Method = http.MethodPut
	result.Headers = map[string]string{"Content-Type": result.ContentType}
	return result, nil
}

func getMediaTx(ctx context.Context, tx pgx.Tx, ownerID, mediaID uuid.UUID, forUpdate bool) (MediaAsset, error) {
	query := `SELECT id, kind::text, status::text, original_object_key, original_filename, mime_type, byte_size, sha256, version, created_at FROM media_asset WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL`
	if forUpdate {
		query += " FOR UPDATE"
	}
	var asset MediaAsset
	err := tx.QueryRow(ctx, query, ownerID, mediaID).Scan(&asset.ID, &asset.Kind, &asset.Status, &asset.ObjectKey, &asset.FileName, &asset.MimeType, &asset.SizeBytes, &asset.SHA256, &asset.Version, &asset.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return MediaAsset{}, ErrNotFound
	}
	return asset, err
}

func bumpMediaVersionTx(ctx context.Context, tx pgx.Tx, ownerID, mediaID uuid.UUID, expectedVersion int) (MediaAsset, error) {
	if _, err := tx.Exec(ctx, `UPDATE media_asset SET version=version+1, updated_at=now(), updated_by=$1 WHERE owner_id=$1 AND id=$2 AND version=$3 AND deleted_at IS NULL`, ownerID, mediaID, expectedVersion); err != nil {
		return MediaAsset{}, err
	}
	return getMediaTx(ctx, tx, ownerID, mediaID, false)
}

func appendEventTx(ctx context.Context, tx pgx.Tx, ownerID, organizationID, aggregateID uuid.UUID, aggregateType, eventType string, payload map[string]any, idempotencyKey string) error {
	var version int
	if err := tx.QueryRow(ctx, `SELECT COALESCE(max(event_version),0)+1 FROM domain_event WHERE owner_id=$1 AND aggregate_type=$2 AND aggregate_id=$3`, ownerID, aggregateType, aggregateID).Scan(&version); err != nil {
		return err
	}
	var eventID uuid.UUID
	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	if err := tx.QueryRow(ctx, `INSERT INTO domain_event (owner_id, organization_id, aggregate_type, aggregate_id, event_type, event_version, actor_id, occurred_at, payload, idempotency_key) VALUES ($1,$2,$3,$4,$5,$6,$1,now(),$7,$8) RETURNING id`, ownerID, organizationID, aggregateType, aggregateID, eventType, version, data, idempotencyKey).Scan(&eventID); err != nil {
		return err
	}
	outboxPayload, err := json.Marshal(map[string]any{"event_id": eventID, "event_type": eventType, "aggregate_type": aggregateType, "aggregate_id": aggregateID, "payload": payload})
	if err != nil {
		return err
	}
	_, err = tx.Exec(ctx, `INSERT INTO outbox_message (owner_id, domain_event_id, topic, partition_key, payload) VALUES ($1,$2,$3,$4,$5)`, ownerID, eventID, "domain."+strings.ToLower(aggregateType), aggregateID.String(), outboxPayload)
	return err
}

func validateComplete(input CompleteInput) error {
	if strings.TrimSpace(input.ObjectETag) == "" || input.SizeBytes < 1 || len(input.SHA256) != 64 || !isHexSHA256(input.SHA256) {
		return fmt.Errorf("%w: invalid completion metadata", ErrValidation)
	}
	return nil
}

func validatePresign(input PresignInput) error {
	if strings.TrimSpace(input.FileName) == "" || input.SizeBytes < 1 || len(input.SHA256) != 64 || !isHexSHA256(input.SHA256) {
		return fmt.Errorf("%w: invalid upload metadata", ErrValidation)
	}
	if !strings.HasPrefix(input.ContentType, "image/") && !strings.HasPrefix(input.ContentType, "video/") {
		return fmt.Errorf("%w: unsupported content type", ErrValidation)
	}
	return nil
}

func isHexSHA256(value string) bool {
	for _, ch := range value {
		if !(ch >= '0' && ch <= '9') && !(ch >= 'a' && ch <= 'f') && !(ch >= 'A' && ch <= 'F') {
			return false
		}
	}
	return true
}

func mediaKind(contentType string) string {
	if strings.HasPrefix(contentType, "video/") {
		return "video"
	}
	return "image"
}
func safeFileName(name string) string {
	name = strings.NewReplacer("/", "_", "\\", "_").Replace(strings.TrimSpace(name))
	if name == "" {
		return "upload.bin"
	}
	return name
}
