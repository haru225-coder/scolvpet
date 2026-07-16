package i2core

import "errors"

var (
	ErrNotFound                   = errors.New("resource not found")
	ErrValidation                 = errors.New("validation failed")
	ErrDuplicate                  = errors.New("duplicate resource")
	ErrVersionConflict            = errors.New("version conflict")
	ErrIdempotencyKeyRequired     = errors.New("idempotency key required")
	ErrIdempotencyPayloadMismatch = errors.New("idempotency payload mismatch")
	ErrIdempotencyInProgress      = errors.New("idempotency request in progress")
	ErrStayConflict               = errors.New("enclosure stay conflict")
	ErrInvalidWeight              = errors.New("invalid weight")
	ErrPedigreeCycle              = errors.New("pedigree cycle detected")
)
