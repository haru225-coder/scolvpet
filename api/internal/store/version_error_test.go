package store

import (
	"errors"
	"fmt"
	"strings"
	"testing"
)

// TestVersionErrorIsCompatible 守护 P0 版本号协议改造的兼容性契约:
//   - a) 现有产出端 fmt.Errorf("%w: current=%d", ErrVersionConflict, v) 不破;
//   - b) 新 typed 产出端 &VersionError{Current: v} 可被 errors.Is 匹配;
//   - c) Error() 文本仍含 "version conflict"(httpapi 层 Contains 在 P2 前依赖);
//   - d) errors.As 能取出 Current 字段。
func TestVersionErrorIsCompatible(t *testing.T) {
	// a) 现有 %w 包装形态:errors.Is 必须仍命中哨兵。
	legacy := fmt.Errorf("%w: current=%d", ErrVersionConflict, 5)
	if !errors.Is(legacy, ErrVersionConflict) {
		t.Fatalf("legacy %%w wrap should match ErrVersionConflict, got: %v", legacy)
	}

	// b) 新 typed 形态:直接可匹配。
	typed := &VersionError{Current: 5}
	if !errors.Is(typed, ErrVersionConflict) {
		t.Fatalf("typed *VersionError should match ErrVersionConflict")
	}

	// c) Error() 文本兼容:哨兵与新 typed 的错误文本都含 "version conflict"。
	if !strings.Contains(ErrVersionConflict.Error(), "version conflict") {
		t.Fatalf("sentinel Error() should contain %q, got: %q", "version conflict", ErrVersionConflict.Error())
	}
	if !strings.Contains(legacy.Error(), "version conflict") {
		t.Fatalf("legacy Error() text should contain %q, got: %q", "version conflict", legacy.Error())
	}
	if !strings.Contains(typed.Error(), "version conflict") {
		t.Fatalf("typed Error() text should contain %q, got: %q", "version conflict", typed.Error())
	}

	// d) errors.As 能取出 Current 字段。
	wrapped := fmt.Errorf("wrap: %w", &VersionError{Current: 5})
	var ve *VersionError
	if !errors.As(wrapped, &ve) {
		t.Fatalf("errors.As should extract *VersionError from %v", wrapped)
	}
	if ve.Current != 5 {
		t.Fatalf("errors.As Current = %d, want 5", ve.Current)
	}
}
