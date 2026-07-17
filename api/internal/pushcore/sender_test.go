package pushcore

import (
	"context"
	"log/slog"
	"testing"
)

func TestLogSenderSend(t *testing.T) {
	sender := NewLogSender(slog.Default())
	result, err := sender.Send(context.Background(), DeliveryRequest{
		OwnerID:  "o1",
		DeviceID: "d1",
		Platform: "android",
		Token:    "token-abc-12345678",
		Title:    "测试",
		Body:     "正文",
	})
	if err != nil {
		t.Fatal(err)
	}
	if result.Provider != "log" || result.ProviderMessageID == "" {
		t.Fatalf("result=%+v", result)
	}
	if len(sender.Sent) != 1 {
		t.Fatalf("sent=%d", len(sender.Sent))
	}
}

func TestLogSenderRejectsEmptyToken(t *testing.T) {
	sender := NewLogSender(nil)
	if _, err := sender.Send(context.Background(), DeliveryRequest{Token: "  "}); err == nil {
		t.Fatal("expected error")
	}
}

func TestSelectProvider(t *testing.T) {
	if SelectProvider("ios", "") != "apns" {
		t.Fatal("ios")
	}
	if SelectProvider("android", "") != "fcm" {
		t.Fatal("android")
	}
	if SelectProvider("web", "log") != "log" {
		t.Fatal("explicit")
	}
}
