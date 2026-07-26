package httpapi

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/geneticcore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

// Public showcase routes for miniprogram Sprint 3:
// pedigree tree + phenotype-table simulation for published hamsters only.
func (s *Server) registerP3PublicShowcaseRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/public/sites/{slug}/hamsters/{hamster_id}/pedigree", s.getPublicHamsterPedigree)
	mux.HandleFunc("POST /v1/public/sites/{slug}/simulate", s.postPublicPhenotypeSimulate)
}

type publicSimulateRequest struct {
	SireHamsterID string `json:"sire_hamster_id"`
	DamHamsterID  string `json:"dam_hamster_id"`
	Series        string `json:"series"`
	SirePhenotype string `json:"sire_phenotype"`
	DamPhenotype  string `json:"dam_phenotype"`
}

func (s *Server) getPublicHamsterPedigree(w http.ResponseWriter, r *http.Request) {
	site, ownerID, err := s.findPublishedGrowthSite(r.Context(), r.PathValue("slug"))
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	hamsterID, err := uuid.Parse(strings.TrimSpace(r.PathValue("hamster_id")))
	if err != nil || hamsterID == uuid.Nil {
		writeAPIError(w, r, validationError("hamster_id", "仓鼠 ID 无效"))
		return
	}
	// Subject must be a published public hamster.
	subject, err := s.getGrowthPublicHamster(r.Context(), ownerID, hamsterID)
	if err != nil || !subject.Published {
		writeAPIError(w, r, store.ErrNotFound)
		return
	}
	generations := 3
	if value := strings.TrimSpace(r.URL.Query().Get("generations")); value != "" {
		parsed, parseErr := strconv.Atoi(value)
		if parseErr != nil || parsed < 1 || parsed > 6 {
			writeAPIError(w, r, validationError("generations", "代数须在 1–6"))
			return
		}
		generations = parsed
	}
	graph, err := s.i2CoreService().GetHamsterPedigree(r.Context(), ownerID, hamsterID, generations)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}

	// Build published-name map for privacy-safe labels.
	publishedNames := map[string]string{}
	items, _ := s.loadGrowthPublicHamsters(r.Context(), ownerID, false)
	for _, item := range items {
		if item.Published {
			publishedNames[item.ID] = item.PublicName
		}
	}

	nodes := make([]map[string]any, 0, len(graph.Nodes))
	for _, n := range graph.Nodes {
		id := n.ID.String()
		label := "未公开"
		public := false
		if name, ok := publishedNames[id]; ok && strings.TrimSpace(name) != "" {
			label = name
			public = true
		} else if id == hamsterID.String() {
			label = subject.PublicName
			public = true
		}
		nodes = append(nodes, map[string]any{
			"hamster_id":  id,
			"public_name": label,
			"sex":         n.Sex,
			"public":      public,
		})
	}
	edges := make([]map[string]any, 0, len(graph.Parentages))
	for _, p := range graph.Parentages {
		if p.Status != "accepted" || p.ValidTo != nil {
			continue
		}
		edges = append(edges, map[string]any{
			"child_hamster_id":  p.ChildID.String(),
			"parent_hamster_id": p.ParentID.String(),
			"role":              p.Role,
		})
	}

	w.Header().Set("Cache-Control", "no-store")
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"site":             site,
		"root_hamster_id":  hamsterID.String(),
		"root_public_name": subject.PublicName,
		"generations":      generations,
		"nodes":            nodes,
		"edges":            edges,
		"note":             "仅展示已公开档案名称；未公开祖先显示为「未公开」。",
	}))
}

func (s *Server) postPublicPhenotypeSimulate(w http.ResponseWriter, r *http.Request) {
	site, ownerID, err := s.findPublishedGrowthSite(r.Context(), r.PathValue("slug"))
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var request publicSimulateRequest
	if _, err := decodeI2Body(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "请求体无效"))
		return
	}

	series := strings.TrimSpace(request.Series)
	sirePh := strings.TrimSpace(request.SirePhenotype)
	damPh := strings.TrimSpace(request.DamPhenotype)
	var sireLabel, damLabel string

	// Prefer published hamster pair when IDs provided.
	if strings.TrimSpace(request.SireHamsterID) != "" && strings.TrimSpace(request.DamHamsterID) != "" {
		sireID, err1 := uuid.Parse(strings.TrimSpace(request.SireHamsterID))
		damID, err2 := uuid.Parse(strings.TrimSpace(request.DamHamsterID))
		if err1 != nil || err2 != nil {
			writeAPIError(w, r, validationError("hamster_id", "父本/母本 ID 无效"))
			return
		}
		sire, err := s.getGrowthPublicHamster(r.Context(), ownerID, sireID)
		if err != nil || !sire.Published {
			writeAPIError(w, r, store.ErrNotFound)
			return
		}
		dam, err := s.getGrowthPublicHamster(r.Context(), ownerID, damID)
		if err != nil || !dam.Published {
			writeAPIError(w, r, store.ErrNotFound)
			return
		}
		// Load raw variety_code for series|label authority path.
		var sireVar, damVar string
		_ = s.Store.Pool.QueryRow(r.Context(), `
			SELECT COALESCE(variety_code,'') FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, sireID).Scan(&sireVar)
		_ = s.Store.Pool.QueryRow(r.Context(), `
			SELECT COALESCE(variety_code,'') FROM hamster WHERE owner_id=$1 AND id=$2 AND deleted_at IS NULL
		`, ownerID, damID).Scan(&damVar)
		sSeries, sLabel := splitCoreVariety(sireVar)
		dSeries, dLabel := splitCoreVariety(damVar)
		if sLabel == "" {
			sLabel = strings.TrimSpace(sire.Variety)
		}
		if dLabel == "" {
			dLabel = strings.TrimSpace(dam.Variety)
		}
		if series == "" {
			if sSeries != "" {
				series = sSeries
			} else {
				series = dSeries
			}
		}
		sirePh, damPh = sLabel, dLabel
		sireLabel, damLabel = sire.PublicName, dam.PublicName
	}

	if series == "" || sirePh == "" || damPh == "" {
		writeAPIError(w, r, validationError("body", "需要已发布仓鼠配对或 series + 父母表型"))
		return
	}

	result, err := geneticcore.SimulatePhenotypeTable(series, sirePh, damPh)
	if err != nil {
		writeAPIError(w, r, validationError("simulate", err.Error()))
		return
	}

	outcomes := make([]map[string]any, 0, len(result.Outcomes))
	for _, o := range result.Outcomes {
		outcomes = append(outcomes, map[string]any{
			"phenotype":   o.Phenotype,
			"probability": o.Probability,
			"fraction":    o.Fraction,
			"percent":     o.Probability * 100,
		})
	}

	// Short “为什么？” copy for customer showcase (presentation only).
	most := ""
	mostP := 0.0
	for _, o := range result.Outcomes {
		if o.Probability > mostP {
			mostP = o.Probability
			most = o.Phenotype
		}
	}
	why := map[string]any{
		"sire":      sirePh,
		"dam":       damPh,
		"sire_name": sireLabel,
		"dam_name":  damLabel,
		"therefore": "根据权威表型表，该配对后代最可能出现「" + most + "」。单窝会有随机波动，以下为理论比例。",
	}

	w.Header().Set("Cache-Control", "no-store")
	writeJSON(w, r, http.StatusOK, envelope(r, map[string]any{
		"site":            site,
		"mode":            "phenotype_table",
		"series":          series,
		"sire_phenotype":  sirePh,
		"dam_phenotype":   damPh,
		"sire_name":       sireLabel,
		"dam_name":        damLabel,
		"outcomes":        outcomes,
		"why":             why,
		"table_version":    result.Version,
		"prediction_basis": result.PredictionBasis,
	}))
}

func splitCoreVariety(raw string) (series, label string) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return "", ""
	}
	if i := strings.Index(raw, "|"); i > 0 && i < len(raw)-1 {
		return strings.TrimSpace(raw[:i]), strings.TrimSpace(raw[i+1:])
	}
	return "", raw
}
