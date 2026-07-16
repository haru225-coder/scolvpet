package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
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

type tokenClaims struct {
	Subject string `json:"sub"`
	Expires int64  `json:"exp"`
	JTI     string `json:"jti"`
}

type Service struct {
	secret       []byte
	mockCode     string
	mu           sync.Mutex
	challenges   map[uuid.UUID]*Challenge
	revoked      map[string]time.Time
	refresh      map[string]uuid.UUID
	refreshOwner map[string]uuid.UUID
}

func New(secret, mockCode string) *Service {
	if secret == "" {
		secret = "local-development-secret"
	}
	if mockCode == "" {
		mockCode = "123456"
	}
	return &Service{
		secret:       []byte(secret),
		mockCode:     mockCode,
		challenges:   make(map[uuid.UUID]*Challenge),
		revoked:      make(map[string]time.Time),
		refresh:      make(map[string]uuid.UUID),
		refreshOwner: make(map[string]uuid.UUID),
	}
}

func (s *Service) RequestCode(phone string) Challenge {
	s.mu.Lock()
	defer s.mu.Unlock()

	challenge := Challenge{
		ID:        uuid.New(),
		Phone:     phone,
		Code:      s.mockCode,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	}
	s.challenges[challenge.ID] = &challenge
	return challenge
}

func (s *Service) VerifyCode(id uuid.UUID, phone, code string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

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

func (s *Service) CreateSession(ownerID uuid.UUID) (accessToken, refreshToken string) {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now()
	claims := tokenClaims{Subject: ownerID.String(), Expires: now.Add(time.Hour).Unix(), JTI: uuid.NewString()}
	accessToken = s.sign(claims)
	refreshToken = "rt_" + uuid.NewString()
	s.refresh[refreshToken] = ownerID
	s.refreshOwner[refreshToken] = ownerID
	return accessToken, refreshToken
}

func (s *Service) OwnerForRefresh(refreshToken string) (uuid.UUID, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	ownerID, ok := s.refresh[refreshToken]
	if !ok {
		ownerID, ok = s.refreshOwner[refreshToken]
	}
	if !ok {
		return uuid.Nil, ErrInvalidRefresh
	}
	return ownerID, nil
}

func (s *Service) Refresh(refreshToken string) (accessToken, nextRefreshToken string, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	ownerID, ok := s.refresh[refreshToken]
	if !ok {
		return "", "", ErrInvalidRefresh
	}
	delete(s.refresh, refreshToken)
	claims := tokenClaims{Subject: ownerID.String(), Expires: time.Now().Add(time.Hour).Unix(), JTI: uuid.NewString()}
	accessToken = s.sign(claims)
	nextRefreshToken = "rt_" + uuid.NewString()
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
