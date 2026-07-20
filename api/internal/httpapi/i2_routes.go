package httpapi

import (
	"net/http"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/i2core"
)

func (s *Server) registerI2CoreRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/hamsters", s.listI2Hamsters)
	mux.HandleFunc("POST /v1/hamsters", s.createI2Hamster)
	mux.HandleFunc("POST /v1/hamsters/batch", s.batchCreateI2Hamsters)
	mux.HandleFunc("GET /v1/hamsters/{hamster_id}", s.getI2Hamster)
	mux.HandleFunc("PATCH /v1/hamsters/{hamster_id}", s.updateI2Hamster)
	mux.HandleFunc("GET /v1/hamsters/{hamster_id}/pedigree", s.getI2HamsterPedigree)

	mux.HandleFunc("GET /v1/pedigree-parentages", s.listI2PedigreeParentages)
	mux.HandleFunc("POST /v1/pedigree-parentages", s.createI2PedigreeParentage)

	mux.HandleFunc("GET /v1/enclosures", s.listI2Enclosures)
	mux.HandleFunc("POST /v1/enclosures", s.createI2Enclosure)
	mux.HandleFunc("GET /v1/enclosures/{enclosure_id}", s.getI2Enclosure)
	mux.HandleFunc("PATCH /v1/enclosures/{enclosure_id}", s.updateI2Enclosure)
	mux.HandleFunc("GET /v1/enclosures/{enclosure_id}/stays", s.listI2EnclosureStays)
	mux.HandleFunc("POST /v1/enclosures/{enclosure_id}/stays", s.createI2EnclosureStay)
	mux.HandleFunc("PATCH /v1/enclosure-stays/{stay_id}", s.updateI2EnclosureStay)
	mux.HandleFunc("GET /v1/enclosures/{enclosure_id}/cleanings", s.listI2EnclosureCleanings)
	mux.HandleFunc("POST /v1/enclosures/{enclosure_id}/cleanings", s.createI2EnclosureCleaning)
	mux.HandleFunc("GET /v1/enclosure-cleanings/{cleaning_id}", s.getI2EnclosureCleaning)

	mux.HandleFunc("GET /v1/litters", s.listI2Litters)
	mux.HandleFunc("GET /v1/litters/{litter_id}", s.getI2Litter)
	mux.HandleFunc("GET /v1/litters/{litter_id}/parents", s.listI2LitterParents)
	mux.HandleFunc("POST /v1/litters/{litter_id}/parents", s.createI2LitterParent)
	mux.HandleFunc("GET /v1/litters/{litter_id}/members", s.listI2LitterMembers)

	mux.HandleFunc("GET /v1/weight-records", s.listI2WeightRecords)
	mux.HandleFunc("POST /v1/weight-records", s.createI2WeightRecord)
	mux.HandleFunc("POST /v1/weight-records/batch", s.batchCreateI2WeightRecords)
}

func (s *Server) i2CoreService() *i2core.Service {
	return i2core.NewService(i2core.NewPostgresRepositoryFromStore(s.Store))
}

func (s *Server) authenticateI2(w http.ResponseWriter, r *http.Request) (uuid.UUID, bool) {
	ownerID, _, ok := s.authenticate(r)
	if !ok {
		writeAPIError(w, r, authRequired())
		return uuid.Nil, false
	}
	return ownerID, true
}
