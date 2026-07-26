package httpapi

import (
	"errors"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

// Wave 1 correction loop for weight records. The i2core layer has always
// supported the corrects/reason pair; these freeze the HTTP contract that
// exposes it, so the reason can never become optional again.

func weightCorrectionRequest(corrects *uuid.UUID, reason *string) i2WeightCreateRequest {
	hamsterID := uuid.New()
	return i2WeightCreateRequest{
		HamsterID:              &hamsterID,
		MeasurementKind:        "individual",
		WeightG:                42.5,
		RecordedAt:             "2026-07-26T02:00:00Z",
		Source:                 "manual",
		CorrectsWeightRecordID: corrects,
		CorrectionReason:       reason,
	}
}

func TestWeightCorrectionRequiresReason(t *testing.T) {
	corrected := uuid.New()
	blank := "   "
	tooLong := strings.Repeat("x", 501)
	cases := []struct {
		name   string
		reason *string
	}{
		{"missing", nil},
		{"blank", &blank},
		{"too long", &tooLong},
	}
	for _, tc := range cases {
		_, err := weightCorrectionRequest(&corrected, tc.reason).coreInput()
		if err == nil {
			t.Fatalf("%s: correction without a usable reason must be rejected", tc.name)
		}
	}
}

func TestWeightCorrectionAcceptsReasonAndTrimsIt(t *testing.T) {
	corrected := uuid.New()
	reason := "  上称时读数看错，实际 42.5g  "
	input, err := weightCorrectionRequest(&corrected, &reason).coreInput()
	if err != nil {
		t.Fatalf("valid correction rejected: %v", err)
	}
	if input.CorrectsWeightRecordID == nil || *input.CorrectsWeightRecordID != corrected {
		t.Fatal("corrects_weight_record_id was not carried into the core input")
	}
	if input.CorrectionReason == nil || *input.CorrectionReason != "上称时读数看错，实际 42.5g" {
		t.Fatalf("correction reason not trimmed: %v", input.CorrectionReason)
	}
}

// A plain record keeps working with no correction fields — the chain is opt-in.
func TestWeightRecordWithoutCorrectionStaysUnchanged(t *testing.T) {
	input, err := weightCorrectionRequest(nil, nil).coreInput()
	if err != nil {
		t.Fatalf("plain weight record rejected: %v", err)
	}
	if input.CorrectsWeightRecordID != nil || input.CorrectionReason != nil {
		t.Fatal("non-correction record must not carry correction fields")
	}
}

func TestWeightCorrectionRejectsNilTargetID(t *testing.T) {
	empty := uuid.Nil
	reason := "原因充分"
	if _, err := weightCorrectionRequest(&empty, &reason).coreInput(); err == nil {
		t.Fatal("all-zero corrects_weight_record_id must be rejected")
	}
}

func TestTaskCorrectionRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerI5Routes(mux)
	for _, path := range []string{
		"/v1/tasks/018f47a2-96a7-7e37-a202-cefdc69456ce/cancel",
		"/v1/tasks/018f47a2-96a7-7e37-a202-cefdc69456ce/reopen",
	} {
		recorder := httptest.NewRecorder()
		mux.ServeHTTP(recorder, httptest.NewRequest(http.MethodPost, path, strings.NewReader(`{"reason":"x"}`)))
		if recorder.Code != http.StatusUnauthorized {
			t.Fatalf("POST %s expected 401, got %d", path, recorder.Code)
		}
	}
}

func TestWeightCorrectionErrorMentionsReasonField(t *testing.T) {
	corrected := uuid.New()
	_, err := weightCorrectionRequest(&corrected, nil).coreInput()
	if err == nil {
		t.Fatal("expected an error")
	}
	var apiErr *apiError
	if !errors.As(err, &apiErr) {
		t.Fatalf("expected an apiError so the client can show the field, got %T", err)
	}
}
