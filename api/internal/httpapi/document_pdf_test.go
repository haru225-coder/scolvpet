package httpapi

import (
	"bytes"
	"os"
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestRenderDocumentPDFFallbackIsValid(t *testing.T) {
	note := "备注：需要循序渐进观察。"
	pdfBytes, err := renderDocumentPDF(docDocument{
		ID:         uuid.New(),
		Kind:       "contract",
		Title:      "交接协议",
		BodyFilled: "客户：小雪\n交接个体：SY-001\n\n请保留本单据。",
		Notes:      &note,
	}, "")
	if err != nil {
		t.Fatalf("render fallback PDF: %v", err)
	}
	if !bytes.HasPrefix(pdfBytes, []byte("%PDF-")) {
		t.Fatalf("missing PDF header: %q", pdfBytes[:minInt(len(pdfBytes), 16)])
	}
	if !bytes.HasSuffix(bytes.TrimSpace(pdfBytes), []byte("%%EOF")) {
		t.Fatal("missing PDF EOF marker")
	}
	if !strings.Contains(string(pdfBytes), "SY-001") {
		t.Fatal("fallback PDF should preserve ASCII business identifiers")
	}
	if output := os.Getenv("SCOLVPET_PDF_TEST_OUTPUT"); output != "" {
		if err := os.WriteFile(output, pdfBytes, 0o600); err != nil {
			t.Fatalf("write PDF inspection artifact: %v", err)
		}
	}
}

func TestRenderDocumentPDFUsesConfiguredCJKFontWhenPresent(t *testing.T) {
	fontPath := "../../../apps/mobile/assets/fonts/NotoSansSC-Variable.ttf"
	if _, err := os.Stat(fontPath); err != nil {
		t.Skip("repo font asset is not available in this checkout")
	}
	pdfBytes, err := renderDocumentPDF(docDocument{
		ID:         uuid.New(),
		Kind:       "receipt",
		Title:      "收款回执",
		BodyFilled: "客户：小雪\n收款项目：定金",
	}, fontPath)
	if err != nil {
		t.Fatalf("render CJK PDF: %v", err)
	}
	if !bytes.HasPrefix(pdfBytes, []byte("%PDF-")) {
		t.Fatal("configured CJK font output is not a PDF")
	}
	if output := os.Getenv("SCOLVPET_PDF_CJK_TEST_OUTPUT"); output != "" {
		if err := os.WriteFile(output, pdfBytes, 0o600); err != nil {
			t.Fatalf("write CJK PDF inspection artifact: %v", err)
		}
	}
}

func minInt(left, right int) int {
	if left < right {
		return left
	}
	return right
}
