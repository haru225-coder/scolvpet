package worker

import (
	"testing"
	"time"
)

func TestWorkerDefaultsToLeasedClaims(t *testing.T) {
	worker := New(nil, nil)
	if worker.LeaseDuration != time.Minute {
		t.Fatalf("lease duration = %s, want 1m", worker.LeaseDuration)
	}
	if worker.ID == "" {
		t.Fatal("worker id must be unique and non-empty")
	}
}
