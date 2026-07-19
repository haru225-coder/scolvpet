package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/geneticcore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func (s *Server) registerP1GeneticRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/genetic/loci", s.listGeneticLoci)
	mux.HandleFunc("GET /v1/genetic/phenotype-catalog", s.listGeneticPhenotypeCatalog)
	mux.HandleFunc("GET /v1/genetic/target-crosses", s.listGeneticTargetCrosses)
	mux.HandleFunc("POST /v1/genetic/compare-actual", s.compareGeneticActual)
	mux.HandleFunc("GET /v1/genetic/feedback-summary", s.listGeneticFeedbackSummary)
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

type compareGeneticActualRequest struct {
	Series         string         `json:"series"`
	SirePhenotype  string         `json:"sire_phenotype"`
	DamPhenotype   string         `json:"dam_phenotype"`
	ActualCounts   map[string]int `json:"actual_counts"`
	Save           bool           `json:"save"`
	BreedingPlanID *string        `json:"breeding_plan_id"`
	LitterID       *string        `json:"litter_id"`
}

func (s *Server) compareGeneticActual(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request compareGeneticActualRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "回填对比请求体格式不正确"))
		return
	}
	basePrediction, err := geneticcore.SimulatePhenotypeTable(
		request.Series,
		request.SirePhenotype,
		request.DamPhenotype,
	)
	if err != nil {
		writeAPIError(w, r, validationError("actual_counts", err.Error()))
		return
	}
	phenotypeHistory, _, historyErr := s.loadPhenotypePairHistories(
		r.Context(), ownerID, basePrediction.Series, basePrediction.Sire, basePrediction.Dam, nil, nil,
	)
	if historyErr == nil {
		basePrediction = geneticcore.CalibratePhenotypeTable(
			basePrediction,
			phenotypeHistory,
			geneticcore.PhenotypeCalibrationHistory{},
		)
	}
	result, err := geneticcore.CompareActualToPrediction(basePrediction, request.ActualCounts)
	if err != nil {
		writeAPIError(w, r, validationError("actual_counts", err.Error()))
		return
	}
	var feedbackID *uuid.UUID
	if request.Save {
		orgID, orgErr := s.currentOrganizationID(r.Context(), ownerID)
		if orgErr != nil {
			writeAPIError(w, r, orgErr)
			return
		}
		var planID, litterID *uuid.UUID
		if request.BreedingPlanID != nil && strings.TrimSpace(*request.BreedingPlanID) != "" {
			id, parseErr := uuid.Parse(strings.TrimSpace(*request.BreedingPlanID))
			if parseErr != nil {
				writeAPIError(w, r, validationError("breeding_plan_id", "计划 ID 无效"))
				return
			}
			planID = &id
		}
		if request.LitterID != nil && strings.TrimSpace(*request.LitterID) != "" {
			id, parseErr := uuid.Parse(strings.TrimSpace(*request.LitterID))
			if parseErr != nil {
				writeAPIError(w, r, validationError("litter_id", "窝次 ID 无效"))
				return
			}
			litterID = &id
		}
		countsJSON, _ := json.Marshal(request.ActualCounts)
		rowsJSON, _ := json.Marshal(result.Rows)
		var id uuid.UUID
		err = s.Store.Pool.QueryRow(r.Context(), `
			INSERT INTO genetic_phenotype_feedback (
				owner_id, organization_id, breeding_plan_id, litter_id,
				series, sire_phenotype, dam_phenotype, total_actual,
				actual_counts, mean_abs_error, total_variation, compare_rows, notes
			) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9::jsonb,$10,$11,$12::jsonb,$13)
			RETURNING id
		`, ownerID, orgID, planID, litterID,
			result.Series, result.SirePhenotype, result.DamPhenotype, result.TotalActual,
			countsJSON, result.MeanAbsError, result.TotalVariation, rowsJSON, result.Notes,
		).Scan(&id)
		if err != nil {
			// 这次回填是后续历史校准的事实来源；写入失败不能伪装成成功，
			// 否则用户以为系统已经记住本窝，下一次预测却永远不会变准。
			writeAPIError(w, r, err)
			return
		}
		feedbackID = &id
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"comparison":  result,
			"feedback_id": feedbackID,
		},
		"meta": responseMeta(r),
	})
}

func (s *Server) listGeneticFeedbackSummary(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	rows, err := s.Store.Pool.Query(r.Context(), `
		WITH latest AS (
			SELECT DISTINCT ON (COALESCE(litter_id, breeding_plan_id, id))
				series,
				LEAST(sire_phenotype, dam_phenotype) AS parent_a,
				GREATEST(sire_phenotype, dam_phenotype) AS parent_b,
				total_actual, mean_abs_error, total_variation, created_at
			FROM genetic_phenotype_feedback
			WHERE owner_id=$1
			ORDER BY COALESCE(litter_id, breeding_plan_id, id), created_at DESC, id DESC
		)
		SELECT series, parent_a, parent_b,
			count(*)::int AS sample_count,
			avg(mean_abs_error) AS avg_mae,
			avg(total_variation) AS avg_tv,
			avg(total_actual::double precision) AS avg_litter_size,
			max(created_at) AS last_at
		FROM latest
		GROUP BY series, parent_a, parent_b
		ORDER BY avg(mean_abs_error) DESC, count(*) DESC
		LIMIT 100
	`, ownerID)
	if err != nil {
		// Empty summary if table missing.
		writeJSON(w, r, http.StatusOK, map[string]any{
			"data": map[string]any{
				"pairs": []any{},
				"notes": "暂无偏差统计（可能尚未迁移 genetic_phenotype_feedback）",
			},
			"meta": responseMeta(r),
		})
		return
	}
	defer rows.Close()
	type row struct {
		Series        string    `json:"series"`
		SirePhenotype string    `json:"sire_phenotype"`
		DamPhenotype  string    `json:"dam_phenotype"`
		SampleCount   int       `json:"sample_count"`
		AvgMAE        float64   `json:"avg_mean_abs_error"`
		AvgTV         float64   `json:"avg_total_variation"`
		AvgLitterSize float64   `json:"avg_litter_size"`
		LastAt        time.Time `json:"last_at"`
	}
	items := make([]row, 0)
	for rows.Next() {
		var item row
		if err := rows.Scan(
			&item.Series, &item.SirePhenotype, &item.DamPhenotype,
			&item.SampleCount, &item.AvgMAE, &item.AvgTV, &item.AvgLitterSize, &item.LastAt,
		); err != nil {
			writeAPIError(w, r, err)
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"pairs": items,
			"notes": "按公母表型聚合的历史回填偏差；avg_mean_abs_error 越大表示该组合实际偏离核心表期望越多。",
		},
		"meta": responseMeta(r),
	})
}

// simulateGeneticRequest supports two modes:
//   - phenotype_table (default when series + sire/dam phenotypes present): authority xlsx table
//   - mendel: simplified multi-locus genotype maps (legacy educational)
type simulateGeneticRequest struct {
	Mode            string            `json:"mode"`
	Series          string            `json:"series"`
	SirePhenotype   string            `json:"sire_phenotype"`
	DamPhenotype    string            `json:"dam_phenotype"`
	SireHamsterID   string            `json:"sire_hamster_id"`
	DamHamsterID    string            `json:"dam_hamster_id"`
	TargetPhenotype string            `json:"target_phenotype"` // optional: only used with list-style planning later
	Sire            map[string]string `json:"sire"`
	Dam             map[string]string `json:"dam"`
}

type phenotypeFeedbackObservation struct {
	SirePhenotype string
	DamPhenotype  string
	PlanSireID    string
	PlanDamID     string
	ActualCounts  map[string]int
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

// listGeneticPhenotypeCatalog exposes the authority phenotype table catalog (series + phenotypes).
func (s *Server) listGeneticPhenotypeCatalog(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.authenticateMemberOwner(w, r); !ok {
		return
	}
	doc, err := geneticcore.PhenotypeTableMeta()
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"id":      doc.ID,
			"title":   doc.Title,
			"version": doc.Version,
			"source":  doc.Source,
			"notes":   doc.Notes,
			"series":  doc.Series,
		},
		"meta": responseMeta(r),
	})
}

// listGeneticTargetCrosses ranks parent pairs that can produce a target phenotype.
// Query: series=poly&phenotype=蜜波利
func (s *Server) listGeneticTargetCrosses(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	series := strings.TrimSpace(r.URL.Query().Get("series"))
	phenotype := strings.TrimSpace(r.URL.Query().Get("phenotype"))
	if series == "" {
		writeAPIError(w, r, validationError("series", "系列必填"))
		return
	}
	if phenotype == "" {
		writeAPIError(w, r, validationError("phenotype", "目标表型必填"))
		return
	}
	seriesCode, err := geneticcore.ResolveSeriesCode(series)
	if err != nil {
		writeAPIError(w, r, validationError("series", err.Error()))
		return
	}
	crosses, err := geneticcore.FindCrossesForTarget(series, phenotype)
	if err != nil {
		writeAPIError(w, r, validationError("phenotype", err.Error()))
		return
	}
	histories, historyErr := s.loadPhenotypeSeriesHistories(r.Context(), ownerID, seriesCode)
	if historyErr != nil {
		// Keep authority-table target search available before the feedback
		// migration is applied or during a transient history read failure.
		histories = map[string]geneticcore.PhenotypeCalibrationHistory{}
	}
	type ranked struct {
		ParentA           string  `json:"parent_a"`
		ParentB           string  `json:"parent_b"`
		TargetProbability float64 `json:"target_probability"`
		TargetFraction    string  `json:"target_fraction,omitempty"`
		Outcomes          any     `json:"outcomes"`
		PredictionBasis   string  `json:"prediction_basis"`
		HistoryLitters    int     `json:"history_litter_count"`
		HistoryPups       int     `json:"history_pup_count"`
	}
	items := make([]ranked, 0, len(crosses))
	for _, c := range crosses {
		key := phenotypeFeedbackPairKey(c.ParentA, c.ParentB)
		c, basis, litterCount, pupCount := geneticcore.CalibratePhenotypeCross(c, histories[key])
		var p float64
		var frac string
		for _, o := range c.Outcomes {
			if o.Phenotype == phenotype {
				p = o.Probability
				frac = o.Fraction
				break
			}
		}
		items = append(items, ranked{
			ParentA:           c.ParentA,
			ParentB:           c.ParentB,
			TargetProbability: p,
			TargetFraction:    frac,
			Outcomes:          c.Outcomes,
			PredictionBasis:   basis,
			HistoryLitters:    litterCount,
			HistoryPups:       pupCount,
		})
	}
	sort.SliceStable(items, func(i, j int) bool {
		if items[i].TargetProbability != items[j].TargetProbability {
			return items[i].TargetProbability > items[j].TargetProbability
		}
		if items[i].ParentA != items[j].ParentA {
			return items[i].ParentA < items[j].ParentA
		}
		return items[i].ParentB < items[j].ParentB
	})
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": map[string]any{
			"series":           seriesCode,
			"target_phenotype": phenotype,
			"crosses":          items,
		},
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
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request simulateGeneticRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "模拟请求体格式不正确"))
		return
	}
	mode := strings.TrimSpace(request.Mode)
	if mode == "" {
		// Prefer authority phenotype table when phenotype fields are present.
		if strings.TrimSpace(request.SirePhenotype) != "" || strings.TrimSpace(request.DamPhenotype) != "" || strings.TrimSpace(request.Series) != "" {
			mode = "phenotype_table"
		} else {
			mode = "mendel"
		}
	}
	switch mode {
	case "phenotype_table", "table", "phenotype":
		tableResult, err := geneticcore.SimulatePhenotypeTable(request.Series, request.SirePhenotype, request.DamPhenotype)
		if err != nil {
			writeAPIError(w, r, validationError("phenotype", err.Error()))
			return
		}
		sireID, damID, err := parseOptionalHamsterPair(request.SireHamsterID, request.DamHamsterID)
		if err != nil {
			writeAPIError(w, r, validationError("sire_hamster_id/dam_hamster_id", err.Error()))
			return
		}
		phenotypeHistory, parentPairHistory, historyErr := s.loadPhenotypePairHistories(
			r.Context(), ownerID, tableResult.Series, tableResult.Sire, tableResult.Dam, sireID, damID,
		)
		if historyErr == nil {
			tableResult = geneticcore.CalibratePhenotypeTable(
				tableResult,
				phenotypeHistory,
				parentPairHistory,
			)
		}
		// Return both adapted SimulationResult shape and explicit table fields for clients.
		writeJSON(w, r, http.StatusOK, map[string]any{
			"data": phenotypeSimulationResponse(tableResult),
			"meta": responseMeta(r),
		})
	case "mendel", "genotype":
		result, err := geneticcore.Simulate(request.Sire, request.Dam)
		if err != nil {
			writeAPIError(w, r, validationError("genotype", err.Error()))
			return
		}
		writeJSON(w, r, http.StatusOK, map[string]any{"data": result, "meta": responseMeta(r)})
	default:
		writeAPIError(w, r, validationError("mode", "mode 须为 phenotype_table 或 mendel"))
	}
}

func phenotypeSimulationResponse(result geneticcore.PhenotypeTableResult) map[string]any {
	simulation := result.ToSimulationResult()
	return map[string]any{
		"mode":                 result.Mode,
		"table_id":             result.TableID,
		"table_version":        result.Version,
		"series":               result.Series,
		"series_name":          result.SeriesName,
		"sire_phenotype":       result.Sire,
		"dam_phenotype":        result.Dam,
		"sire":                 simulation.Sire,
		"dam":                  simulation.Dam,
		"outcomes":             simulation.Outcomes,
		"table_outcomes":       result.Outcomes,
		"prediction_basis":     result.PredictionBasis,
		"history_litter_count": result.HistoryLitterCount,
		"history_pup_count":    result.HistoryPupCount,
		"notes":                result.Notes,
	}
}

func parseOptionalHamsterPair(sireRaw, damRaw string) (*uuid.UUID, *uuid.UUID, error) {
	sireRaw = strings.TrimSpace(sireRaw)
	damRaw = strings.TrimSpace(damRaw)
	if sireRaw == "" && damRaw == "" {
		return nil, nil, nil
	}
	var sireID, damID uuid.UUID
	if sireRaw != "" {
		parsed, err := uuid.Parse(sireRaw)
		if err != nil {
			return nil, nil, errors.New("公鼠 ID 无效")
		}
		sireID = parsed
	}
	if damRaw != "" {
		parsed, err := uuid.Parse(damRaw)
		if err != nil {
			return nil, nil, errors.New("母鼠 ID 无效")
		}
		damID = parsed
	}
	// A single selected profile still gets phenotype-level calibration. Exact
	// parent-pair history only applies when both profile IDs are available.
	if sireRaw == "" || damRaw == "" {
		return nil, nil, nil
	}
	if sireID == damID {
		return nil, nil, errors.New("公鼠和母鼠 ID 不能相同")
	}
	return &sireID, &damID, nil
}

func (s *Server) loadPhenotypePairHistories(
	ctx context.Context,
	ownerID uuid.UUID,
	series, sirePhenotype, damPhenotype string,
	sireID, damID *uuid.UUID,
) (geneticcore.PhenotypeCalibrationHistory, geneticcore.PhenotypeCalibrationHistory, error) {
	phenotypeHistory := geneticcore.PhenotypeCalibrationHistory{Counts: map[string]int{}}
	parentPairHistory := geneticcore.PhenotypeCalibrationHistory{Counts: map[string]int{}}
	if s == nil || s.Store == nil || s.Store.Pool == nil {
		return phenotypeHistory, parentPairHistory, errors.New("genetic feedback database is unavailable")
	}

	rows, err := s.Store.Pool.Query(ctx, `
		WITH latest AS (
			SELECT DISTINCT ON (COALESCE(f.litter_id, f.breeding_plan_id, f.id))
				f.sire_phenotype, f.dam_phenotype, f.actual_counts,
				COALESCE(bp.sire_id::text, '') AS plan_sire_id,
				COALESCE(bp.dam_id::text, '') AS plan_dam_id
			FROM genetic_phenotype_feedback f
			LEFT JOIN breeding_plan bp
				ON bp.owner_id=f.owner_id AND bp.id=f.breeding_plan_id
			WHERE f.owner_id=$1 AND f.series=$2
				AND ((f.sire_phenotype=$3 AND f.dam_phenotype=$4)
					OR (f.sire_phenotype=$4 AND f.dam_phenotype=$3))
			ORDER BY COALESCE(f.litter_id, f.breeding_plan_id, f.id),
				f.created_at DESC, f.id DESC
		)
		SELECT sire_phenotype, dam_phenotype, actual_counts, plan_sire_id, plan_dam_id
		FROM latest
	`, ownerID, strings.TrimSpace(series), strings.TrimSpace(sirePhenotype), strings.TrimSpace(damPhenotype))
	if err != nil {
		return phenotypeHistory, parentPairHistory, err
	}
	defer rows.Close()

	for rows.Next() {
		var observation phenotypeFeedbackObservation
		var actualCountsJSON []byte
		if err := rows.Scan(
			&observation.SirePhenotype,
			&observation.DamPhenotype,
			&actualCountsJSON,
			&observation.PlanSireID,
			&observation.PlanDamID,
		); err != nil {
			return phenotypeHistory, parentPairHistory, err
		}
		observation.ActualCounts = decodePhenotypeActualCounts(actualCountsJSON)
		addPhenotypeFeedback(&phenotypeHistory, observation.ActualCounts)
		if sireID != nil && damID != nil &&
			observation.PlanSireID == sireID.String() && observation.PlanDamID == damID.String() {
			addPhenotypeFeedback(&parentPairHistory, observation.ActualCounts)
		}
	}
	if err := rows.Err(); err != nil {
		return phenotypeHistory, parentPairHistory, err
	}
	return phenotypeHistory, parentPairHistory, nil
}

func (s *Server) loadPhenotypeSeriesHistories(
	ctx context.Context,
	ownerID uuid.UUID,
	series string,
) (map[string]geneticcore.PhenotypeCalibrationHistory, error) {
	histories := map[string]geneticcore.PhenotypeCalibrationHistory{}
	if s == nil || s.Store == nil || s.Store.Pool == nil {
		return histories, errors.New("genetic feedback database is unavailable")
	}
	rows, err := s.Store.Pool.Query(ctx, `
		WITH latest AS (
			SELECT DISTINCT ON (COALESCE(f.litter_id, f.breeding_plan_id, f.id))
				f.sire_phenotype, f.dam_phenotype, f.actual_counts
			FROM genetic_phenotype_feedback f
			WHERE f.owner_id=$1 AND f.series=$2
			ORDER BY COALESCE(f.litter_id, f.breeding_plan_id, f.id),
				f.created_at DESC, f.id DESC
		)
		SELECT sire_phenotype, dam_phenotype, actual_counts
		FROM latest
	`, ownerID, strings.TrimSpace(series))
	if err != nil {
		return histories, err
	}
	defer rows.Close()

	for rows.Next() {
		var sirePhenotype, damPhenotype string
		var actualCountsJSON []byte
		if err := rows.Scan(&sirePhenotype, &damPhenotype, &actualCountsJSON); err != nil {
			return histories, err
		}
		key := phenotypeFeedbackPairKey(sirePhenotype, damPhenotype)
		history := histories[key]
		if history.Counts == nil {
			history.Counts = map[string]int{}
		}
		addPhenotypeFeedback(&history, decodePhenotypeActualCounts(actualCountsJSON))
		histories[key] = history
	}
	if err := rows.Err(); err != nil {
		return histories, err
	}
	return histories, nil
}

func addPhenotypeFeedback(history *geneticcore.PhenotypeCalibrationHistory, counts map[string]int) {
	if history.Counts == nil {
		history.Counts = map[string]int{}
	}
	history.LitterCount++
	for rawLabel, count := range counts {
		label := strings.TrimSpace(rawLabel)
		if label == "" || count <= 0 {
			continue
		}
		history.Counts[label] += count
	}
}

func decodePhenotypeActualCounts(raw []byte) map[string]int {
	counts := map[string]int{}
	var values map[string]json.RawMessage
	if err := json.Unmarshal(raw, &values); err != nil {
		return counts
	}
	for rawLabel, value := range values {
		label := strings.TrimSpace(rawLabel)
		if label == "" {
			continue
		}
		var count int
		if err := json.Unmarshal(value, &count); err != nil {
			var text string
			if json.Unmarshal(value, &text) != nil {
				continue
			}
			parsed, parseErr := strconv.Atoi(strings.TrimSpace(text))
			if parseErr != nil {
				continue
			}
			count = parsed
		}
		if count > 0 {
			counts[label] += count
		}
	}
	return counts
}

func phenotypeFeedbackPairKey(parentA, parentB string) string {
	parentA = strings.TrimSpace(parentA)
	parentB = strings.TrimSpace(parentB)
	if parentA > parentB {
		parentA, parentB = parentB, parentA
	}
	return parentA + "\x00" + parentB
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
