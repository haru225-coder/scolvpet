import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'contracts_models.dart';

const _documentFontAsset = 'assets/fonts/NotoSansSC-Variable.ttf';

Future<Uint8List> buildDocumentPdf(DocDocument document) async {
  final fontData = await rootBundle.load(_documentFontAsset);
  final font = pw.Font.ttf(fontData);
  final accent = PdfColor.fromHex('#c77852');
  final ink = PdfColor.fromHex('#24211f');
  final muted = PdfColor.fromHex('#706a66');
  final paper = PdfColor.fromHex('#fffdfb');
  final line = PdfColor.fromHex('#ded9d5');

  final pdf = pw.Document(
    title: document.title,
    author: '熊舍管家',
    subject: document.kindLabel,
    creator: '熊舍管家 v0.03',
  );
  final theme = pw.ThemeData.withFont(base: font, bold: font);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(46, 42, 46, 46),
      theme: theme,
      header: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 18),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '熊舍管家',
              style: pw.TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              document.kindLabel,
              style: pw.TextStyle(color: muted, fontSize: 10),
            ),
          ],
        ),
      ),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              document.statusLabel,
              style: pw.TextStyle(color: muted, fontSize: 9),
            ),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(color: muted, fontSize: 9),
            ),
          ],
        ),
      ),
      build: (context) => [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            color: paper,
            borderRadius: pw.BorderRadius.circular(14),
            border: pw.Border.all(color: line, width: 0.8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                document.title,
                style: pw.TextStyle(
                  color: ink,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _metaText(document.kindLabel, muted),
                  _metaText(document.statusLabel, muted),
                  if (document.contactName?.trim().isNotEmpty == true)
                    _metaText(document.contactName!, muted),
                  if (document.amountLabel != null)
                    _metaText(document.amountLabel!, accent),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: line, thickness: 0.8),
              pw.SizedBox(height: 18),
              pw.Text(
                document.bodyFilled,
                style: pw.TextStyle(color: ink, fontSize: 12, lineSpacing: 6),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 28),
        pw.Row(
          children: [
            pw.Expanded(child: _signatureBlock('熊舍确认', line, muted)),
            pw.SizedBox(width: 32),
            pw.Expanded(child: _signatureBlock('客户确认', line, muted)),
          ],
        ),
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _metaText(String value, PdfColor color) {
  return pw.Text(value, style: pw.TextStyle(color: color, fontSize: 10));
}

pw.Widget _signatureBlock(String label, PdfColor line, PdfColor muted) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(height: 1, color: line),
      pw.SizedBox(height: 7),
      pw.Text(label, style: pw.TextStyle(color: muted, fontSize: 10)),
    ],
  );
}

String documentPdfFileName(DocDocument document) {
  final cleaned = document.title
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
  final base = cleaned.isEmpty ? document.kindLabel : cleaned;
  return '$base.pdf';
}
