package httpapi

import (
	"net/http"
	"strings"
	"testing"
)

// The confirm endpoint executes writes on behalf of the caller; every
// confirmable action must map to a direct route, and the mapping must deny
// roles that the direct route denies (docs/31 §5.2).
func TestAssistantConfirmMirrorsDirectRBAC(t *testing.T) {
	confirmable := []string{
		"create_task", "complete_task", "create_weight_record",
		"create_hamster", "update_hamster", "create_enclosure",
		"create_crm_contact", "update_crm_contact", "create_crm_reservation",
		"confirm_crm_reservation", "cancel_crm_reservation",
		"create_crm_handover", "complete_crm_handover",
		"create_accounting_record", "create_health_record",
		"record_pairing_observation", "create_separation_task",
		"create_contract", "create_receipt",
	}
	for _, actionType := range confirmable {
		route, known := assistantActionRoute(actionType)
		if !known {
			t.Fatalf("confirmable action %q has no direct-route mapping", actionType)
		}
		direct := principalCanRequest("staff", http.MethodPost, route)
		if actionType == "create_enclosure" || actionType == "create_weight_record" ||
			actionType == "create_task" || actionType == "complete_task" ||
			actionType == "create_separation_task" ||
			actionType == "create_accounting_record" || actionType == "create_health_record" ||
			actionType == "record_pairing_observation" {
			if direct {
				t.Fatalf("staff unexpectedly passes the direct rule for %s (%s)", actionType, route)
			}
		}
		// breeder keeps its legitimate writes through confirm.
		if actionType == "create_weight_record" && !principalCanRequest("breeder", http.MethodPost, route) {
			t.Fatalf("breeder must keep weight-record writes via confirm")
		}
		if actionType == "create_health_record" && !principalCanRequest("breeder", http.MethodPost, route) {
			t.Fatalf("breeder must keep health-record writes via confirm")
		}
		if actionType == "record_pairing_observation" && !principalCanRequest("breeder", http.MethodPost, route) {
			t.Fatalf("breeder must keep pairing observation writes via confirm")
		}
		if actionType == "create_separation_task" && !principalCanRequest("breeder", http.MethodPost, route) {
			t.Fatalf("breeder must keep separation task writes via confirm")
		}
		// staff keeps CRM writes through confirm.
		if strings.HasPrefix(actionType, "create_crm_") || actionType == "confirm_crm_reservation" ||
			actionType == "cancel_crm_reservation" || actionType == "complete_crm_handover" {
			if !principalCanRequest("staff", http.MethodPost, route) {
				t.Fatalf("staff must keep CRM writes via confirm for %s", actionType)
			}
		}
		// staff keeps contract/receipt writes through confirm.
		if (actionType == "create_contract" || actionType == "create_receipt") &&
			!principalCanRequest("staff", http.MethodPost, route) {
			t.Fatalf("staff must keep document writes via confirm for %s", actionType)
		}
	}
	if _, known := assistantActionRoute("future_unmapped_action"); known {
		t.Fatal("unknown action types must stay unmapped (fail-closed)")
	}
}
