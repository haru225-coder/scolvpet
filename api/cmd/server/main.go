package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
	_ "time/tzdata"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/scolvpet/scolvpet/api/internal/auth"
	"github.com/scolvpet/scolvpet/api/internal/httpapi"
	"github.com/scolvpet/scolvpet/api/internal/outbox"
	"github.com/scolvpet/scolvpet/api/internal/sms"
	"github.com/scolvpet/scolvpet/api/internal/store"
	"github.com/scolvpet/scolvpet/api/internal/wechat"
	"github.com/scolvpet/scolvpet/api/internal/worker"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	config, err := loadRuntimeConfig()
	if err != nil {
		logger.Error("runtime configuration rejected", "error", err)
		os.Exit(1)
	}
	databaseURL := config.DatabaseURL
	addr := config.APIAddr

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	poolConfig, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		logger.Error("database config invalid", "error", err)
		os.Exit(1)
	}
	poolConfig.MaxConns = int32(config.DBMaxConns)
	poolConfig.MinConns = int32(config.DBMinConns)
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

	apiStore := store.New(pool)
	var smsProvider auth.SMSProvider
	switch config.SMSProvider {
	case "mock":
		smsProvider = auth.MockSMSProvider{}
	case "http":
		smsProvider, err = sms.NewHTTPProvider(config.SMSHTTPEndpoint, config.SMSHTTPToken)
		if err != nil {
			logger.Error("sms provider config invalid", "error", err)
			os.Exit(1)
		}
	default:
		logger.Error("sms provider unsupported", "provider", config.SMSProvider)
		os.Exit(1)
	}
	service := auth.NewWithOptions(config.JWTSecret, config.SMSMockCode, auth.Options{
		Persistence: apiStore,
		SMSProvider: smsProvider,
	})
	importObjects, err := newObjectStore(config)
	if err != nil {
		logger.Error("object store config invalid", "provider", config.ObjectStoreProvider, "error", err)
		os.Exit(1)
	}
	apiServer := httpapi.NewServer(apiStore, service, logger)
	// NewServer keeps a local default for unit tests; the process entrypoint
	// replaces it with the configured local or S3-compatible implementation.
	apiServer.ImportObjects = importObjects
	apiServer.Environment = config.Environment
	apiServer.Ready = &httpapi.ReadyChecks{
		SMSProvider:    config.SMSProvider,
		SMSMockCodeSet: config.SMSMockCode != "",
		WechatProvider: config.WechatProvider,
	}
	apiServer.TrustedProxies = config.TrustedProxyCIDRs
	switch config.WechatProvider {
	case "mock":
		apiServer.Wechat = wechat.MockProvider{}
	case "http":
		wechatProvider, wechatErr := wechat.NewHTTPProvider(config.WechatAppID, config.WechatSecret)
		if wechatErr != nil {
			logger.Error("wechat provider config invalid", "error", wechatErr)
			os.Exit(1)
		}
		apiServer.Wechat = wechatProvider
	default:
		logger.Error("wechat provider unsupported", "provider", config.WechatProvider)
		os.Exit(1)
	}
	outboxWorker := worker.New(pool, logger)
	outboxWorker.LeaseDuration = time.Duration(config.OutboxLeaseSeconds) * time.Second
	switch config.OutboxPublisherMode {
	case "success":
		outboxWorker.Publisher = func(context.Context, string, []byte) error { return nil }
	case "fail":
		outboxWorker.Publisher = func(context.Context, string, []byte) error {
			return errors.New("configured publisher failure")
		}
	case "http":
		publisher, publisherErr := outbox.NewHTTPPublisher(config.OutboxPublisherEndpoint, config.OutboxPublisherToken)
		if publisherErr != nil {
			logger.Error("outbox publisher config invalid", "error", publisherErr)
			os.Exit(1)
		}
		outboxWorker.Publisher = publisher.Publish
	}
	if !config.OutboxWorkerDisabled {
		go outboxWorker.Run(ctx, 2*time.Second)
	}
	mediaCodec := worker.NewExternalCodec(mediaCodecConfig(config))
	mediaWorker := worker.NewMediaProcessorWithCodec(pool, importObjects, logger, mediaCodec)
	if !config.MediaWorkerDisabled {
		go mediaWorker.Run(ctx, time.Duration(config.MediaWorkerIntervalSecs)*time.Second)
	}
	// Auto-release expired public/staff reservation holds (P0-03).
	go func() {
		ticker := time.NewTicker(60 * time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				if n, err := apiServer.ReleaseExpiredReservationHolds(ctx); err != nil {
					logger.Warn("reservation hold release failed", "error", err)
				} else if n > 0 {
					logger.Info("reservation holds released", "count", n)
				}
			}
		}
	}()

	// WriteTimeout covers the whole handler lifetime after request headers.
	// Assistant chat may call upstream LLM + tools for 30–90s; 15s caused empty
	// replies / Caddy 502 EOF on write paths. Keep >= reverse_proxy read_timeout.
	server := &http.Server{
		Addr:              addr,
		Handler:           apiServer.Handler(),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      120 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
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
