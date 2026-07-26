package httpapi

import (
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestDocumentPartyConflictMessages(t *testing.T) {
	cases := []struct {
		field   string
		message string
	}{
		{"contact_id", "合同客户必须与预订客户一致"},
		{"handover_id", "交付单必须绑定预订，不能关联 reservation_id 为空的交付单"},
		{"handover_id", "交付单必须属于同一预订"},
		{"handover_id", "交付单客户必须与预订客户一致"},
		{"handover_id", "交付单仓鼠必须与预订仓鼠一致"},
	}
	for _, tc := range cases {
		if conflictError(tc.field, tc.message) == nil {
			t.Fatalf("expected error for %s / %s", tc.field, tc.message)
		}
	}
}

// Freeze bindDocumentParties rules against the real source file so renames regress.
// End-to-end: scripts/public-reservation-smoke.sh (cross contact, fake hamster_name).
func TestBindDocumentPartiesSourceRules(t *testing.T) {
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller failed")
	}
	srcPath := filepath.Join(filepath.Dir(thisFile), "p1_contracts.go")
	raw, err := os.ReadFile(srcPath)
	if err != nil {
		t.Fatalf("read p1_contracts.go: %v", err)
	}
	src := string(raw)
	// Locate bindDocumentParties body roughly.
	idx := strings.Index(src, "func (s *Server) bindDocumentParties")
	if idx < 0 {
		t.Fatal("bindDocumentParties not found")
	}
	body := src[idx:]
	if end := strings.Index(body, "\nfunc (s *Server) getDocHandoverContext"); end > 0 {
		body = body[:end]
	}
	required := []string{
		"合同客户必须与预订客户一致",
		"交付单必须绑定预订，不能关联 reservation_id 为空的交付单",
		"交付单必须属于同一预订",
		"交付单客户必须与预订客户一致",
		"交付单仓鼠必须与预订仓鼠一致",
		"out.HamsterName = resCtx.HamsterName",
		"handReservation == nil",
		"*handReservation != *input.ReservationID",
	}
	for _, r := range required {
		if !strings.Contains(body, r) {
			t.Fatalf("bindDocumentParties missing rule/marker: %q", r)
		}
	}
}

func TestDocumentPartyInputShape(t *testing.T) {
	rid := uuid.New()
	in := documentPartyInput{
		ReservationID: &rid,
		HamsterName:   "客户端伪造仓鼠名",
	}
	if in.ReservationID == nil || in.HamsterName == "" {
		t.Fatal("fixture")
	}
}
