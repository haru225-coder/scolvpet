package importcsv

import (
	"bytes"
	"testing"

	"golang.org/x/text/encoding/simplifiedchinese"
	"golang.org/x/text/transform"
)

func TestTemplatesExposeAllI2Types(t *testing.T) {
	templates := Templates()
	if len(templates) != 3 {
		t.Fatalf("template count = %d, want 3", len(templates))
	}
	seen := make(map[TemplateType]bool)
	for _, template := range templates {
		seen[template.Type] = true
	}
	for _, expected := range []TemplateType{TemplateHamster, TemplateEnclosure, TemplateWeight} {
		if !seen[expected] {
			t.Fatalf("missing template %s", expected)
		}
	}
}

func TestParseDetectsBOMDelimiterTemplateAndColumns(t *testing.T) {
	data := append([]byte{0xef, 0xbb, 0xbf}, []byte("内部编号;昵称;性别;出生日期\nH-1;小雪;female;2026-01-02\n")...)
	file, err := Parse(data, ParseOptions{})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	if file.Encoding != EncodingUTF8BOM {
		t.Fatalf("encoding = %s", file.Encoding)
	}
	if file.Delimiter != ';' {
		t.Fatalf("delimiter = %q", file.Delimiter)
	}
	if file.Template != TemplateHamster {
		t.Fatalf("template = %s", file.Template)
	}
	if got := file.Mapping["内部编号"]; got != "internal_code" {
		t.Fatalf("internal code mapping = %q", got)
	}
	if got := file.Rows[0].Mapped["name"]; got != "小雪" {
		t.Fatalf("mapped name = %q", got)
	}
}

func TestParseDetectsGB18030AndTabSeparatedEnclosure(t *testing.T) {
	source := "笼盒编号\t笼架\t容量\nC-1\tR-1\t2\n"
	encoded, _, err := transform.Bytes(simplifiedchinese.GB18030.NewEncoder(), []byte(source))
	if err != nil {
		t.Fatalf("encode fixture: %v", err)
	}
	if bytes.Equal(encoded, []byte(source)) {
		t.Fatal("fixture unexpectedly stayed UTF-8")
	}
	file, err := Parse(encoded, ParseOptions{})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	if file.Encoding != EncodingGB18030 || file.Delimiter != '\t' || file.Template != TemplateEnclosure {
		t.Fatalf("detected encoding=%s delimiter=%q template=%s", file.Encoding, file.Delimiter, file.Template)
	}
}

func TestExplicitMappingOverridesCandidateMapping(t *testing.T) {
	file, err := Parse([]byte("编号,说明\nH-1,备注内容\n"), ParseOptions{
		Template: TemplateHamster,
		Mapping:  map[string]string{"说明": "notes"},
	})
	if err != nil {
		t.Fatalf("Parse: %v", err)
	}
	if got := file.Rows[0].Mapped["notes"]; got != "备注内容" {
		t.Fatalf("notes = %q", got)
	}
}
