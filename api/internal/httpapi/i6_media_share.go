package httpapi

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i6media"
	"github.com/scolvpet/scolvpet/api/internal/objectstore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerI6MediaRoutes(mux *http.ServeMux) {
	mux.HandleFunc("POST /v1/media/uploads/presign", s.presignI6MediaUpload)
	mux.HandleFunc("PUT /v1/media/uploads/{upload_id}/content", s.putI6MediaUpload)
	mux.HandleFunc("POST /v1/media/uploads/{upload_id}/complete", s.completeI6MediaUpload)
	mux.HandleFunc("GET /v1/media/{media_id}", s.getI6Media)
	mux.HandleFunc("GET /v1/media/{media_id}/content", s.getI6MediaContent)
	mux.HandleFunc("POST /v1/media/{media_id}/edit-recipes", s.createI6MediaEditRecipe)
	mux.HandleFunc("GET /v1/media/{media_id}/transcode-status", s.getI6MediaTranscodeStatus)
	mux.HandleFunc("POST /v1/media/{media_id}/retry-processing", s.retryI6MediaProcessing)
	mux.HandleFunc("PUT /v1/media/{media_id}/cover", s.setI6MediaCover)
	mux.HandleFunc("GET /v1/shares", s.listI6Shares)
	mux.HandleFunc("POST /v1/shares", s.createI6Share)
	mux.HandleFunc("POST /v1/shares/preview", s.previewI6ShareDraft)
	mux.HandleFunc("GET /v1/shares/{share_id}/preview", s.previewI6Share)
	mux.HandleFunc("POST /v1/shares/{share_id}/revoke", s.revokeI6Share)
	mux.HandleFunc("GET /v1/public/shares/{token}", s.getI6PublicShare)
	mux.HandleFunc("GET /v1/public/shares/{token}/media/{media_id}", s.getI6PublicShareMedia)
}

func (s *Server) i6MediaService() *i6media.Service {
	return i6media.NewService(s.Store, s.ImportObjects)
}

func (s *Server) presignI6MediaUpload(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	var input i6media.PresignInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeAPIError(w, r, i6media.ErrValidation)
		return
	}
	result, err := s.i6MediaService().Presign(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, input)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) putI6MediaUpload(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	uploadID, err := uuid.Parse(r.PathValue("upload_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	service := s.i6MediaService()
	if _, err := service.GetUpload(r.Context(), ownerID, uploadID); err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	result, err := service.PutUpload(r.Context(), ownerID, uploadID, r.Header.Get("Idempotency-Key"), r.URL.Path, r.Body)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) completeI6MediaUpload(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	uploadID, err := uuid.Parse(r.PathValue("upload_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	var input i6media.CompleteInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	upload, err := s.i6MediaService().GetUpload(r.Context(), ownerID, uploadID)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	if s.ImportObjects == nil {
		writeI6MediaError(w, r, errors.New("media object store unavailable"))
		return
	}
	reader, info, err := s.ImportObjects.Get(r.Context(), upload.ObjectKey)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	_ = reader.Close()
	result, err := s.i6MediaService().Complete(r.Context(), ownerID, uploadID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, r.Header.Get("If-Match"), input, info)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) getI6Media(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	asset, err := s.i6MediaService().GetMediaView(r.Context(), ownerID, mediaID)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(asset.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, asset))
}

func (s *Server) getI6MediaContent(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	var variantID *uuid.UUID
	if raw := strings.TrimSpace(r.URL.Query().Get("variant_id")); raw != "" {
		parsed, err := uuid.Parse(raw)
		if err != nil {
			writeI6MediaError(w, r, i6media.ErrNotFound)
			return
		}
		variantID = &parsed
	}
	reader, info, contentType, err := s.i6MediaService().OpenMediaContent(r.Context(), ownerID, mediaID, variantID)
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		writeI6MediaError(w, r, err)
		return
	}
	defer reader.Close()
	w.Header().Set("Cache-Control", "private, no-store, max-age=0")
	if contentType != "" {
		w.Header().Set("Content-Type", contentType)
	}
	if info.SHA256 != "" {
		w.Header().Set("ETag", `"`+info.SHA256+`"`)
	}
	if _, err := io.Copy(w, reader); err != nil {
		return
	}
}

func (s *Server) createI6MediaEditRecipe(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	var input i6media.EditRecipeInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	result, err := s.i6MediaService().CreateEditRecipe(r.Context(), ownerID, mediaID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, r.Header.Get("If-Match"), input)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) getI6MediaTranscodeStatus(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	job, err := s.i6MediaService().ProcessingStatus(r.Context(), ownerID, mediaID)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, job))
}

func (s *Server) retryI6MediaProcessing(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	var input i6media.RetryProcessingInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	result, err := s.i6MediaService().RetryProcessing(r.Context(), ownerID, mediaID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, r.Header.Get("If-Match"), input)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) setI6MediaCover(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	var input i6media.CoverInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	result, err := s.i6MediaService().SetCover(r.Context(), ownerID, mediaID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, r.Header.Get("If-Match"), input)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) listI6Shares(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	shares, err := s.i6MediaService().ListShares(r.Context(), ownerID)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, listEnvelope(r, shares))
}

func (s *Server) createI6Share(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	var input i6media.ShareInput
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	result, err := s.i6MediaService().CreateShare(r.Context(), ownerID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, input)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeI6MediaStored(w, r, result.Status, envelope(r, result.Value), result.Headers, result.Replayed)
}

func (s *Server) previewI6ShareDraft(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	var input i6media.ShareInput
	_, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	preview, err := s.i6MediaService().PreviewShareDraft(r.Context(), ownerID, input)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, preview))
}

func (s *Server) previewI6Share(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	shareID, err := uuid.Parse(r.PathValue("share_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	preview, err := s.i6MediaService().PreviewShare(r.Context(), ownerID, shareID)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, preview))
}

func (s *Server) revokeI6Share(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI6(w, r)
	if !ok {
		return
	}
	shareID, err := uuid.Parse(r.PathValue("share_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	var input struct {
		Reason string `json:"reason"`
	}
	payload, err := decodeBody(r, &input)
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrValidation)
		return
	}
	result, err := s.i6MediaService().RevokeShare(r.Context(), ownerID, shareID, r.Header.Get("Idempotency-Key"), r.URL.Path, payload, r.Header.Get("If-Match"), input.Reason)
	if err != nil {
		writeI6MediaError(w, r, err)
		return
	}
	share := result.Value
	writeI6MediaStored(w, r, result.Status, envelope(r, map[string]any{"share": share, "revoked_at": share.RevokedAt, "cache_invalidation": map[string]any{"status": "queued"}}), result.Headers, result.Replayed)
}

func (s *Server) getI6PublicShare(w http.ResponseWriter, r *http.Request) {
	share, err := s.i6MediaService().PublicShare(r.Context(), strings.TrimSpace(r.PathValue("token")))
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		writeI6MediaError(w, r, err)
		return
	}
	w.Header().Set("Cache-Control", "public, no-store, max-age=0")
	writeJSON(w, r, http.StatusOK, envelope(r, share))
}

func (s *Server) getI6PublicShareMedia(w http.ResponseWriter, r *http.Request) {
	mediaID, err := uuid.Parse(r.PathValue("media_id"))
	if err != nil {
		writeI6MediaError(w, r, i6media.ErrNotFound)
		return
	}
	reader, info, contentType, err := s.i6MediaService().PublicMedia(r.Context(), strings.TrimSpace(r.PathValue("token")), mediaID)
	if err != nil {
		w.Header().Set("Cache-Control", "no-store")
		writeI6MediaError(w, r, err)
		return
	}
	defer reader.Close()
	w.Header().Set("Cache-Control", "public, no-store, max-age=0")
	if contentType != "" {
		w.Header().Set("Content-Type", contentType)
	}
	if info.SHA256 != "" {
		w.Header().Set("ETag", `"`+info.SHA256+`"`)
	}
	if _, err := io.Copy(w, reader); err != nil {
		return
	}
}

func writeI6MediaError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, i6media.ErrValidation) {
		writeAPIError(w, r, validationError("media", "媒体或分享请求参数不正确"))
		return
	}
	if errors.Is(err, i6media.ErrNotFound) || errors.Is(err, store.ErrNotFound) {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	if errors.Is(err, i6media.ErrConflict) {
		writeAPIError(w, r, &apiError{Status: http.StatusConflict, Code: "STATE_CONFLICT", Message: "当前媒体或分享状态不允许执行该动作"})
		return
	}
	if errors.Is(err, objectstore.ErrChecksumMismatch) || errors.Is(err, objectstore.ErrSizeMismatch) {
		writeAPIError(w, r, validationError("media", "对象内容与声明的大小或 SHA-256 不一致"))
		return
	}
	writeAPIError(w, r, err)
}

func writeI6MediaStored(w http.ResponseWriter, r *http.Request, status int, payload any, headers map[string]string, replayed bool) {
	for key, value := range headers {
		w.Header().Set(key, value)
	}
	w.Header().Set("Idempotency-Key", r.Header.Get("Idempotency-Key"))
	w.Header().Set("Idempotency-Replayed", strconv.FormatBool(replayed))
	writeJSON(w, r, status, payload)
}

var _ = json.Valid
