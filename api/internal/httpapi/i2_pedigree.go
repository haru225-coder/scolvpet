package httpapi

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) getI2HamsterPedigree(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	hamsterID, ok := parseI2PathUUID(w, r, "hamster_id")
	if !ok {
		return
	}
	generations := 4
	if value := strings.TrimSpace(r.URL.Query().Get("generations")); value != "" {
		parsed, err := strconv.Atoi(value)
		if err != nil || parsed < 1 || parsed > 8 {
			writeI2CoreError(w, r, validationError("generations", "家谱代数必须在 1 到 8 之间"))
			return
		}
		generations = parsed
	}
	graph, err := s.i2CoreService().GetHamsterPedigree(r.Context(), ownerID, hamsterID, generations)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, i2PedigreeGraphJSON(graph)))
}

func (s *Server) listI2PedigreeParentages(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	childID, err := parseI2OptionalQueryUUID(r, "child_hamster_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	parentID, err := parseI2OptionalQueryUUID(r, "parent_hamster_id")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.PedigreeParentageFilter{ChildHamsterID: childID, ParentHamsterID: parentID}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.PedigreeParentage, error) {
		filter.Page = corePage
		return service.ListPedigreeParentages(r.Context(), ownerID, filter)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2PedigreeParentageJSON), pageInfo)
}

func (s *Server) createI2PedigreeParentage(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2PedigreeParentageCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.ParentHamsterID == uuid.Nil || request.ChildHamsterID == uuid.Nil || strings.TrimSpace(request.ValidFrom) == "" {
		writeI2CoreError(w, r, validationError("body", "父母关系请求体格式不正确"))
		return
	}
	validFrom, err := parseI2DateTime(request.ValidFrom)
	if err != nil {
		writeI2CoreError(w, r, validationError("valid_from", "关系生效时间格式不正确"))
		return
	}
	input := i2core.CreatePedigreeParentageInput{
		ParentID: request.ParentHamsterID, ChildID: request.ChildHamsterID, Role: request.Role,
		EvidenceType: request.EvidenceType, Confidence: request.Confidence, ValidFrom: validFrom,
		Notes: request.Notes, CorrectionReason: request.CorrectionReason,
	}
	result, err := s.i2CoreService().CreatePedigreeParentage(r.Context(), ownerID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2PedigreeParentageJSON(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/pedigree-parentages/"+result.Value.ID.String())
}

func (s *Server) endI2PedigreeParentage(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	var request i2PedigreeParentageEndRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.ChildHamsterID == uuid.Nil || strings.TrimSpace(request.Role) == "" || strings.TrimSpace(request.CorrectionReason) == "" {
		writeI2CoreError(w, r, validationError("body", "解除父母关系请求体格式不正确（需 child_hamster_id、role、correction_reason）"))
		return
	}
	input := i2core.EndPedigreeParentageInput{
		ChildID: request.ChildHamsterID, Role: request.Role, CorrectionReason: request.CorrectionReason,
	}
	result, err := s.i2CoreService().EndPedigreeParentage(r.Context(), ownerID, i2WriteOptions(r, payload), input)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusOK, envelope(r, i2PedigreeParentageJSON(result.Value)), result.Replayed,
		store.FormatETag(result.Value.Version), "/v1/pedigree-parentages/"+result.Value.ID.String())
}
