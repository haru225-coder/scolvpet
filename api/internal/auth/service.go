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
)

var (
	ErrInvalidCode    = errors.New("invalid verification code")
	ErrInvalidToken   = errors.New("invalid access token")
	ErrExpiredToken   = errors.New("expired access token")
	ErrRevokedToken   = errors.New("revoked access token")
	ErrVerification   = errors.New("verification challenge not found")
	ErrInvalidRefresh = errors.New("invalid refresh token")
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
	revoked      map[string]time.Time
	refresh      map[string]uuid.UUID
	refreshOwner map[string]uuid.UUID
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
	}
}

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
		ownerID, ok = s.refreshOwner[refreshToken]
	}
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
	s.refresh[nextRefreshToken] = ownerID
	s.refreshOwner[nextRefreshToken] = ownerID
	return accessToken, nextRefreshToken, nil
}

func (s *Service) ParseAccessToken(token string) (uuid.UUID, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if token == "" {
		return uuid.Nil, ErrInvalidToken
	}
	if revokedAt, ok := s.revoked[token]; ok && time.Now().Before(revokedAt) {
		return uuid.Nil, ErrRevokedToken
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
	if time.Now().Unix() >= claims.Expires {
		return uuid.Nil, ErrExpiredToken
	}
	ownerID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, ErrInvalidToken
	}
	return ownerID, nil
}

func (s *Service) Revoke(token string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.revoked[token] = time.Now().Add(time.Hour)
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
