package worker

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"image"
	"image/color"
	_ "image/gif"
	"image/jpeg"
	"image/png"
	"io"
	"log/slog"
	"math"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/objectstore"
)

// MediaProcessor claims media_transform async jobs and materializes their
// variants. It deliberately stays behind ObjectStore so local and S3-backed
// deployments use the same processing state machine.
//
// Original media objects are never rewritten: derivatives are always written
// under a distinct variant object key. WebP encoding and video transcoding are
// injected via WebPEncoder / VideoTranscoder so tests can use fakes.
type MediaProcessor struct {
	Pool            *pgxpool.Pool
	Objects         objectstore.ObjectStore
	Logger          *slog.Logger
	ID              string
	LeaseDuration   time.Duration
	WebPEncoder     WebPEncoder
	VideoTranscoder VideoTranscoder
}

type mediaJob struct {
	ID             uuid.UUID
	OwnerID        uuid.UUID
	RequestPayload []byte
	AttemptCount   int
	MaxAttempts    int
}

type mediaVariantWork struct {
	ID             uuid.UUID
	OwnerID        uuid.UUID
	MediaAssetID   uuid.UUID
	VariantKind    string
	VariantKey     string
	EditRecipe     []byte
	OriginalKey    string
	OriginalSHA256 string
	OriginalMime   string
	OriginalSize   int64
}

type derivedMedia struct {
	Body        []byte
	ContentType string
	Width       int
	Height      int
	DurationMS  int64
	Codec       string
}

type mediaRecipe struct {
	Operations   []map[string]any `json:"operations"`
	OutputFormat string           `json:"output_format"`
}

func NewMediaProcessor(pool *pgxpool.Pool, objects objectstore.ObjectStore, logger *slog.Logger) *MediaProcessor {
	codec := NewExternalCodec(DefaultCodecConfig())
	return &MediaProcessor{
		Pool:            pool,
		Objects:         objects,
		Logger:          logger,
		ID:              "media-worker-" + uuid.NewString(),
		LeaseDuration:   time.Minute,
		WebPEncoder:     codec,
		VideoTranscoder: codec,
	}
}

// NewMediaProcessorWithCodec injects codec tools and optional object store for
// production wiring where paths/timeouts come from runtime configuration.
func NewMediaProcessorWithCodec(pool *pgxpool.Pool, objects objectstore.ObjectStore, logger *slog.Logger, codec *ExternalCodec) *MediaProcessor {
	processor := NewMediaProcessor(pool, objects, logger)
	if codec != nil {
		processor.WebPEncoder = codec
		processor.VideoTranscoder = codec
	}
	return processor
}

func (w *MediaProcessor) Run(ctx context.Context, interval time.Duration) {
	if interval < time.Millisecond {
		interval = time.Second
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := w.RunOnce(ctx); err != nil && w.Logger != nil {
				w.Logger.Error("media worker cycle failed", "error", err)
			}
		}
	}
}

func (w *MediaProcessor) RunOnce(ctx context.Context) error {
	if w.Pool == nil {
		return errors.New("media worker database pool is nil")
	}
	if w.Objects == nil {
		return errors.New("media worker object store is nil")
	}
	if err := w.recoverStale(ctx); err != nil {
		return err
	}
	job, err := w.claim(ctx)
	if err != nil || job == nil {
		return err
	}
	result, err := w.process(ctx, *job)
	if err != nil {
		if failErr := w.fail(ctx, *job, err); failErr != nil {
			return fmt.Errorf("media job failed: %w; recording failure failed: %v", err, failErr)
		}
		return err
	}
	return w.finish(ctx, *job, result)
}

func (w *MediaProcessor) recoverStale(ctx context.Context) error {
	seconds := int64(w.LeaseDuration / time.Second)
	if seconds < 1 {
		seconds = 1
	}
	_, err := w.Pool.Exec(ctx, `
		UPDATE async_job
		SET status='failed', available_at=now(), locked_at=NULL, locked_by=NULL,
			error_code='MEDIA_STALE_LEASE', error_detail='stale media worker lease reclaimed', updated_at=now()
		WHERE job_type='media_transform' AND status='running'
		  AND locked_at IS NOT NULL AND locked_at <= now() - make_interval(secs => $1)
	`, seconds)
	return err
}

func (w *MediaProcessor) claim(ctx context.Context) (*mediaJob, error) {
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	job := &mediaJob{}
	err = tx.QueryRow(ctx, `
		SELECT id, owner_id, request_payload, attempt_count, max_attempts
		FROM async_job
		WHERE job_type='media_transform'
		  AND status IN ('queued','failed')
		  AND available_at <= now()
		  AND attempt_count < max_attempts
		ORDER BY priority, created_at
		FOR UPDATE SKIP LOCKED
		LIMIT 1
	`).Scan(&job.ID, &job.OwnerID, &job.RequestPayload, &job.AttemptCount, &job.MaxAttempts)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	job.AttemptCount++
	if _, err := tx.Exec(ctx, `
		UPDATE async_job
		SET status='running', attempt_count=$2, started_at=COALESCE(started_at,now()),
			finished_at=NULL, locked_at=now(), locked_by=$3, error_code=NULL,
			error_detail=NULL, progress_percent=10, updated_at=now()
		WHERE id=$1 AND owner_id=$4
	`, job.ID, job.AttemptCount, w.ID, job.OwnerID); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `
		UPDATE media_variant
		SET status='processing', failure_code=NULL, failure_detail=NULL, updated_at=now()
		WHERE owner_id=$1 AND async_job_id=$2 AND deleted_at IS NULL
	`, job.OwnerID, job.ID); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return job, nil
}

func (w *MediaProcessor) process(ctx context.Context, job mediaJob) (map[string]any, error) {
	rows, err := w.Pool.Query(ctx, `
		SELECT v.id, v.owner_id, v.media_asset_id, v.variant_kind::text, v.variant_key,
			v.edit_recipe, a.original_object_key, a.sha256, a.mime_type, a.byte_size
		FROM media_variant v
		JOIN media_asset a ON a.owner_id=v.owner_id AND a.id=v.media_asset_id
		WHERE v.owner_id=$1 AND v.async_job_id=$2 AND v.deleted_at IS NULL AND a.deleted_at IS NULL
		ORDER BY v.created_at, v.id
	`, job.OwnerID, job.ID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	variants := make([]map[string]any, 0)
	sources := make(map[uuid.UUID][]byte)
	sourceInfos := make(map[uuid.UUID]objectstore.ObjectInfo)
	for rows.Next() {
		var item mediaVariantWork
		if err := rows.Scan(&item.ID, &item.OwnerID, &item.MediaAssetID, &item.VariantKind, &item.VariantKey,
			&item.EditRecipe, &item.OriginalKey, &item.OriginalSHA256, &item.OriginalMime, &item.OriginalSize); err != nil {
			return nil, err
		}
		body, info, ok := sources[item.MediaAssetID], sourceInfos[item.MediaAssetID], false
		if body == nil {
			reader, fetched, fetchErr := w.Objects.Get(ctx, item.OriginalKey)
			if fetchErr != nil {
				return nil, fmt.Errorf("读取原始媒体 %s: %w", item.MediaAssetID, fetchErr)
			}
			body, fetchErr = io.ReadAll(reader)
			closeErr := reader.Close()
			if fetchErr != nil {
				return nil, fmt.Errorf("读取原始媒体 %s: %w", item.MediaAssetID, fetchErr)
			}
			if closeErr != nil {
				return nil, fmt.Errorf("关闭原始媒体 %s: %w", item.MediaAssetID, closeErr)
			}
			if fetched.Key != item.OriginalKey || fetched.SizeBytes != int64(len(body)) || !strings.EqualFold(fetched.SHA256, item.OriginalSHA256) {
				return nil, fmt.Errorf("原始媒体 %s 校验失败", item.MediaAssetID)
			}
			sources[item.MediaAssetID], sourceInfos[item.MediaAssetID] = body, fetched
			info, ok = fetched, true
		}
		if !ok {
			info = sourceInfos[item.MediaAssetID]
		}
		derived, err := w.deriveMedia(ctx, body, item.OriginalMime, item.VariantKind, item.EditRecipe)
		if err != nil {
			return nil, fmt.Errorf("派生媒体 variant=%s: %w", item.ID, err)
		}
		// Original object keys are never overwritten; derivatives always use a
		// variant-specific key under the asset namespace.
		outputKey := fmt.Sprintf("%s/media/%s/variants/%s", item.OwnerID, item.MediaAssetID, item.ID)
		if outputKey == item.OriginalKey {
			return nil, fmt.Errorf("拒绝覆盖原始媒体对象 %s", item.OriginalKey)
		}
		digest := sha256.Sum256(derived.Body)
		sha := hex.EncodeToString(digest[:])
		stored, err := w.Objects.Put(ctx, objectstore.PutRequest{
			Key: outputKey, Body: bytes.NewReader(derived.Body), SizeBytes: int64(len(derived.Body)),
			SHA256: sha, ContentType: derived.ContentType, ExpiresAt: time.Now().UTC().Add(24 * time.Hour),
		})
		if err != nil {
			return nil, fmt.Errorf("写入派生媒体 variant=%s: %w", item.ID, err)
		}
		variants = append(variants, map[string]any{
			"id": item.ID, "media_asset_id": item.MediaAssetID, "variant_kind": item.VariantKind,
			"object_key": stored.Key, "sha256": stored.SHA256, "size_bytes": stored.SizeBytes,
			"content_type": derived.ContentType,
			"width_px":     derived.Width, "height_px": derived.Height,
			"duration_ms":  derived.DurationMS, "codec": derived.Codec,
		})
		_ = info
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	if len(variants) == 0 {
		return nil, errors.New("media transform job has no active variants")
	}
	return map[string]any{"variants": variants}, nil
}

func (w *MediaProcessor) finish(ctx context.Context, job mediaJob, result map[string]any) error {
	payload, err := json.Marshal(result)
	if err != nil {
		return err
	}
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	for _, raw := range result["variants"].([]map[string]any) {
		variantID, _ := raw["id"].(uuid.UUID)
		objectKey, _ := raw["object_key"].(string)
		sha, _ := raw["sha256"].(string)
		size, _ := raw["size_bytes"].(int64)
		contentType, _ := raw["content_type"].(string)
		width, _ := raw["width_px"].(int)
		height, _ := raw["height_px"].(int)
		durationMS, _ := raw["duration_ms"].(int64)
		codec, _ := raw["codec"].(string)
		if _, err := tx.Exec(ctx, `
			UPDATE media_variant
			SET status='ready', object_key=$4, mime_type=$5,
				byte_size=$6, width_px=NULLIF($7,0), height_px=NULLIF($8,0),
				duration_ms=NULLIF($9,0), codec=NULLIF($10,''), sha256=$11,
				failure_code=NULL, failure_detail=NULL, updated_at=now()
			WHERE owner_id=$1 AND id=$2 AND async_job_id=$3 AND deleted_at IS NULL
		`, job.OwnerID, variantID, job.ID, objectKey, contentType, size, width, height, durationMS, codec, sha); err != nil {
			return err
		}
	}
	if _, err := tx.Exec(ctx, `
		UPDATE async_job
		SET status='succeeded', progress_percent=100, result_payload=$3, finished_at=now(),
			locked_at=NULL, locked_by=NULL, error_code=NULL, error_detail=NULL, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='running' AND locked_by=$4
	`, job.OwnerID, job.ID, payload, w.ID); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func (w *MediaProcessor) fail(ctx context.Context, job mediaJob, cause error) error {
	tx, err := w.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	message := cause.Error()
	if _, err := tx.Exec(ctx, `
		UPDATE media_variant
		SET status='failed', failure_code='MEDIA_PROCESSING_FAILED', failure_detail=$3, updated_at=now()
		WHERE owner_id=$1 AND async_job_id=$2 AND deleted_at IS NULL
	`, job.OwnerID, job.ID, message); err != nil {
		return err
	}
	if _, err := tx.Exec(ctx, `
		UPDATE async_job
		SET status='failed', progress_percent=100, finished_at=now(), available_at=now()+make_interval(secs => LEAST(900, power(2, attempt_count)::int)),
			locked_at=NULL, locked_by=NULL, error_code='MEDIA_PROCESSING_FAILED', error_detail=$3, updated_at=now()
		WHERE owner_id=$1 AND id=$2 AND status='running' AND locked_by=$4
	`, job.OwnerID, job.ID, message, w.ID); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func (w *MediaProcessor) deriveMedia(ctx context.Context, source []byte, sourceMime, variantKind string, recipeJSON []byte) (derivedMedia, error) {
	return deriveMediaWith(ctx, source, sourceMime, variantKind, recipeJSON, w.WebPEncoder, w.VideoTranscoder)
}

// deriveMedia is the package-level helper used by pure unit tests that do not
// need a full MediaProcessor / database fixture.
func deriveMedia(source []byte, sourceMime, variantKind string, recipeJSON []byte) (derivedMedia, error) {
	return deriveMediaWith(context.Background(), source, sourceMime, variantKind, recipeJSON, nil, nil)
}

func deriveMediaWith(
	ctx context.Context,
	source []byte,
	sourceMime, variantKind string,
	recipeJSON []byte,
	webpEncoder WebPEncoder,
	videoTranscoder VideoTranscoder,
) (derivedMedia, error) {
	switch variantKind {
	case "video_transcode":
		if videoTranscoder == nil {
			return derivedMedia{}, fmt.Errorf("%w: video transcoder not configured", ErrCodecUnavailable)
		}
		result, err := videoTranscoder.Transcode(ctx, source)
		if err != nil {
			return derivedMedia{}, err
		}
		return derivedMedia{
			Body:        result.Body,
			ContentType: result.ContentType,
			Width:       result.Width,
			Height:      result.Height,
			DurationMS:  result.DurationMS,
			Codec:       result.Codec,
		}, nil
	case "image_edit":
		// handled below
	default:
		// preview and other non-edit derivatives keep a content-addressed copy
		// of the original bytes without mutating the original object key.
		if strings.HasPrefix(sourceMime, "image/") {
			config, _, err := image.DecodeConfig(bytes.NewReader(source))
			if err == nil {
				return derivedMedia{Body: source, ContentType: sourceMime, Width: config.Width, Height: config.Height}, nil
			}
		}
		if strings.HasPrefix(sourceMime, "video/") && videoTranscoder != nil {
			if probe, err := videoTranscoder.Probe(ctx, source); err == nil {
				return derivedMedia{
					Body: source, ContentType: sourceMime,
					Width: probe.Width, Height: probe.Height, DurationMS: probe.DurationMS, Codec: probe.CodecName,
				}, nil
			}
		}
		return derivedMedia{Body: source, ContentType: sourceMime}, nil
	}

	var recipe mediaRecipe
	if err := json.Unmarshal(recipeJSON, &recipe); err != nil {
		return derivedMedia{}, fmt.Errorf("解析编辑配方: %w", err)
	}
	img, format, err := image.Decode(bytes.NewReader(source))
	if err != nil {
		return derivedMedia{}, fmt.Errorf("解码图片: %w", err)
	}
	for _, operation := range recipe.Operations {
		name := strings.ToLower(strings.TrimSpace(stringValue(operation["op"])))
		if name == "" {
			name = strings.ToLower(strings.TrimSpace(stringValue(operation["type"])))
		}
		params, _ := operation["parameters"].(map[string]any)
		if params == nil {
			params = operation
		}
		var err error
		switch name {
		case "resize":
			width, height := intValue(params["width"]), intValue(params["height"])
			if width < 1 || height < 1 {
				return derivedMedia{}, errors.New("resize 需要正的 width 和 height")
			}
			img = resizeImage(img, width, height)
		case "crop":
			img, err = cropImage(img, intValue(params["x"]), intValue(params["y"]), intValue(params["width"]), intValue(params["height"]))
		case "rotate":
			img, err = rotateImage(img, intValue(params["degrees"]))
		default:
			return derivedMedia{}, fmt.Errorf("暂不支持编辑操作 %q", name)
		}
		if err != nil {
			return derivedMedia{}, err
		}
	}
	outputFormat := strings.ToLower(strings.TrimSpace(recipe.OutputFormat))
	if outputFormat == "" {
		outputFormat = strings.ToLower(format)
	}
	var body bytes.Buffer
	var contentType string
	switch outputFormat {
	case "jpeg", "jpg":
		if err := jpeg.Encode(&body, img, &jpeg.Options{Quality: 90}); err != nil {
			return derivedMedia{}, err
		}
		contentType = "image/jpeg"
	case "png":
		if err := png.Encode(&body, img); err != nil {
			return derivedMedia{}, err
		}
		contentType = "image/png"
	case "webp":
		if webpEncoder == nil {
			return derivedMedia{}, fmt.Errorf("%w: webp encoder not configured", ErrCodecUnavailable)
		}
		encoded, err := webpEncoder.Encode(ctx, img, 80)
		if err != nil {
			return derivedMedia{}, err
		}
		bounds := img.Bounds()
		return derivedMedia{Body: encoded, ContentType: "image/webp", Width: bounds.Dx(), Height: bounds.Dy(), Codec: "webp"}, nil
	default:
		return derivedMedia{}, fmt.Errorf("不支持输出格式 %q", outputFormat)
	}
	bounds := img.Bounds()
	return derivedMedia{Body: body.Bytes(), ContentType: contentType, Width: bounds.Dx(), Height: bounds.Dy()}, nil
}

func resizeImage(src image.Image, width, height int) image.Image {
	dst := image.NewNRGBA(image.Rect(0, 0, width, height))
	srcBounds := src.Bounds()
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			sx := srcBounds.Min.X + x*srcBounds.Dx()/width
			sy := srcBounds.Min.Y + y*srcBounds.Dy()/height
			dst.Set(x, y, color.NRGBAModel.Convert(src.At(sx, sy)))
		}
	}
	return dst
}

func cropImage(src image.Image, x, y, width, height int) (image.Image, error) {
	bounds := src.Bounds()
	if width < 1 || height < 1 || x < 0 || y < 0 || x+width > bounds.Dx() || y+height > bounds.Dy() {
		return nil, errors.New("crop 区域超出图片边界")
	}
	dst := image.NewNRGBA(image.Rect(0, 0, width, height))
	for dy := 0; dy < height; dy++ {
		for dx := 0; dx < width; dx++ {
			dst.Set(dx, dy, color.NRGBAModel.Convert(src.At(bounds.Min.X+x+dx, bounds.Min.Y+y+dy)))
		}
	}
	return dst, nil
}

func rotateImage(src image.Image, degrees int) (image.Image, error) {
	degrees = ((degrees % 360) + 360) % 360
	if degrees != 0 && degrees != 90 && degrees != 180 && degrees != 270 {
		return nil, errors.New("rotate 仅支持 0/90/180/270 度")
	}
	bounds := src.Bounds()
	width, height := bounds.Dx(), bounds.Dy()
	if degrees == 90 || degrees == 270 {
		width, height = height, width
	}
	dst := image.NewNRGBA(image.Rect(0, 0, width, height))
	for y := 0; y < bounds.Dy(); y++ {
		for x := 0; x < bounds.Dx(); x++ {
			dx, dy := x, y
			switch degrees {
			case 90:
				dx, dy = bounds.Dy()-1-y, x
			case 180:
				dx, dy = bounds.Dx()-1-x, bounds.Dy()-1-y
			case 270:
				dx, dy = y, bounds.Dx()-1-x
			}
			dst.Set(dx, dy, color.NRGBAModel.Convert(src.At(bounds.Min.X+x, bounds.Min.Y+y)))
		}
	}
	return dst, nil
}

func stringValue(value any) string {
	if value == nil {
		return ""
	}
	return fmt.Sprint(value)
}

func intValue(value any) int {
	switch number := value.(type) {
	case int:
		return number
	case int64:
		return int(number)
	case float64:
		return int(math.Round(number))
	case json.Number:
		parsed, _ := number.Int64()
		return int(parsed)
	default:
		return 0
	}
}
