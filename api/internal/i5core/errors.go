package i5core

import "errors"

var (
	ErrNotFound                   = errors.New("resource not found")
	ErrValidation                 = errors.New("validation failed")
	ErrDuplicate                  = errors.New("duplicate resource")
	ErrVersionConflict            = errors.New("version conflict")
	ErrIdempotencyKeyRequired     = errors.New("idempotency key required")
	ErrIdempotencyPayloadMismatch = errors.New("idempotency payload mismatch")
	ErrIdempotencyInProgress      = errors.New("idempotency request in progress")
)
