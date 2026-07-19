# Caddy listens on 8443 on LA1 because port 443 is occupied by the existing proxy.
https://p.scolv.com:8443 {
  reverse_proxy 127.0.0.1:8080
}
