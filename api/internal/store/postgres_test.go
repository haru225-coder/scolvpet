package store

import (
	"encoding/json"
	"testing"
)

func TestCanonicalRequestIncludesMethodPathAndNormalizedPayload(t *testing.T) {
	left := canonicalRequest("post", "/v1/species-rule-versions", []byte(`{"b":2,"a":1}`))
	right := canonicalRequest("POST", "/v1/species-rule-versions", []byte(`{"a":1,"b":2}`))
	if left != right {
		t.Fatalf("canonical payload mismatch:\nleft=%s\nright=%s", left, right)
	}
	if left == canonicalRequest("POST", "/v1/other", []byte(`{"a":1,"b":2}`)) {
		t.Fatal("request path must participate in idempotency hash")
	}
	if left == canonicalRequest("PATCH", "/v1/species-rule-versions", []byte(`{"a":1,"b":2}`)) {
		t.Fatal("request method must participate in idempotency hash")
	}
}

func TestDecodeStoredResponseRestoresHeadersAndSupportsLegacyBody(t *testing.T) {
	body := []byte(`{"data":{"id":"rule-1"}}`)
	stored, err := json.Marshal(storedResponse{
		Body:    body,
		Headers: map[string]string{"ETag": `"2"`, "Location": "/v1/rule-1"},
	})
	if err != nil {
		t.Fatal(err)
	}
	decodedBody, headers := decodeStoredResponse(stored)
	if string(decodedBody) != string(body) {
		t.Fatalf("body mismatch: %s", decodedBody)
	}
	if headers["ETag"] != `"2"` || headers["Location"] != "/v1/rule-1" {
		t.Fatalf("headers not restored: %#v", headers)
	}
	legacyBody, legacyHeaders := decodeStoredResponse(body)
	if string(legacyBody) != string(body) || len(legacyHeaders) != 0 {
		t.Fatalf("legacy response compatibility failed: body=%s headers=%#v", legacyBody, legacyHeaders)
	}
}
