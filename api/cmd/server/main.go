package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/httpapi"
	"github.com/scolvpet/scolvpet/api/internal/store"
	"github.com/scolvpet/scolvpet/api/internal/worker"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	databaseURL := getenv("DATABASE_URL", "postgres://scolvpet:scolvpet@127.0.0.1:55432/scolvpet?sslmode=disable")
	addr := getenv("API_ADDR", ":8080")

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	poolConfig, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		logger.Error("database config invalid", "error", err)
		os.Exit(1)
	}
	poolConfig.MaxConns = int32(getenvInt("DB_MAX_CONNS", 8))
	poolConfig.MinConns = int32(getenvInt("DB_MIN_CONNS", 1))
	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		logger.Error("database pool creation failed", "error", err)
		os.Exit(1)
	}
	defer pool.Close()
	if err := pool.Ping(ctx); err != nil {
		logger.Error("database unavailable", "error", err)
		os.Exit(1)
	}

	service := auth.New(getenv("JWT_SECRET", "local-development-secret"), getenv("SMS_MOCK_CODE", "123456"))
	apiStore := store.New(pool)
	apiServer := httpapi.NewServer(apiStore, service, logger)
	outboxWorker := worker.New(pool, logger)
	outboxWorker.LeaseDuration = time.Duration(getenvInt("OUTBOX_WORKER_LEASE_SECONDS", 60)) * time.Second
	if getenv("OUTBOX_PUBLISHER_MODE", "success") == "fail" {
		outboxWorker.Publisher = func(context.Context, string, []byte) error {
			return errors.New("configured publisher failure")
		}
	}
	if getenv("OUTBOX_WORKER_DISABLED", "0") != "1" {
		go outboxWorker.Run(ctx, 2*time.Second)
	}

	server := &http.Server{Addr: addr, Handler: apiServer.Handler(), ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 15 * time.Second, WriteTimeout: 15 * time.Second, IdleTimeout: 60 * time.Second}
	go func() {
		logger.Info("api server listening", "addr", addr)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("api server stopped", "error", err)
			cancel()
		}
	}()

	<-ctx.Done()
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownCancel()
	if err := server.Shutdown(shutdownCtx); err != nil {
		logger.Error("api graceful shutdown failed", "error", err)
	}
}

func getenv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func getenvInt(key string, fallback int) int {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(value)
	if err != nil || parsed < 1 {
		return fallback
	}
	return parsed
}
