package i2core

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
	ErrStayConflict               = errors.New("enclosure stay conflict")
	ErrInvalidWeight              = errors.New("invalid weight")
	ErrPedigreeCycle              = errors.New("pedigree cycle detected")
)

// VersionError 携带冲突时的期望版本号,是 ErrVersionConflict 的类型化形态。
// Unwrap 保证 errors.Is(err, ErrVersionConflict) 命中哨兵。
type VersionError struct{ Current int }

func (e *VersionError) Error() string {
	return fmt.Sprintf("version conflict: current=%d", e.Current)
}
func (e *VersionError) Unwrap() error { return ErrVersionConflict }

// Version 返回冲突时的期望版本号,供消费端读取 typed 字段。
func (e *VersionError) Version() int { return e.Current }
