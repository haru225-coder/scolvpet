package i5core

import (
	"errors"
	"fmt"
)

var (
	ErrNotFound                   = errors.New("resource not found")
	ErrValidation                 = errors.New("validation failed")
	ErrDuplicate                  = errors.New("duplicate resource")
	ErrVersionConflict            = errors.New("version conflict")
	ErrIdempotencyKeyRequired     = errors.New("idempotency key required")
	ErrIdempotencyPayloadMismatch = errors.New("idempotency payload mismatch")
	ErrIdempotencyInProgress      = errors.New("idempotency request in progress")
)

type VersionError struct {
	Current int
}

func (e *VersionError) Error() string {
	return fmt.Sprintf("version conflict: current=%v", e.Current)
}
func (e *VersionError) Unwrap() error { return ErrVersionConflict }

// Version 返回冲突时的期望版本号,供消费端读取 typed 字段。
func (e *VersionError) Version() int { return e.Current }
