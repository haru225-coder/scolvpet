package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/entitlementcore"
)

func (s *Server) registerP1EntitlementRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /v1/entitlements/catalog", s.getEntitlementCatalog)
	mux.HandleFunc("GET /v1/entitlements/current", s.getCurrentEntitlement)
	mux.HandleFunc("POST /v1/entitlements/check", s.checkEntitlement)
	// Production must never expose self-serve sandbox activation.
	if s.sandboxEntitlementsEnabled() {
		mux.HandleFunc("POST /v1/entitlements/sandbox/activate", s.sandboxActivatePlan)
	}
}

func (s *Server) sandboxEntitlementsEnabled() bool {
	env := strings.ToLower(strings.TrimSpace(s.Environment))
	if env == "" {
		// Unit tests / local construction without Environment: keep sandbox for
		// development ergonomics, but main always sets Environment from APP_ENV.
		return true
	}
	return env != "production"
}

type entitlementCheckRequest struct {
	Feature string `json:"feature"`
	Metric  string `json:"metric"`
}

type sandboxActivateRequest struct {
	PlanCode string `json:"plan_code"`
}

func (s *Server) getEntitlementCatalog(w http.ResponseWriter, r *http.Request) {
	if _, ok := s.authenticateMemberOwner(w, r); !ok {
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{
		"data": entitlementcore.DefaultCatalog(),
		"meta": responseMeta(r),
	})
}

func (s *Server) getCurrentEntitlement(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	snap, err := s.loadEntitlementSnapshot(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": snap, "meta": responseMeta(r)})
}

func (s *Server) checkEntitlement(w http.ResponseWriter, r *http.Request) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request entitlementCheckRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "校验请求体格式不正确"))
		return
	}
	if strings.TrimSpace(request.Feature) == "" && strings.TrimSpace(request.Metric) == "" {
		writeAPIError(w, r, validationError("feature", "feature 或 metric 至少填一项"))
		return
	}
	snap, err := s.loadEntitlementSnapshot(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	var result entitlementcore.CheckResult
	if strings.TrimSpace(request.Feature) != "" {
		result = entitlementcore.CheckFeature(snap, request.Feature)
	} else {
		result = entitlementcore.CheckMetric(snap, request.Metric)
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": result, "meta": responseMeta(r)})
}

func (s *Server) sandboxActivatePlan(w http.ResponseWriter, r *http.Request) {
	if !s.sandboxEntitlementsEnabled() {
		writeAPIError(w, r, &apiError{Status: http.StatusNotFound, Code: "RESOURCE_NOT_FOUND", Message: "资源不存在"})
		return
	}
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	var request sandboxActivateRequest
	if _, err := decodeBody(r, &request); err != nil {
		writeAPIError(w, r, validationError("body", "激活请求体格式不正确"))
		return
	}
	planCode := strings.TrimSpace(request.PlanCode)
	if planCode == "" {
		planCode = entitlementcore.PlanPro
	}
	if _, ok := entitlementcore.CatalogByCode(planCode); !ok {
		writeAPIError(w, r, validationError("plan_code", "未知套餐"))
		return
	}
	if err := s.writePlanEntitlements(r.Context(), ownerID, planCode, "sandbox"); err != nil {
		writeAPIError(w, r, err)
		return
	}
	snap, err := s.loadEntitlementSnapshot(r.Context(), ownerID)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	writeJSON(w, r, http.StatusOK, map[string]any{"data": snap, "meta": responseMeta(r)})
}

func (s *Server) loadEntitlementSnapshot(ctx context.Context, ownerID uuid.UUID) (entitlementcore.Snapshot, error) {
	usage, err := s.loadUsageMap(ctx, ownerID)
	if err != nil {
		return entitlementcore.Snapshot{}, err
	}
	planCode, source, effectiveAt, expiresAt, features, limits, err := s.readStoredPlan(ctx, ownerID)
	if err != nil {
		return entitlementcore.Snapshot{}, err
	}
	if planCode == "" {
		planCode = entitlementcore.PlanFree
		source = "system"
		effectiveAt = time.Now().UTC()
		// Best-effort seed free plan rows so subsequent reads are stable.
		_ = s.writePlanEntitlements(ctx, ownerID, planCode, source)
	}
	return entitlementcore.BuildSnapshot(planCode, source, effectiveAt, expiresAt, usage, features, limits), nil
}

func (s *Server) loadUsageMap(ctx context.Context, ownerID uuid.UUID) (map[string]float64, error) {
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT metric::text, current_value::float8
		FROM usage_meter
		WHERE owner_id=$1
	`, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string]float64{}
	for rows.Next() {
		var metric string
		var value float64
		if err := rows.Scan(&metric, &value); err != nil {
			return nil, err
		}
		out[metric] = value
	}
	return out, nil
}

func (s *Server) readStoredPlan(ctx context.Context, ownerID uuid.UUID) (
	planCode, source string,
	effectiveAt time.Time,
	expiresAt *time.Time,
	features map[string]bool,
	limits map[string]*float64,
	err error,
) {
	features = map[string]bool{}
	limits = map[string]*float64{}
	rows, err := s.Store.Pool.Query(ctx, `
		SELECT entitlement_code, value_type::text, boolean_value, integer_value::float8,
			source, effective_at, expires_at
		FROM entitlement
		WHERE owner_id=$1 AND revoked_at IS NULL
		  AND effective_at <= now()
		  AND (expires_at IS NULL OR expires_at > now())
	`, ownerID)
	if err != nil {
		return "", "", time.Time{}, nil, nil, nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var code, valueType, rowSource string
		var boolVal *bool
		var intVal *float64
		var eff time.Time
		var exp *time.Time
		if err := rows.Scan(&code, &valueType, &boolVal, &intVal, &rowSource, &eff, &exp); err != nil {
			return "", "", time.Time{}, nil, nil, nil, err
		}
		switch {
		case code == entitlementcore.PlanCodeEntitlement && valueType == "json":
			// plan stored as integer 0 free / 1 pro fallback path below
		case code == entitlementcore.PlanCodeEntitlement && valueType == "boolean" && boolVal != nil:
			if *boolVal {
				planCode = entitlementcore.PlanPro
			} else {
				planCode = entitlementcore.PlanFree
			}
			source = rowSource
			effectiveAt = eff
			expiresAt = exp
		case strings.HasPrefix(code, "feature.") && valueType == "boolean" && boolVal != nil:
			features[code] = *boolVal
		case strings.HasPrefix(code, "limit.") && valueType == "integer" && intVal != nil:
			metric := strings.TrimPrefix(code, "limit.")
			v := *intVal
			limits[metric] = &v
		case code == "plan.code" && valueType == "integer" && intVal != nil:
			if *intVal >= 1 {
				planCode = entitlementcore.PlanPro
			} else {
				planCode = entitlementcore.PlanFree
			}
			source = rowSource
			effectiveAt = eff
			expiresAt = exp
		}
	}
	// Prefer dedicated string via integer encoding: also support boolean plan.pro
	if planCode == "" {
		var pro bool
		err = s.Store.Pool.QueryRow(ctx, `
			SELECT COALESCE(boolean_value, false)
			FROM entitlement
			WHERE owner_id=$1 AND entitlement_code='plan.pro' AND revoked_at IS NULL
			  AND effective_at <= now()
			  AND (expires_at IS NULL OR expires_at > now())
			LIMIT 1
		`, ownerID).Scan(&pro)
		if err == nil {
			if pro {
				planCode = entitlementcore.PlanPro
			} else {
				planCode = entitlementcore.PlanFree
			}
			source = "system"
			effectiveAt = time.Now().UTC()
		} else if !errors.Is(err, pgx.ErrNoRows) {
			return "", "", time.Time{}, nil, nil, nil, err
		} else {
			err = nil
		}
	}
	return planCode, source, effectiveAt, expiresAt, features, limits, nil
}

func (s *Server) writePlanEntitlements(ctx context.Context, ownerID uuid.UUID, planCode, source string) error {
	plan, ok := entitlementcore.CatalogByCode(planCode)
	if !ok {
		return validationError("plan_code", "未知套餐")
	}
	// Revoke previous active plan markers.
	_, err := s.Store.Pool.Exec(ctx, `
		UPDATE entitlement
		SET revoked_at=now(), updated_at=now(), version=version+1
		WHERE owner_id=$1 AND revoked_at IS NULL
		  AND entitlement_code IN ('plan.pro', 'plan.code')
	`, ownerID)
	if err != nil {
		return err
	}
	// Also revoke feature/limit rows we manage so catalog re-applies cleanly.
	_, err = s.Store.Pool.Exec(ctx, `
		UPDATE entitlement
		SET revoked_at=now(), updated_at=now(), version=version+1
		WHERE owner_id=$1 AND revoked_at IS NULL
		  AND (entitlement_code LIKE 'feature.%' OR entitlement_code LIKE 'limit.%')
	`, ownerID)
	if err != nil {
		return err
	}

	isPro := planCode == entitlementcore.PlanPro
	_, err = s.Store.Pool.Exec(ctx, `
		INSERT INTO entitlement (
			owner_id, entitlement_code, value_type, boolean_value, source, effective_at
		) VALUES ($1,'plan.pro','boolean',$2,$3,now())
	`, ownerID, isPro, source)
	if err != nil {
		return err
	}
	// Integer plan.code: 0 free, 1 pro (readable without boolean semantics).
	planInt := 0
	if isPro {
		planInt = 1
	}
	_, err = s.Store.Pool.Exec(ctx, `
		INSERT INTO entitlement (
			owner_id, entitlement_code, value_type, integer_value, source, effective_at
		) VALUES ($1,'plan.code','integer',$2,$3,now())
	`, ownerID, planInt, source)
	if err != nil {
		return err
	}
	for code, allowed := range plan.Features {
		_, err = s.Store.Pool.Exec(ctx, `
			INSERT INTO entitlement (
				owner_id, entitlement_code, value_type, boolean_value, source, effective_at
			) VALUES ($1,$2,'boolean',$3,$4,now())
		`, ownerID, code, allowed, source)
		if err != nil {
			return err
		}
	}
	for metric, lim := range plan.Limits {
		_, err = s.Store.Pool.Exec(ctx, `
			INSERT INTO entitlement (
				owner_id, entitlement_code, value_type, integer_value, source, effective_at
			) VALUES ($1,$2,'integer',$3,$4,now())
		`, ownerID, "limit."+metric, int64(lim), source)
		if err != nil {
			return err
		}
	}
	return nil
}
