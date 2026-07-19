# LA1 临时部署

此目录把 API、PostgreSQL 和本地对象存储放进 Docker Compose。API 只绑定 VPS 本机 `127.0.0.1:8080`，外部通过 Caddy 的 `https://p.scolv.com:8443` 访问。

```bash
cp deploy/vps/.env.example /opt/scolvpet/.env
docker compose -f /opt/scolvpet/docker-compose.yml up -d --build
curl -fsS https://p.scolv.com:8443/healthz
```

`/opt/scolvpet/.env` 只放在 VPS，不提交到仓库。`SMS_MOCK_CODE=123456` 仅用于临时验收。
