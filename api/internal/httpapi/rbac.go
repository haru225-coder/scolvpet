package httpapi

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"github.com/scolvpet/scolvpet/api/internal/store"
)

type requestPrincipalContextKey struct{}

func (s *Server) rbacMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if rbacExemptPath(r.URL.Path) {
			next.ServeHTTP(w, r)
			return
		}
		value := strings.TrimSpace(r.Header.Get("Authorization"))
		if value == "" {
			next.ServeHTTP(w, r)
			return
		}
		if len(value) < 8 || !strings.EqualFold(value[:7], "Bearer ") {
			writeAPIError(w, r, authRequired())
			return
		}
		token := strings.TrimSpace(value[7:])
		accountID, err := s.Auth.ParseAccessTokenContext(r.Context(), token)
		if err != nil {
			writeAPIError(w, r, authRequired())
			return
		}
		principal, err := s.resolveRequestPrincipal(r, accountID)
		if err != nil {
			if errors.Is(err, store.ErrNotFound) {
				writeAPIError(w, r, authRequired())
			} else {
				writeAPIError(w, r, err)
			}
			return
		}
		if !principalCanRequest(principal.Role, r.Method, r.URL.Path) {
			writeAPIError(w, r, permissionDenied(principal.Role))
			return
		}
		ctx := context.WithValue(
			r.Context(),
			requestPrincipalContextKey{},
			principal,
		)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func principalFromRequest(r *http.Request) (store.Principal, bool) {
	principal, ok := r.Context().Value(requestPrincipalContextKey{}).(store.Principal)
	return principal, ok
}

func (s *Server) resolveRequestPrincipal(
	r *http.Request,
	accountID uuid.UUID,
) (store.Principal, error) {
	if principal, ok := principalFromRequest(r); ok {
		return principal, nil
	}
	return s.Store.ResolvePrincipal(r.Context(), accountID)
}

func rbacExemptPath(path string) bool {
	return path == "/healthz" ||
		path == "/readyz" ||
		strings.HasPrefix(path, "/v1/auth/") ||
		strings.HasPrefix(path, "/v1/public/") ||
		// Customer bearer (ct_*) is authenticated inside handlers, not staff RBAC.
		strings.HasPrefix(path, "/v1/customer/")
}

func principalCanRequest(role, method, path string) bool {
	if method == http.MethodGet || method == http.MethodHead || method == http.MethodOptions {
		// Read access is not equivalent to access to every projection. Viewer
		// accounts may inspect operational records, but must not enumerate
		// customer PII, financial records, document capability tokens, member
		// rosters, or export/backup metadata.
		if role == "viewer" {
			return !pathContainsAny(path,
				"/v1/contracts", "/v1/receipts", "/v1/accounting",
				"/v1/crm", "/v1/organization-members", "/v1/data-center",
			)
		}
		return knownPrincipalRole(role)
	}
	if path == "/v1/auth/sessions/current" && method == http.MethodDelete {
		return true
	}
	if role == "owner" {
		return true
	}
	if role == "viewer" {
		return false
	}
	if strings.HasPrefix(path, "/v1/organization-members") ||
		strings.HasPrefix(path, "/v1/organizations/") ||
		strings.HasPrefix(path, "/v1/species-rule-versions") ||
		strings.Contains(path, "/imports") ||
		strings.HasPrefix(path, "/v1/entitlements") {
		return false
	}
	if strings.HasPrefix(path, "/v1/push/devices") {
		return true
	}
	if strings.HasPrefix(path, "/v1/wechat/subscriptions") {
		return role != "viewer"
	}

	switch role {
	case "breeder":
		return pathContainsAny(path,
			"/breeding-plans", "/pairing", "/litters", "/hamsters",
			"/weight-records", "/health-records", "/tasks", "/reminders",
			"/media", "/pedigree", "/genetic", "/stud",
		)
	case "caretaker":
		return pathContainsAny(path,
			"/hamsters", "/enclosures", "/stays", "/cleanings", "/litters",
			"/weight-records", "/health-records", "/tasks", "/reminders", "/media",
		)
	case "staff":
		return pathContainsAny(path,
			"/crm", "/contracts", "/receipts", "/public-site", "/miniprogram",
			"/growth", "/assistant", "/hamsters", "/push/messages",
		)
	default:
		return false
	}
}

func knownPrincipalRole(role string) bool {
	switch role {
	case "owner", "breeder", "caretaker", "staff", "viewer":
		return true
	default:
		return false
	}
}

func pathContainsAny(path string, values ...string) bool {
	for _, value := range values {
		if strings.Contains(path, value) {
			return true
		}
	}
	return false
}

func principalCapabilities(role string) []string {
	base := []string{
		"member_role:" + role,
		"tenant_scope",
		"offline_read_cache",
	}
	switch role {
	case "owner":
		return append(base,
			"manage_members", "manage_subscriptions", "write_breeding", "write_litter", "write_hamster",
			"write_enclosure", "write_weight", "write_task", "write_health",
			"write_import", "write_media", "write_crm", "write_documents",
			"write_accounting", "write_growth",
		)
	case "breeder":
		return append(base,
			"write_breeding", "write_litter", "write_hamster", "write_weight",
			"write_task", "write_health", "write_media", "manage_subscriptions",
		)
	case "caretaker":
		return append(base,
			"write_litter", "write_hamster", "write_enclosure", "write_weight",
			"write_task", "write_health", "write_media", "manage_subscriptions",
		)
	case "staff":
		return append(base,
			"write_hamster", "write_crm", "write_documents", "write_growth", "manage_subscriptions",
		)
	default:
		return base
	}
}
