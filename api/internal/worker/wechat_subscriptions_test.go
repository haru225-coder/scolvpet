package worker

import (
	"testing"
)

func TestSubscriptionEventDataForTaskReminder(t *testing.T) {
	data, err := subscriptionEventData("task_reminder", []byte(`{"title":"清洁笼舍","description":"检查饮水","scheduled_at":"2026-07-27T08:00:00Z"}`))
	if err != nil {
		t.Fatalf("task event data: %v", err)
	}
	if data["thing1"] != "清洁笼舍" || data["time2"] != "2026-07-27T08:00:00Z" || data["thing3"] != "检查饮水" {
		t.Fatalf("task event data: %#v", data)
	}
}

func TestSubscriptionEventDataForReservationStatus(t *testing.T) {
	data, err := subscriptionEventData("reservation_status", []byte(`{"title":"奶茶预订","status":"handed_over","updated_at":"2026-07-27T08:00:00Z"}`))
	if err != nil {
		t.Fatalf("reservation event data: %v", err)
	}
	if data["thing1"] != "奶茶预订" || data["phrase2"] != "已交付" || data["time3"] != "2026-07-27T08:00:00Z" {
		t.Fatalf("reservation event data: %#v", data)
	}
}

func TestSubscriptionEventDataRejectsUnknownEvent(t *testing.T) {
	if _, err := subscriptionEventData("unknown", []byte(`{}`)); err == nil {
		t.Fatal("unknown event type should fail")
	}
}

func TestSubscriptionWorkerSelectsTemplateByEventType(t *testing.T) {
	worker := &SubscriptionWorker{TaskTemplateID: "task-template", ReservationTemplateID: "reservation-template"}
	if got := worker.templateIDForEvent("task_reminder"); got != "task-template" {
		t.Fatalf("task template: %q", got)
	}
	if got := worker.templateIDForEvent("reservation_status"); got != "reservation-template" {
		t.Fatalf("reservation template: %q", got)
	}
	if got := worker.templateIDForEvent("unknown"); got != "" {
		t.Fatalf("unknown template: %q", got)
	}
}
