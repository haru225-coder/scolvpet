package store

import (
	"context"
	"crypto/subtle"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/scolvpet/scolvpet/api/internal/auth"
)

func (s *Store) CreateVerificationChallenge(ctx context.Context, id uuid.UUID, phone, codeHash string, expiresAt time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		INSERT INTO verification_challenge (id, phone, purpose, code_sha256, expires_at)
		VALUES ($1, $2, 'login', $3, $4)
	`, id, phone, codeHash, expiresAt)
	return err
}

func (s *Store) DeleteVerificationChallenge(ctx context.Context, id uuid.UUID) error {
	_, err := s.Pool.Exec(ctx, `DELETE FROM verification_challenge WHERE id=$1`, id)
	return err
}

func (s *Store) VerifyVerificationChallenge(ctx context.Context, id uuid.UUID, phone, codeHash string, now time.Time) error {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var storedPhone, storedHash string
	var attempts int
	var expiresAt time.Time
	var consumedAt *time.Time
	err = tx.QueryRow(ctx, `
		SELECT phone, code_sha256, attempts, expires_at, consumed_at
		FROM verification_challenge
		WHERE id=$1
		FOR UPDATE
	`, id).Scan(&storedPhone, &storedHash, &attempts, &expiresAt, &consumedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return auth.ErrVerification
		}
		return err
	}
	if storedPhone != phone || consumedAt != nil || !now.Before(expiresAt) {
		return auth.ErrVerification
	}
	if attempts >= 5 {
		return auth.ErrInvalidCode
	}

	attempts++
	if subtle.ConstantTimeCompare([]byte(storedHash), []byte(codeHash)) != 1 {
		if _, err := tx.Exec(ctx, `UPDATE verification_challenge SET attempts=$2 WHERE id=$1`, id, attempts); err != nil {
			return err
		}
		if err := tx.Commit(ctx); err != nil {
			return err
		}
		return auth.ErrInvalidCode
	}
	if _, err := tx.Exec(ctx, `
		UPDATE verification_challenge
		SET attempts=$2, consumed_at=$3
		WHERE id=$1
	`, id, attempts, now); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func (s *Store) CreateRefreshSession(ctx context.Context, tokenHash string, ownerID uuid.UUID, expiresAt time.Time) error {
	_, err := s.Pool.Exec(ctx, `
		INSERT INTO auth_refresh_session (owner_id, token_sha256, expires_at)
		VALUES ($1, $2, $3)
	`, ownerID, tokenHash, expiresAt)
	return err
}

func (s *Store) LookupRefreshSession(ctx context.Context, tokenHash string, now time.Time) (uuid.UUID, error) {
	var ownerID uuid.UUID
	var expiresAt time.Time
	var revokedAt *time.Time
	_, err := s.Pool.Exec(ctx, `
		DELETE FROM auth_refresh_session
		WHERE expires_at <= $1 AND revoked_at IS NULL AND consumed_at IS NULL
	`, now)
	if err != nil {
		return uuid.Nil, err
	}
	err = s.Pool.QueryRow(ctx, `
		SELECT owner_id, expires_at, revoked_at
		FROM auth_refresh_session
		WHERE token_sha256=$1
	`, tokenHash).Scan(&ownerID, &expiresAt, &revokedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return uuid.Nil, auth.ErrInvalidRefresh
		}
		return uuid.Nil, err
	}
	if revokedAt != nil || !now.Before(expiresAt) {
		return uuid.Nil, auth.ErrInvalidRefresh
	}
	return ownerID, nil
}

func (s *Store) RotateRefreshSession(ctx context.Context, tokenHash, nextTokenHash string, ownerID uuid.UUID, expiresAt, now time.Time) error {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()

	var currentOwner uuid.UUID
	err = tx.QueryRow(ctx, `
		UPDATE auth_refresh_session
		SET consumed_at=$3, last_used_at=$3
		WHERE token_sha256=$1 AND owner_id=$2
		  AND consumed_at IS NULL AND revoked_at IS NULL AND expires_at > $3
		RETURNING owner_id
	`, tokenHash, ownerID, now).Scan(&currentOwner)
	if errors.Is(err, pgx.ErrNoRows) {
		return auth.ErrInvalidRefresh
	}
	if err != nil {
		return err
	}
	if currentOwner != ownerID {
		return auth.ErrInvalidRefresh
	}
	if _, err := tx.Exec(ctx, `
		INSERT INTO auth_refresh_session (owner_id, token_sha256, expires_at)
		VALUES ($1, $2, $3)
	`, ownerID, nextTokenHash, expiresAt); err != nil {
		return err
	}
	return tx.Commit(ctx)
}
