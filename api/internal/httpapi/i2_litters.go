package httpapi

import (
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) listI2Litters(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	state := strings.TrimSpace(r.URL.Query().Get("state"))
	if state != "" && !i2OneOf(state, "newborn", "nursing", "weaning_due", "sexing_due", "individualizing", "closed", "voided") {
		writeI2CoreError(w, r, validationError("state", "窝次状态取值不正确"))
		return
	}
	bornFrom, err := parseI2OptionalQueryDate(r, "born_from")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	bornTo, err := parseI2OptionalQueryDate(r, "born_to")
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	if bornFrom != nil && bornTo != nil && bornTo.Before(*bornFrom) {
		writeI2CoreError(w, r, validationError("born_to", "结束日期不得早于开始日期"))
		return
	}
	location, err := i2RequestLocation(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	filter := i2core.LitterFilter{State: state}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.Litter, error) {
		filter.Page = corePage
		return service.ListLitters(r.Context(), ownerID, filter)
	}, func(litter i2core.Litter) bool {
		if bornFrom == nil && bornTo == nil {
			return true
		}
		if litter.BornAt == nil {
			return false
		}
		date := i2DateOnly(litter.BornAt.In(location))
		return (bornFrom == nil || !date.Before(*bornFrom)) && (bornTo == nil || !date.After(*bornTo))
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2LitterJSON), pageInfo)
}

func (s *Server) getI2Litter(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	litter, err := s.i2CoreService().GetLitter(r.Context(), ownerID, litterID)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	w.Header().Set("ETag", store.FormatETag(litter.Version))
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"litter":         i2LitterJSON(litter),
		"reconciliation": i2LitterReconciliationJSON(litter),
	}))
}

func (s *Server) listI2LitterParents(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	service := s.i2CoreService()
	items, err := loadAllI2(func(page i2core.Page) ([]i2core.LitterParent, error) {
		return service.ListLitterParents(r.Context(), ownerID, litterID, page)
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, envelope(r, mapI2Slice(items, i2LitterParentJSON)))
}

func (s *Server) createI2LitterParent(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	expectedVersion, err := parseI2IfMatch(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	var request i2LitterParentCreateRequest
	payload, err := decodeI2Body(r, &request)
	if err != nil || request.HamsterID == uuid.Nil {
		writeI2CoreError(w, r, validationError("body", "窝次父母请求体格式不正确"))
		return
	}
	result, err := s.i2CoreService().CreateLitterParent(r.Context(), ownerID, i2WriteOptions(r, payload), i2core.CreateLitterParentInput{
		LitterID: litterID, HamsterID: request.HamsterID, Role: request.Role, EvidenceType: request.EvidenceType,
		EvidencePayload: request.EvidencePayload, Confidence: request.Confidence, CorrectionReason: request.CorrectionReason,
		ExpectedLitterVersion: expectedVersion,
	})
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2Stored(w, r, http.StatusCreated, envelope(r, i2LitterParentJSON(result.Value.Parent)), result.Replayed,
		store.FormatETag(result.Value.Litter.Version), "")
}

func (s *Server) listI2LitterMembers(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateI2(w, r)
	if !ok {
		return
	}
	litterID, ok := parseI2PathUUID(w, r, "litter_id")
	if !ok {
		return
	}
	page, err := parseI2Page(r)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	service := s.i2CoreService()
	items, pageInfo, err := loadI2Page(page, func(corePage i2core.Page) ([]i2core.LitterMember, error) {
		return service.ListLitterMembers(r.Context(), ownerID, litterID, corePage)
	}, nil)
	if err != nil {
		writeI2CoreError(w, r, err)
		return
	}
	writeI2List(w, r, mapI2Slice(items, i2LitterMemberJSON), pageInfo)
}
