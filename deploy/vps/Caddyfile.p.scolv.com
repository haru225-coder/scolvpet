# Caddy listens on 8443 on LA1 because port 443 is occupied by the existing proxy.
# Assistant chat may call upstream LLM; keep reverse_proxy read timeout >= 120s
# to avoid 502 while rules/LLM still running.
#
# Public customer Web SSR is served on the same host; API stays under /v1 and
# health probes. Adjust hostnames if web uses a separate public domain.
https://p.scolv.com:8443 {
	# Customer-facing public site (Node SSR).
	# Real SSR paths: /p/{slug}, /s/{share}, /d/{document}, plus assets.
	@web path / /p/* /s/* /d/* /sites/* /public/* /assets/* /favicon.ico
	handle @web {
		reverse_proxy 127.0.0.1:3000 {
			transport http {
				dial_timeout 10s
				response_header_timeout 30s
				read_timeout 30s
				write_timeout 30s
			}
		}
	}

	# API + health.
	handle {
		reverse_proxy 127.0.0.1:8080 {
			transport http {
				dial_timeout 10s
				response_header_timeout 120s
				read_timeout 120s
				write_timeout 120s
			}
		}
	}
}
