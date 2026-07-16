package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/worker"
)

func main() {
	ctx := context.Background()
	databaseURL := getenv("DATABASE_URL", "postgres://scolvpet:scolvpet@127.0.0.1:55432/scolvpet?sslmode=disable")
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		panic(err)
	}
	defer pool.Close()

	outboxWorker := worker.New(pool, slog.Default())
	outboxWorker.LeaseDuration = time.Duration(getenvInt("OUTBOX_LEASE_SECONDS", 60)) * time.Second
	mode := getenv("OUTBOX_PUBLISHER_MODE", "success")
	sleep := time.Duration(getenvInt("OUTBOX_PUBLISHER_SLEEP_MS", 0)) * time.Millisecond
	outboxWorker.Publisher = func(context.Context, string, []byte) error {
		if sleep > 0 {
			time.Sleep(sleep)
		}
		if mode == "fail" {
			return errors.New("probe publisher failure")
		}
		return nil
	}

	if err := outboxWorker.RunOnce(ctx); err != nil {
		fmt.Printf("probe result: %v\n", err)
		if mode != "fail" {
			os.Exit(1)
		}
	}
}

func getenv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func getenvInt(key string, fallback int) int {
	value, err := strconv.Atoi(os.Getenv(key))
	if err != nil || value < 1 {
		return fallback
	}
	return value
}
