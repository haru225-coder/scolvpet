package httpapi

import "testing"

func TestNormalizeCrmPhone(t *testing.T) {
	cases := []struct {
		in   string
		want string
	}{
		{"", ""},
		{" 13800138000 ", "13800138000"},
		{"+86 138-0013-8000", "+8613800138000"},
		{"(010) 1234 5678", "01012345678"},
		{"abc", ""},
	}
	for _, tc := range cases {
		if got := normalizeCrmPhone(tc.in); got != tc.want {
			t.Fatalf("normalizeCrmPhone(%q)=%q want %q", tc.in, got, tc.want)
		}
	}
}

func TestNormalizeCrmWechat(t *testing.T) {
	if got := normalizeCrmWechat("  wx_user  "); got != "wx_user" {
		t.Fatalf("wechat normalize: %q", got)
	}
}

func TestEmptyToNilAndDeref(t *testing.T) {
	if emptyToNil(nil) != nil {
		t.Fatal("nil pointer should stay nil")
	}
	blank := "  "
	if emptyToNil(&blank) != nil {
		t.Fatal("blank should become nil")
	}
	value := " hi "
	got := emptyToNil(&value)
	if got == nil || *got != "hi" {
		t.Fatalf("trim failed: %#v", got)
	}
	if derefString(nil) != "" {
		t.Fatal("deref nil")
	}
	if derefString(&value) != " hi " {
		t.Fatal("deref keeps original")
	}
}
