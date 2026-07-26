package auth

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

var (
	ErrInvalidCode    = errors.New("invalid verification code")
	ErrInvalidToken   = errors.New("invalid access token")
	ErrExpiredToken   = errors.New("expired access token")
	ErrRevokedToken   = errors.New("revoked access token")
	ErrVerification   = errors.New("verification challenge not found")
	ErrInvalidRefresh = errors.New("invalid refresh token")
	ErrRateLimited    = errors.New("rate limited")
)

type Challenge struct {
	ID        uuid.UUID
	Phone     string
	Code      string
	ExpiresAt time.Time
	Attempts  int
}

// Persistence stores authentication challenges and refresh sessions outside
// the process. The in-memory maps remain available for auth-only unit tests.
type Persistence interface {
	CreateVerificationChallenge(context.Context, uuid.UUID, string, string, time.Time) error
	DeleteVerificationChallenge(context.Context, uuid.UUID) error
	VerifyVerificationChallenge(context.Context, uuid.UUID, string, string, time.Time) error
	CreateRefreshSession(context.Context, string, uuid.UUID, time.Time) error
	LookupRefreshSession(context.Context, string, time.Time) (uuid.UUID, error)
	RotateRefreshSession(context.Context, string, string, uuid.UUID, time.Time, time.Time) error
	RevokeRefreshSession(context.Context, string, time.Time) error
	RevokeAllRefreshSessionsForOwner(context.Context, uuid.UUID, time.Time) error
	RevokeAccessToken(context.Context, string, uuid.UUID, time.Time) error
	IsAccessTokenRevoked(context.Context, string, time.Time) (bool, error)
	// CheckAndHitRateLimit enforces cooldown/window limits.
	// Returns remaining cooldown seconds when blocked (0 when allowed).
	CheckAndHitRateLimit(ctx context.Context, bucketKey string, cooldown time.Duration, maxPerWindow int, window time.Duration, now time.Time) (retryAfterSeconds int, err error)
}

// RefreshTxPersistence lets a caller that already holds a transaction rotate a
// refresh session on it. Implementations are optional: RefreshTx falls back to
// Refresh when the configured Persistence does not provide it.
type RefreshTxPersistence interface {
	LookupRefreshSessionTx(context.Context, pgx.Tx, string, time.Time) (uuid.UUID, error)
	RotateRefreshSessionTx(context.Context, pgx.Tx, string, string, uuid.UUID, time.Time, time.Time) error
}

type SMSProvider interface {
	SendCode(context.Context, string, string) error
}

type MockSMSProvider struct{}

func (MockSMSProvider) SendCode(context.Context, string, string) error { return nil }

type Options struct {
	Persistence Persistence
	SMSProvider SMSProvider
}

type tokenClaims struct {
	Subject string `json:"sub"`
	Expires int64  `json:"exp"`
	JTI     string `json:"jti"`
}

type Service struct {
	secret       []byte
	mockCode     string
	persistence  Persistence
	smsProvider  SMSProvider
	mu           sync.Mutex
	challenges   map[uuid.UUID]*Challenge
	revoked      map[string]time.Time // raw token -> expires (process-local fallback)
	refresh      map[string]uuid.UUID
	refreshOwner map[string]uuid.UUID // compatibility lookup for active refresh tokens
	rateBuckets  map[string]rateBucket
}

type rateBucket struct {
	windowStart  time.Time
	hits         int
	blockedUntil time.Time
	lastHit      time.Time
}

func New(secret, mockCode string) *Service {
	return NewWithOptions(secret, mockCode, Options{})
}

func NewWithPersistence(secret, mockCode string, persistence Persistence) *Service {
	return NewWithOptions(secret, mockCode, Options{Persistence: persistence})
}

func NewWithOptions(secret, mockCode string, options Options) *Service {
	if secret == "" {
		secret = "local-development-secret"
	}
	return &Service{
		secret:       []byte(secret),
		mockCode:     mockCode,
		persistence:  options.Persistence,
		smsProvider:  options.SMSProvider,
		challenges:   make(map[uuid.UUID]*Challenge),
		revoked:      make(map[string]time.Time),
		refresh:      make(map[string]uuid.UUID),
		refreshOwner: make(map[string]uuid.UUID),
		rateBuckets:  make(map[string]rateBucket),
	}
}

// RequestCode creates a verification challenge without creating an account.
// Caller must enforce rate limits first via EnforceRateLimit.
func (s *Service) RequestCode(ctx context.Context, phone string) (Challenge, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	code, err := s.nextCode()
	if err != nil {
		return Challenge{}, err
	}
	challenge := Challenge{
		ID:        uuid.New(),
		Phone:     phone,
		Code:      code,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	}
	if s.persistence != nil {
		if err := s.persistence.CreateVerificationChallenge(ctx, challenge.ID, challenge.Phone, digestHex(challenge.Code), challenge.ExpiresAt); err != nil {
			return Challenge{}, err
		}
	} else {
		s.challenges[challenge.ID] = &challenge
	}
	if s.smsProvider != nil {
		if err := s.smsProvider.SendCode(ctx, challenge.Phone, challenge.Code); err != nil {
			if s.persistence != nil {
				_ = s.persistence.DeleteVerificationChallenge(ctx, challenge.ID)
			} else {
				delete(s.challenges, challenge.ID)
			}
			return Challenge{}, err
		}
	}
	return challenge, nil
}

func (s *Service) VerifyCode(ctx context.Context, id uuid.UUID, phone, code string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.persistence != nil {
		return s.persistence.VerifyVerificationChallenge(ctx, id, phone, digestHex(code), time.Now().UTC())
	}

	challenge, ok := s.challenges[id]
	if !ok || challenge.Phone != phone || time.Now().After(challenge.ExpiresAt) {
		return ErrVerification
	}
	if challenge.Attempts >= 5 {
		return ErrInvalidCode
	}
	challenge.Attempts++
	if subtle.ConstantTimeCompare([]byte(challenge.Code), []byte(code)) != 1 {
		return ErrInvalidCode
	}
	delete(s.challenges, id)
	return nil
}

func (s *Service) CreateSession(ctx context.Context, ownerID uuid.UUID) (accessToken, refreshToken string, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now()
	claims := tokenClaims{Subject: ownerID.String(), Expires: now.Add(time.Hour).Unix(), JTI: uuid.NewString()}
	accessToken = s.sign(claims)
	refreshToken = "rt_" + uuid.NewString()
	if s.persistence != nil {
		if err := s.persistence.CreateRefreshSession(ctx, digestHex(refreshToken), ownerID, now.Add(30*24*time.Hour)); err != nil {
			return "", "", err
		}
		return accessToken, refreshToken, nil
	}
	s.refresh[refreshToken] = ownerID
	s.refreshOwner[refreshToken] = ownerID
	return accessToken, refreshToken, nil
}

func (s *Service) OwnerForRefresh(ctx context.Context, refreshToken string) (uuid.UUID, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.persistence != nil {
		return s.persistence.LookupRefreshSession(ctx, digestHex(refreshToken), time.Now().UTC())
	}
	ownerID, ok := s.refresh[refreshToken]
	if !ok {
		return uuid.Nil, ErrInvalidRefresh
	}
	return ownerID, nil
}

func (s *Service) Refresh(ctx context.Context, refreshToken string) (accessToken, nextRefreshToken string, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now().UTC()
	var ownerID uuid.UUID
	if s.persistence != nil {
		ownerID, err = s.persistence.LookupRefreshSession(ctx, digestHex(refreshToken), now)
		if err != nil {
			return "", "", err
		}
	} else {
		var ok bool
		ownerID, ok = s.refresh[refreshToken]
		if !ok {
			return "", "", ErrInvalidRefresh
		}
	}
	claims := tokenClaims{Subject: ownerID.String(), Expires: now.Add(time.Hour).Unix(), JTI: uuid.NewString()}
	accessToken = s.sign(claims)
	nextRefreshToken = "rt_" + uuid.NewString()
	if s.persistence != nil {
		if err := s.persistence.RotateRefreshSession(ctx, digestHex(refreshToken), digestHex(nextRefreshToken), ownerID, now.Add(30*24*time.Hour), now); err != nil {
			return "", "", err
		}
		return accessToken, nextRefreshToken, nil
	}
	delete(s.refresh, refreshToken)
	delete(s.refreshOwner, refreshToken)
	s.refresh[nextRefreshToken] = ownerID
	s.refreshOwner[nextRefreshToken] = ownerID
	return accessToken, nextRefreshToken, nil
}

// RefreshTx rotates the session on a transaction the caller already owns.
//
// Refresh cannot be used from inside a transaction: it takes the service mutex
// and then asks the pool for a second connection, so once concurrent refreshes
// reach DB_MAX_CONNS every one of them holds a connection while waiting for the
// mutex holder, which is itself waiting for a connection that can never free.
// Reusing the caller's transaction keeps the whole rotation on one connection,
// and the mutex is not needed at all because the persistence path touches none
// of the in-memory maps it guards.
func (s *Service) RefreshTx(
	ctx context.Context,
	tx pgx.Tx,
	refreshToken string,
) (accessToken, nextRefreshToken string, err error) {
	txPersistence, ok := s.persistence.(RefreshTxPersistence)
	if !ok {
		return s.Refresh(ctx, refreshToken)
	}
	now := time.Now().UTC()
	ownerID, err := txPersistence.LookupRefreshSessionTx(ctx, tx, digestHex(refreshToken), now)
	if err != nil {
		return "", "", err
	}
	claims := tokenClaims{
		Subject: ownerID.String(),
		Expires: now.Add(time.Hour).Unix(),
		JTI:     uuid.NewString(),
	}
	accessToken = s.sign(claims)
	nextRefreshToken = "rt_" + uuid.NewString()
	if err := txPersistence.RotateRefreshSessionTx(
		ctx,
		tx,
		digestHex(refreshToken),
		digestHex(nextRefreshToken),
		ownerID,
		now.Add(30*24*time.Hour),
		now,
	); err != nil {
		return "", "", err
	}
	return accessToken, nextRefreshToken, nil
}

func (s *Service) ParseAccessToken(token string) (uuid.UUID, error) {
	return s.ParseAccessTokenContext(context.Background(), token)
}

// ParseAccessTokenContext runs on every authenticated request. Parsing and
// HMAC verification are pure (secret is immutable after construction), so the
// mutex only guards the in-memory revocation map — holding it across the
// persistence round-trip would serialize all bearer traffic on one DB latency
// (docs/31 §5.12).
func (s *Service) ParseAccessTokenContext(ctx context.Context, token string) (uuid.UUID, error) {
	if token == "" {
		return uuid.Nil, ErrInvalidToken
	}
	parts := strings.Split(token, ".")
	if len(parts) != 3 || parts[0] != "v1" {
		return uuid.Nil, ErrInvalidToken
	}
	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return uuid.Nil, ErrInvalidToken
	}
	var claims tokenClaims
	if err := json.Unmarshal(payload, &claims); err != nil {
		return uuid.Nil, ErrInvalidToken
	}
	if !hmac.Equal([]byte(parts[2]), []byte(s.signature(payload))) {
		return uuid.Nil, ErrInvalidToken
	}
	now := time.Now()
	if now.Unix() >= claims.Expires {
		return uuid.Nil, ErrExpiredToken
	}
	s.mu.Lock()
	s.cleanupRevoked(now)
	revokedAt, revokedInMemory := s.revoked[token]
	s.mu.Unlock()
	if revokedInMemory && now.Before(revokedAt) {
		return uuid.Nil, ErrRevokedToken
	}
	if s.persistence != nil {
		revoked, err := s.persistence.IsAccessTokenRevoked(ctx, digestHex(token), now.UTC())
		if err != nil {
			return uuid.Nil, err
		}
		if revoked {
			return uuid.Nil, ErrRevokedToken
		}
	}
	ownerID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, ErrInvalidToken
	}
	return ownerID, nil
}

// Revoke marks the access token invalid until expiry. The public method keeps
// its historical no-error signature for unit callers; request handlers use
// RevokeAccess so persistence errors are surfaced.
func (s *Service) Revoke(token string) {
	_ = s.RevokeAccess(context.Background(), token)
}

func (s *Service) RevokeAccess(ctx context.Context, token string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now()
	s.cleanupRevoked(now)
	parts := strings.Split(token, ".")
	expiresAt := time.Now().Add(time.Hour)
	var ownerID uuid.UUID
	if len(parts) == 3 && parts[0] == "v1" {
		if payload, err := base64.RawURLEncoding.DecodeString(parts[1]); err == nil {
			var claims tokenClaims
			if json.Unmarshal(payload, &claims) == nil {
				if claims.Expires > 0 {
					expiresAt = time.Unix(claims.Expires, 0)
				}
				if parsed, err := uuid.Parse(claims.Subject); err == nil {
					ownerID = parsed
				}
			}
		}
	}
	s.revoked[token] = expiresAt
	if s.persistence != nil && ownerID != uuid.Nil {
		return s.persistence.RevokeAccessToken(ctx, digestHex(token), ownerID, expiresAt.UTC())
	}
	return nil
}

func (s *Service) cleanupRevoked(now time.Time) {
	for token, expiresAt := range s.revoked {
		if !now.Before(expiresAt) {
			delete(s.revoked, token)
		}
	}
}

// RevokeRefresh invalidates a refresh token immediately.
func (s *Service) RevokeRefresh(ctx context.Context, refreshToken string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now().UTC()
	if s.persistence != nil {
		return s.persistence.RevokeRefreshSession(ctx, digestHex(refreshToken), now)
	}
	delete(s.refresh, refreshToken)
	delete(s.refreshOwner, refreshToken)
	return nil
}

// RevokeAllRefreshForOwner invalidates every active refresh session for the owner.
func (s *Service) RevokeAllRefreshForOwner(ctx context.Context, ownerID uuid.UUID) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now().UTC()
	if s.persistence != nil {
		return s.persistence.RevokeAllRefreshSessionsForOwner(ctx, ownerID, now)
	}
	for token, oid := range s.refresh {
		if oid == ownerID {
			delete(s.refresh, token)
			delete(s.refreshOwner, token)
		}
	}
	return nil
}

// EnforceRateLimit applies cooldown + sliding window limits.
// Returns retry-after seconds when blocked.
func (s *Service) EnforceRateLimit(ctx context.Context, bucketKey string, cooldown time.Duration, maxPerWindow int, window time.Duration) (int, error) {
	now := time.Now().UTC()
	if s.persistence != nil {
		return s.persistence.CheckAndHitRateLimit(ctx, bucketKey, cooldown, maxPerWindow, window, now)
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	bucket := s.rateBuckets[bucketKey]
	if !bucket.blockedUntil.IsZero() && now.Before(bucket.blockedUntil) {
		return int(bucket.blockedUntil.Sub(now).Seconds()) + 1, ErrRateLimited
	}
	if !bucket.lastHit.IsZero() && now.Sub(bucket.lastHit) < cooldown {
		retry := int(cooldown.Seconds()) - int(now.Sub(bucket.lastHit).Seconds())
		if retry < 1 {
			retry = 1
		}
		return retry, ErrRateLimited
	}
	if bucket.windowStart.IsZero() || now.Sub(bucket.windowStart) >= window {
		bucket.windowStart = now
		bucket.hits = 0
	}
	if bucket.hits >= maxPerWindow {
		bucket.blockedUntil = now.Add(window)
		s.rateBuckets[bucketKey] = bucket
		return int(window.Seconds()), ErrRateLimited
	}
	bucket.hits++
	bucket.lastHit = now
	s.rateBuckets[bucketKey] = bucket
	return 0, nil
}

func (s *Service) sign(claims tokenClaims) string {
	payload, _ := json.Marshal(claims)
	return fmt.Sprintf("v1.%s.%s", base64.RawURLEncoding.EncodeToString(payload), s.signature(payload))
}

func (s *Service) signature(payload []byte) string {
	digest := hmac.New(sha256.New, s.secret)
	_, _ = digest.Write(payload)
	return base64.RawURLEncoding.EncodeToString(digest.Sum(nil))
}

func (s *Service) nextCode() (string, error) {
	if s.mockCode != "" {
		return s.mockCode, nil
	}
	value, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", value.Int64()), nil
}

func digestHex(value string) string {
	digest := sha256.Sum256([]byte(value))
	return fmt.Sprintf("%x", digest)
}
