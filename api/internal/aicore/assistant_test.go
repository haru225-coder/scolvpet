package aicore

import (
	"testing"
	"time"
)

func TestDetectIntent(t *testing.T) {
	cases := map[string]string{
		"现在有多少只在养": IntentHamsters,
		"有没有逾期任务":   IntentOverdue,
		"待办有哪些":     IntentTasks,
		"繁育概况":      IntentBreeding,
		"用量多少":      IntentUsage,
		"我是什么套餐":    IntentPlan,
		"今天怎么样":     IntentOverview,
		"你能做什么":     IntentHelp,
		"???":       IntentUnknown,
	}
	for q, want := range cases {
		if got := DetectIntent(q); got != want {
			t.Fatalf("q=%q got=%s want=%s", q, got, want)
		}
	}
}

func TestAnswerFromSnapshot(t *testing.T) {
	snap := Snapshot{
		OrganizationName: "雪团熊舍",
		ActiveHamsters:   12,
		Enclosures:       8,
		ActiveLitters:    2,
		OpenTasks:        5,
		OverdueTasks:     1,
		GestatingPlans:   1,
		MediaBytes:       10 * 1024 * 1024,
		PlanCode:         "free",
		GeneratedAt:      time.Now().UTC(),
	}
	ans := AnswerFromSnapshot("在养多少", snap)
	if ans.Intent != IntentHamsters {
		t.Fatalf("intent=%s", ans.Intent)
	}
	if ans.Mode != "rules" {
		t.Fatalf("mode=%s", ans.Mode)
	}
	if !containsAny(ans.Answer, "12") {
		t.Fatalf("answer=%s", ans.Answer)
	}
	if len(ans.Facts) == 0 {
		t.Fatal("no facts")
	}
}
