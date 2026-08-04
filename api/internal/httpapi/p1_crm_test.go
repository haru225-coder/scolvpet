package httpapi

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

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
		{http.MethodGet, "/v1/crm/contacts/00000000-0000-0000-0000-000000000001"},
		{http.MethodGet, "/v1/crm/reservations"},
		{http.MethodPost, "/v1/crm/reservations"},
		{http.MethodGet, "/v1/crm/reservations/00000000-0000-0000-0000-000000000001"},
		{http.MethodGet, "/v1/crm/handovers"},
		{http.MethodPost, "/v1/crm/handovers"},
		{http.MethodGet, "/v1/crm/handovers/00000000-0000-0000-0000-000000000001"},
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

// crmReservationFakeTx 只实现 createCrmReservationTx 实际会用到的 QueryRow;
// 其余 pgx.Tx 方法由内嵌的 nil 接口动态分发,测试路径不会走到。
type crmReservationFakeTx struct {
	pgx.Tx
	scanErr error
}

func (t *crmReservationFakeTx) QueryRow(ctx context.Context, sql string, args ...any) pgx.Row {
	return crmReservationFakeRow{err: t.scanErr}
}

type crmReservationFakeRow struct {
	err error
}

func (r crmReservationFakeRow) Scan(dest ...any) error { return r.err }

// createCrmReservationTx 的 INSERT 兜底只认 pgconn.PgError 的
// SQLSTATE(23505)+ 目标约束名,命中后映射为 hamster_id 冲突;
// 不再靠索引名/duplicate 文本嗅探。
func TestCreateCrmReservationTxUniqueFallbackBySQLSTATEAndConstraint(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())

	run := func(scanErr error) (uuid.UUID, error) {
		return server.createCrmReservationTx(
			context.Background(),
			&crmReservationFakeTx{scanErr: scanErr},
			uuid.New(), uuid.New(),
			createCrmReservationInput{ContactID: uuid.New()},
		)
	}

	// 命中:23505 + 目标约束名 → CONFLICT(hamster_id)。
	id, err := run(&pgconn.PgError{Code: "23505", ConstraintName: "ux_crm_reservation_open_hamster"})
	if id != uuid.Nil {
		t.Fatalf("expected nil id on conflict, got %v", id)
	}
	var apiErr *apiError
	if !errors.As(err, &apiErr) || apiErr.Code != "CONFLICT" {
		t.Fatalf("expected CONFLICT apiError, got %v", err)
	}
	if field, _ := apiErr.Details["field"].(string); field != "hamster_id" {
		t.Fatalf("conflict field=%q want hamster_id", field)
	}
	if apiErr.Message != "该仓鼠已被预订，请选择其他个体" {
		t.Fatalf("conflict message=%q", apiErr.Message)
	}

	// 同一 SQLSTATE 但约束名不同 → 不兜底,原样返回原错误。
	other := &pgconn.PgError{Code: "23505", ConstraintName: "ux_another_index"}
	if id, err = run(other); err == nil || !errors.Is(err, other) {
		t.Fatalf("expected original PgError back, got id=%v err=%v", id, err)
	}

	// 纯文本嗅探不再生效:同文本的普通错误原样返回。
	text := errors.New(`duplicate key value violates unique constraint "ux_crm_reservation_open_hamster"`)
	if id, err = run(text); err == nil || !errors.Is(err, text) {
		t.Fatalf("expected original text error back, got id=%v err=%v", id, err)
	}
}
