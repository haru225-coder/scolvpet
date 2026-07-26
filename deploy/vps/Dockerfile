FROM golang:1.26-bookworm AS build

WORKDIR /src
COPY api/go.mod api/go.sum ./api/
RUN cd api && go mod download
COPY api ./api

RUN cd api && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -tags timetzdata -trimpath -ldflags="-s -w" -o /out/scolvpet-api ./cmd/server

FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    postgresql-client \
    ffmpeg \
    webp \
  && rm -rf /var/lib/apt/lists/* \
  && command -v ffmpeg \
  && command -v ffprobe \
  && command -v cwebp

WORKDIR /app
COPY --from=build /out/scolvpet-api /app/scolvpet-api
COPY db /app/db
COPY deploy/vps/entrypoint.sh /app/entrypoint.sh
RUN chmod 0755 /app/entrypoint.sh

ENV API_ADDR=:8080
EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
