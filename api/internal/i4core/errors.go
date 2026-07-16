package i4core

import (
	"errors"
	"fmt"
)

var (
	ErrNotFound                   = errors.New("i4 resource not found")
	ErrValidation                 = errors.New("i4 validation failed")
	ErrConflict                   = errors.New("i4 resource conflict")
	ErrVersionConflict            = errors.New("i4 version conflict")
	ErrIdempotencyKeyRequired     = errors.New("i4 idempotency key required")
	ErrIdempotencyPayloadMismatch = errors.New("i4 idempotency payload mismatch")
	ErrIdempotencyInProgress      = errors.New("i4 idempotency request in progress")
	ErrEligibilityStale           = errors.New("individualization eligibility is stale")
)

type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string { return e.Message }
func (e *ValidationError) Unwrap() error { return ErrValidation }

type VersionError struct{ Current int }

func (e *VersionError) Error() string {
	return fmt.Sprintf("%v: current=%d", ErrVersionConflict, e.Current)
}
func (e *VersionError) Unwrap() error { return ErrVersionConflict }

type StateError struct{ Message string }

func (e *StateError) Error() string { return e.Message }
func (e *StateError) Unwrap() error { return ErrConflict }
