package i3core

import "fmt"

var (
	ErrNotFound            = fmt.Errorf("i3 resource not found")
	ErrValidation          = fmt.Errorf("i3 validation failed")
	ErrConflict            = fmt.Errorf("i3 resource conflict")
	ErrVersionConflict     = fmt.Errorf("i3 version conflict")
	ErrIdempotencyRequired = fmt.Errorf("i3 idempotency key required")
)

type VersionError struct {
	Current int
}

func (e *VersionError) Error() string {
	return fmt.Sprintf("%s: current=%d", ErrVersionConflict, e.Current)
}
func (e *VersionError) Unwrap() error { return ErrVersionConflict }

type StateError struct {
	Message string
}

func (e *StateError) Error() string { return e.Message }
func (e *StateError) Unwrap() error { return ErrConflict }

type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string { return e.Message }
func (e *ValidationError) Unwrap() error { return ErrValidation }
