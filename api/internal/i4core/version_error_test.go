package i4core

import (
	"errors"
	"fmt"
	"testing"
)

// TestVersionErrorIsCompatible 守护 i4core 版本号协议链路:
// typed &VersionError{Current} 经 Unwrap 必须能被 errors.Is 匹配到哨兵。
// 若此测试失败,说明 i4core 错误链存在断链,须上报而非擅自修改 errors.go。
func TestVersionErrorIsCompatible(t *testing.T) {
	err := fmt.Errorf("wrap: %w", &VersionError{Current: 3})
	if !errors.Is(err, ErrVersionConflict) {
		t.Fatalf("errors.Is(fmt.Errorf(\"wrap: %%w\", &VersionError{Current: 3}), ErrVersionConflict) should be true, got: %v", err)
	}
}
