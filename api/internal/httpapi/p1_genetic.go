package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/geneticcore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP1GeneticRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/genetic/loci", s.listGeneticLoci)
	mux.HandleFunc("GET /v1/genetic/profiles", s.listGeneticProfiles)
	mux.HandleFunc("POST /v1/genetic/profiles", s.createGeneticProfile)
	mux.HandleFunc("POST /v1/genetic/simulate", s.simulateGeneticBreeding)
}

type geneticProfile struct {
	ID         uuid.UUID         `json:"id"`
	HamsterID  *uuid.UUID        `json:"hamster_id,omitempty"`
	Name       string            `json:"name"`
	Phenotype  map[string]any    `json:"phenotype"`
	Genotype   map[string]string `json:"genotype"`
	Confidence string            `json:"confidence"`
	Notes      *string           `json:"notes,omitempty"`
	Version    int               `json:"version"`
	UpdatedAt  time.Time         `json:"updated_at"`
}

type createGeneticProfileRequest struct {
	HamsterID  *string           `json:"hamster_id"`
	Name       string            `json:"name"`
	Phenotype  map[string]any    `json:"phenotype"`
	Genotype   map[string]string `json:"genotype"`
	Confidence string            `json:"confidence"`
	Notes      *string           `json:"notes"`
}

type simulateGeneticRequest struct {
	Sire map[string]string `json:"sire"`
	Dam  map[string]string `json:"dam"`
}

func (s *Server) listGeneticLoci(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.authenticateMemberOwner(w, r); !ok {
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": geneticcore.DefaultLoci,
		"meta": responseMeta(r),
	})
}

func (s *Server) listGeneticProfiles(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		SELECT id, hamster_id, name, phenotype, genotype, confidence::text, notes, version, updated_at
		FROM genetic_profile
		WHERE owner_id=$1
		ORDER BY updated_at DESC, id DESC
		LIMIT 200
	`, ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	defer rows.Close()
	items := make([]geneticProfile, 0)
	for rows.Next() {
		item, err := scanGeneticProfile(rows)
		if err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": items, "meta": responseMeta(r)})
}

func (s *Server) createGeneticProfile(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request createGeneticProfileRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "遗传档案请求体格式不正确"))
		return
	}
	name := strings.TrimSpace(request.Name)
	if name == "" {
		writeAPIError(w, r, validationError("name", "档案名称必填"))
		return
	}
	confidence := strings.TrimSpace(request.Confidence)
	if confidence == "" {
		confidence = "unknown"
	}
	if confidence != "observed" && confidence != "inferred" && confidence != "unknown" {
		writeAPIError(w, r, validationError("confidence", "置信度无效"))
		return
	}
	genotype, err := normalizeGenotypeMap(request.Genotype)
	if err != nil {
		writeAPIError(w, r, validationError("genotype", err.Error()))
		return
	}
	phenotype := request.Phenotype
	if phenotype == nil {
		phenotype = map[string]any{}
	}
	// If phenotype empty, derive labels from genotype.
	if len(phenotype) == 0 && len(genotype) > 0 {
		labels, summary := geneticcore.PhenotypeFor(genotype)
		for k, v := range labels {
			phenotype[k] = v
		}
		phenotype["summary"] = summary
	}
	var hamsterID *uuid.UUID
	if request.HamsterID != nil && strings.TrimSpace(*request.HamsterID) != "" {
		id, parseErr := uuid.Parse(strings.TrimSpace(*request.HamsterID))
		if parseErr != nil {
			writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
			return
		}
		hamsterID = &id
	}
	orgID, err := s.currentOrganizationID(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	phenotypeJSON, _ := json.Marshal(phenotype)
	genotypeJSON, _ := json.Marshal(genotype)
	var id uuid.UUID
	err = s.Store.Pool.QueryRow(r.Context(), `
		INSERT INTO genetic_profile (
			owner_id, organization_id, hamster_id, name, phenotype, genotype, confidence, notes
		) VALUES ($1,$2,$3,$4,$5::jsonb,$6::jsonb,$7::genetic_confidence,$8)
		RETURNING id
	`, ownerID, orgID, hamsterID, name, phenotypeJSON, genotypeJSON, confidence, emptyToNil(request.Notes)).Scan(&id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	item, err := s.getGeneticProfile(r.Context(), ownerID, id)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusCreated, map[string]any{"data": item, "meta": responseMeta(r)})
}

func (s *Server) simulateGeneticBreeding(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.authenticateMemberOwner(w, r); !ok {
		return
	}
	var request simulateGeneticRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "模拟请求体格式不正确"))
		return
	}
	result, err := geneticcore.Simulate(request.Sire, request.Dam)
	if err != nil {
		writeAPIError(w, r, validationError("genotype", err.Error()))
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": result, "meta": responseMeta(r)})
}

func (s *Server) getGeneticProfile(ctx context.Context, ownerID, id uuid.UUID) (geneticProfile, error) {
	row := s.Store.Pool.QueryRow(ctx, `
		SELECT id, hamster_id, name, phenotype, genotype, confidence::text, notes, version, updated_at
		FROM genetic_profile
		WHERE owner_id=$1 AND id=$2
	`, ownerID, id)
	return scanGeneticProfile(row)
}

type geneticScanner interface {
	Scan(dest ...any) error
}

func scanGeneticProfile(row geneticScanner) (geneticProfile, error) {
	var item geneticProfile
	var phenotypeRaw, genotypeRaw []byte
	err := row.Scan(
		&item.ID, &item.HamsterID, &item.Name, &phenotypeRaw, &genotypeRaw,
		&item.Confidence, &item.Notes, &item.Version, &item.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return geneticProfile{}, store.ErrNotFound
	}
	if err != nil {
		return geneticProfile{}, err
	}
	item.Phenotype = map[string]any{}
	_ = json.Unmarshal(phenotypeRaw, &item.Phenotype)
	item.Genotype = map[string]string{}
	var raw map[string]any
	if err := json.Unmarshal(genotypeRaw, &raw); err == nil {
		for k, v := range raw {
			item.Genotype[k] = strings.TrimSpace(toStringAny(v))
		}
	}
	return item, nil
}

func normalizeGenotypeMap(in map[string]string) (map[string]string, error) {
	out := map[string]string{}
	if in == nil {
		return out, nil
	}
	for code, raw := range in {
		code = strings.TrimSpace(code)
		if code == "" || strings.TrimSpace(raw) == "" {
			continue
		}
		locus, ok := geneticcore.LocusByCode(code)
		if !ok {
			return nil, errors.New("未知位点 " + code)
		}
		norm, err := geneticcore.NormalizeAllelePair(locus, raw)
		if err != nil {
			return nil, err
		}
		out[code] = norm
	}
	return out, nil
}

func toStringAny(v any) string {
	switch t := v.(type) {
	case string:
		return t
	default:
		b, _ := json.Marshal(t)
		return string(b)
	}
}
