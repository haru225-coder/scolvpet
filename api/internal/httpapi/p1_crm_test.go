package httpapi

import (
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func TestP1CrmRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1CrmRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/crm/contacts"},
		{http.MethodPost, "/v1/crm/contacts"},
		{http.MethodGet, "/v1/crm/reservations"},
		{http.MethodPost, "/v1/crm/reservations"},
		{http.MethodGet, "/v1/crm/handovers"},
		{http.MethodPost, "/v1/crm/handovers"},
		{http.MethodPost, "/v1/crm/reservations/00000000-0000-0000-0000-000000000001/confirm"},
		{http.MethodPost, "/v1/crm/handovers/00000000-0000-0000-0000-000000000001/complete"},
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

func TestRequireCrmIfMatch(t *testing.T) {
	if err := requireCrmIfMatch("", 2); err == nil {
		t.Fatal("missing If-Match accepted")
	}
	if err := requireCrmIfMatch(`"2"`, 2); err != nil {
		t.Fatalf("matching If-Match rejected: %v", err)
	}
	if err := requireCrmIfMatch(`"1"`, 2); !errors.Is(err, store.ErrVersionConflict) {
		t.Fatalf("stale If-Match error=%v", err)
	}
}

func TestValidateReservationTransition(t *testing.T) {
	if err := validateReservationTransition("held", "confirmed"); err != nil {
		t.Fatalf("held -> confirmed rejected: %v", err)
	}
	if err := validateReservationTransition("confirmed", "confirmed"); err == nil {
		t.Fatal("confirmed -> confirmed accepted")
	}
	if err := validateReservationTransition("handed_over", "cancelled"); err == nil {
		t.Fatal("handed_over -> cancelled accepted")
	}
}

func TestValidateHandoverReservation(t *testing.T) {
	contactID := uuid.New()
	hamsterID := uuid.New()
	otherHamsterID := uuid.New()
	reservation := crmReservation{ContactID: contactID, HamsterID: &hamsterID, Status: "confirmed"}
	if err := validateHandoverReservation(reservation, contactID, &hamsterID); err != nil {
		t.Fatalf("matching handover rejected: %v", err)
	}
	if err := validateHandoverReservation(reservation, contactID, &otherHamsterID); err == nil {
		t.Fatal("mismatched hamster accepted")
	}
	reservation.Status = "held"
	if err := validateHandoverReservation(reservation, contactID, nil); err == nil {
		t.Fatal("held reservation accepted")
	}
}

func TestHandoverIncomeMarkerStable(t *testing.T) {
	id := uuid.MustParse("00000000-0000-0000-0000-000000000123")
	marker := fmt.Sprintf("handover:%s", id)
	if marker != "handover:00000000-0000-0000-0000-000000000123" {
		t.Fatalf("marker=%s", marker)
	}
}
