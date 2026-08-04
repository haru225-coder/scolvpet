package httpapi

import (
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/store"
)

func TestP1MemberRoutesRequireAuth(t *testing.T) {
	server := NewServer(nil, auth.New("test", "123456"), slog.Default())
	mux := http.NewServeMux()
	server.registerP1MemberRoutes(mux)
	paths := []struct {
		method string
		path   string
	}{
		{http.MethodGet, "/v1/organization-members"},
		{http.MethodPost, "/v1/organization-members"},
		{http.MethodPatch, "/v1/organization-members/00000000-0000-0000-0000-000000000001"},
		{http.MethodPost, "/v1/organization-members/00000000-0000-0000-0000-000000000001/revoke"},
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

func TestNormalizeMemberPhoneAndRoles(t *testing.T) {
	if got := normalizeMemberPhone("+8613800138000"); got != "13800138000" {
		t.Fatalf("phone = %q", got)
	}
	if !validMemberRole("breeder") || validMemberRole("admin") {
		t.Fatal("role validation failed")
	}
}

func TestValidateMemberIfMatch(t *testing.T) {
	if err := validateMemberIfMatch("", 3); err != nil {
		t.Fatalf("optional If-Match rejected: %v", err)
	}
	if err := validateMemberIfMatch(`W/"3"`, 3); err != nil {
		t.Fatalf("matching If-Match rejected: %v", err)
	}
	if err := validateMemberIfMatch("bad", 3); err == nil {
		t.Fatal("invalid If-Match accepted")
	}
	if err := validateMemberIfMatch(`"2"`, 3); !errors.Is(err, store.ErrVersionConflict) {
		t.Fatalf("stale If-Match error=%v", err)
	}
}

// isUniqueViolation 只凭 pgconn.PgError 的 SQLSTATE(23505/23P01)判定,
// 且必须穿透包装链,不依赖错误文本。
func TestIsUniqueViolationBySQLSTATE(t *testing.T) {
	cases := []struct {
		name string
		err  error
		want bool
	}{
		{
			name: "23505 unique_violation",
			err:  &pgconn.PgError{Code: "23505"},
			want: true,
		},
		{
			name: "23P01 exclude_violation",
			err:  &pgconn.PgError{Code: "23P01"},
			want: true,
		},
		{
			name: "non-unique SQLSTATE not matched",
			err:  &pgconn.PgError{Code: "23503"},
			want: false,
		},
		{
			name: "wrapped PgError still matched",
			err:  fmt.Errorf("tx failed: %w", &pgconn.PgError{Code: "23505"}),
			want: true,
		},
		{
			name: "nil error",
			err:  nil,
			want: false,
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := isUniqueViolation(tc.err); got != tc.want {
				t.Fatalf("isUniqueViolation(%v) = %v, want %v", tc.err, got, tc.want)
			}
		})
	}
}

// 同样的文本若来自非 PgError,不再被当作唯一键冲突——证明判定不靠文本嗅探。
func TestIsUniqueViolationNotTextSniffed(t *testing.T) {
	if isUniqueViolation(errors.New(`duplicate key value violates unique constraint "some_unique_index"`)) {
		t.Fatal("text-only duplicate must not be treated as unique violation")
	}
}
