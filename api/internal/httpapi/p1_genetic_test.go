package httpapi

import (
	"bytes"
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/geneticcore"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func TestP1GeneticRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1GeneticRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/genetic/loci"},
		{http.MethodGet, "/v1/genetic/phenotype-catalog"},
		{http.MethodGet, "/v1/genetic/target-crosses"},
		{http.MethodPost, "/v1/genetic/compare-actual"},
		{http.MethodGet, "/v1/genetic/feedback-summary"},
		{http.MethodGet, "/v1/genetic/profiles"},
		{http.MethodPost, "/v1/genetic/profiles"},
		{http.MethodPost, "/v1/genetic/simulate"},
	}
	for _, test := range paths {
		recorder := httptest.NewRecorder()
		request := httptest.NewRequest(test.method, test.path, nil)
		mux.ServeHTTP(recorder, request)
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("%s %s expected 401, got %d", test.method, test.path, recorder.Code)
		}
	}
}

func TestPhenotypeSimulationResponseUsesCalibratedProbabilitiesAndMetadata(t *testing.T) {
	base, err := geneticcore.SimulatePhenotypeTable("poly", "蜜波利", "蜜波利")
	if err != nil {
		t.Fatal(err)
	}
	calibrated := geneticcore.CalibratePhenotypeTable(
		base,
		geneticcore.PhenotypeCalibrationHistory{
			LitterCount: 2,
			Counts: map[string]int{
				"蜜波利":  4,
				"黑蜜波利": 4,
			},
		},
		geneticcore.PhenotypeCalibrationHistory{},
	)
	data := phenotypeSimulationResponse(calibrated)
	if data["prediction_basis"] != geneticcore.PredictionBasisAuthorityPlusHistory {
		t.Fatalf("prediction_basis=%v", data["prediction_basis"])
	}
	if data["history_litter_count"] != 2 || data["history_pup_count"] != 8 {
		t.Fatalf("history=%v litters/%v pups", data["history_litter_count"], data["history_pup_count"])
	}

	outcomes, ok := data["outcomes"].([]geneticcore.Outcome)
	if !ok {
		t.Fatalf("outcomes type=%T", data["outcomes"])
	}
	tableOutcomes, ok := data["table_outcomes"].([]geneticcore.PhenotypeOutcome)
	if !ok {
		t.Fatalf("table_outcomes type=%T", data["table_outcomes"])
	}
	byLabel := map[string]float64{}
	for _, outcome := range tableOutcomes {
		byLabel[outcome.Phenotype] = outcome.Probability
	}
	for _, outcome := range outcomes {
		if got, want := outcome.Probability, byLabel[outcome.PhenotypeLabel]; got != want {
			t.Fatalf("%s outcomes probability=%v table_outcomes=%v", outcome.PhenotypeLabel, got, want)
		}
	}
}

func TestSimulatePhenotypeTableFallsBackToAuthorityWithoutFeedbackStore(t *testing.T) {
	authService := auth.New("test", "123456")
	accountID := uuid.New()
	token, _, err := authService.CreateSession(context.Background(), accountID)
	if err != nil {
		t.Fatal(err)
	}
	server := NewServer(nil, authService, slog.Default())
	mux := http.NewServeMux()
	server.registerP1GeneticRoutes(mux)
	body := []byte(`{
		"mode":"phenotype_table",
		"series":"poly",
		"sire_phenotype":"蜜波利",
		"dam_phenotype":"蜜波利"
	}`)
	request := httptest.NewRequest(http.MethodPost, "/v1/genetic/simulate", bytes.NewReader(body))
	request.Header.Set("Authorization", "Bearer "+token)
	request = request.WithContext(context.WithValue(
		request.Context(),
		requestPrincipalContextKey{},
		store.Principal{
			AccountID: accountID,
			OwnerID:   accountID,
			Role:      "owner",
		},
	))
	recorder := httptest.NewRecorder()
	mux.ServeHTTP(recorder, request)
	if recorder.Code != http.StatusOK {
		t.Fatalf("status=%d body=%s", recorder.Code, recorder.Body.String())
	}
	var response struct {
		Data struct {
			PredictionBasis    string `json:"prediction_basis"`
			HistoryLitterCount int    `json:"history_litter_count"`
			HistoryPupCount    int    `json:"history_pup_count"`
			Outcomes           []struct {
				Probability float64 `json:"probability"`
			} `json:"outcomes"`
		} `json:"data"`
	}
	if err := json.Unmarshal(recorder.Body.Bytes(), &response); err != nil {
		t.Fatal(err)
	}
	if response.Data.PredictionBasis != geneticcore.PredictionBasisAuthorityTable {
		t.Fatalf("basis=%s", response.Data.PredictionBasis)
	}
	if response.Data.HistoryLitterCount != 0 || response.Data.HistoryPupCount != 0 {
		t.Fatalf("history=%d/%d", response.Data.HistoryLitterCount, response.Data.HistoryPupCount)
	}
	if len(response.Data.Outcomes) != 2 {
		t.Fatalf("outcomes=%d", len(response.Data.Outcomes))
	}
}

func TestDecodePhenotypeActualCountsSkipsInvalidValues(t *testing.T) {
	got := decodePhenotypeActualCounts([]byte(`{
		"蜜波利": 4,
		"黑蜜波利": "2",
		"负数": -1,
		"小数": 1.5,
		"坏值": true
	}`))
	if got["蜜波利"] != 4 || got["黑蜜波利"] != 2 {
		t.Fatalf("counts=%+v", got)
	}
	if _, ok := got["负数"]; ok {
		t.Fatalf("negative count was retained: %+v", got)
	}
	if _, ok := got["小数"]; ok {
		t.Fatalf("fractional count was retained: %+v", got)
	}
}

func TestParseOptionalHamsterPairAllowsOneSelectedProfile(t *testing.T) {
	sire := uuid.NewString()
	sireID, damID, err := parseOptionalHamsterPair(sire, "")
	if err != nil {
		t.Fatal(err)
	}
	if sireID != nil || damID != nil {
		t.Fatalf("single profile should not enable exact-pair history: %v/%v", sireID, damID)
	}
	if _, _, err := parseOptionalHamsterPair("not-a-uuid", ""); err == nil {
		t.Fatal("malformed non-empty profile ID should be rejected")
	}
}
