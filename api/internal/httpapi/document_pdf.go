package httpapi

import (
	"bytes"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"unicode"

	"github.com/go-pdf/fpdf"
	"github.com/google/uuid"
)

func (s *Server) downloadContractPDF(w http.ResponseWriter, r *http.Request) {
	s.downloadDocumentPDF(w, r, "contract")
}

func (s *Server) downloadReceiptPDF(w http.ResponseWriter, r *http.Request) {
	s.downloadDocumentPDF(w, r, "receipt")
}

func (s *Server) downloadDocumentPDF(w http.ResponseWriter, r *http.Request, kind string) {
	ownerID, ok := s.authenticateMemberOwner(w, r)
	if !ok {
		return
	}
	documentID, err := uuid.Parse(strings.TrimSpace(r.PathValue("document_id")))
	if err != nil || documentID == uuid.Nil {
		writeAPIError(w, r, validationError("document_id", "单据 ID 无效"))
		return
	}
	item, err := s.getDocDocument(r.Context(), ownerID, documentID, kind)
	if err != nil {
		writeAPIError(w, r, err)
		return
	}
	if item.Status != "issued" {
		writeAPIError(w, r, validationError("status", "仅已签发单据可下载 PDF"))
		return
	}
	pdfBytes, err := renderDocumentPDF(item, strings.TrimSpace(os.Getenv("SCOLVPET_PDF_FONT_PATH")))
	if err != nil {
		writeAPIError(w, r, err)
		return
	}

	filename := sanitizePDFFilename(item.Title, kind, documentID)
	w.Header().Set("Content-Type", "application/pdf")
	w.Header().Set("Content-Length", strconv.Itoa(len(pdfBytes)))
	w.Header().Set("Content-Disposition", `inline; filename="`+filename+`"; filename*=UTF-8''`+url.PathEscape(filename))
	w.Header().Set("Cache-Control", "private, no-store")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(pdfBytes)
}

func renderDocumentPDF(item docDocument, fontPath string) ([]byte, error) {
	pdf := fpdf.New("P", "mm", "A4", "")
	pdf.SetTitle(item.Title, true)
	pdf.SetAuthor("ScolvPet", true)
	pdf.SetMargins(20, 18, 20)
	pdf.SetAutoPageBreak(true, 18)
	pdf.SetCompression(false)
	pdf.AddPage()

	fontName := "Helvetica"
	if fontPath != "" {
		if _, err := os.Stat(fontPath); err == nil {
			pdf.AddUTF8Font("ScolvPetSans", "", fontPath)
			pdf.AddUTF8Font("ScolvPetSans", "B", fontPath)
			if pdf.Error() == nil {
				fontName = "ScolvPetSans"
			}
		}
	}

	kindLabel := "Contract"
	if item.Kind == "receipt" {
		kindLabel = "Receipt"
	}
	pdf.SetFont(fontName, "B", 18)
	pdf.CellFormat(0, 10, pdfSafeText(kindLabel+": "+item.Title, fontName), "", 1, "L", false, 0, "")
	pdf.SetFont(fontName, "", 10)
	pdf.SetTextColor(95, 95, 95)
	pdf.CellFormat(0, 6, pdfSafeText("Document ID: "+item.ID.String(), fontName), "", 1, "L", false, 0, "")
	pdf.CellFormat(0, 6, pdfSafeText("Status: issued", fontName), "", 1, "L", false, 0, "")
	if item.IssuedAt != nil {
		pdf.CellFormat(0, 6, pdfSafeText("Issued at: "+item.IssuedAt.UTC().Format("2006-01-02 15:04 UTC"), fontName), "", 1, "L", false, 0, "")
	}
	pdf.Ln(6)
	pdf.SetTextColor(30, 30, 30)
	pdf.SetFont(fontName, "", 11)
	for _, line := range strings.Split(item.BodyFilled, "\n") {
		text := pdfSafeText(line, fontName)
		if strings.TrimSpace(text) == "" {
			pdf.Ln(5)
			continue
		}
		pdf.MultiCell(0, 6, text, "", "L", false)
	}
	if item.Notes != nil && strings.TrimSpace(*item.Notes) != "" {
		pdf.Ln(5)
		pdf.SetFont(fontName, "B", 11)
		pdf.CellFormat(0, 6, pdfSafeText("Notes", fontName), "", 1, "L", false, 0, "")
		pdf.SetFont(fontName, "", 11)
		pdf.MultiCell(0, 6, pdfSafeText(*item.Notes, fontName), "", "L", false)
	}
	if err := pdf.Error(); err != nil {
		return nil, err
	}
	var output bytes.Buffer
	if err := pdf.Output(&output); err != nil {
		return nil, err
	}
	return output.Bytes(), nil
}

func pdfSafeText(value, fontName string) string {
	if fontName != "Helvetica" {
		return value
	}
	return strings.Map(func(r rune) rune {
		if r == '\n' || r == '\t' || (r >= 0x20 && r <= unicode.MaxASCII) {
			return r
		}
		return '?'
	}, value)
}

func sanitizePDFFilename(title, kind string, id uuid.UUID) string {
	name := strings.TrimSpace(title)
	if name == "" {
		name = kind
	}
	name = strings.Map(func(r rune) rune {
		if r == '/' || r == '\\' || r == ':' || r == '"' || unicode.IsControl(r) {
			return '-'
		}
		return r
	}, name)
	name = strings.TrimSpace(name)
	if name == "" {
		name = kind
	}
	return name + "-" + id.String()[:8] + ".pdf"
}
