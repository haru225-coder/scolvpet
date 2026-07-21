# Caddy listens on 8443 on LA1 because port 443 is occupied by the existing proxy.
# Assistant chat may call upstream LLM; keep reverse_proxy read timeout >= 120s
# to avoid 502 while rules/LLM still running.
https://p.scolv.com:8443 {
	reverse_proxy 127.0.0.1:8080 {
		transport http {
			dial_timeout 10s
			response_header_timeout 120s
			read_timeout 120s
			write_timeout 120s
		}
	}
}
