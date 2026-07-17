class DocTemplate {
  const DocTemplate({
    required this.id,
    required this.kind,
    required this.name,
    required this.bodyText,
    required this.version,
  });

  final String id;
  final String kind;
  final String name;
  final String bodyText;
  final int version;

  String get kindLabel => kind == 'receipt' ? '回执' : '合同';

  factory DocTemplate.fromJson(Map<String, dynamic> json) => DocTemplate(
    id: json['id'] as String? ?? '',
    kind: json['kind'] as String? ?? 'contract',
    name: json['name'] as String? ?? '',
    bodyText: json['body_text'] as String? ?? '',
    version: (json['version'] as num?)?.toInt() ?? 1,
  );
}

class DocDocument {
  const DocDocument({
    required this.id,
    required this.templateId,
    required this.kind,
    this.contactId,
    this.handoverId,
    required this.title,
    required this.bodyFilled,
    this.amountCents,
    required this.currency,
    required this.status,
    this.issuedAt,
    this.notes,
    required this.version,
    this.contactName,
  });

  final String id;
  final String templateId;
  final String kind;
  final String? contactId;
  final String? handoverId;
  final String title;
  final String bodyFilled;
  final int? amountCents;
  final String currency;
  final String status;
  final DateTime? issuedAt;
  final String? notes;
  final int version;
  final String? contactName;

  String get kindLabel => kind == 'receipt' ? '回执' : '合同';

  String get statusLabel => switch (status) {
    'draft' => '草稿',
    'issued' => '已签发',
    'archived' => '已归档',
    _ => status,
  };

  bool get isDraft => status == 'draft';

  String? get amountLabel {
    if (amountCents == null) return null;
    final yuan = amountCents! / 100.0;
    return '${yuan.toStringAsFixed(2)} $currency';
  }

  factory DocDocument.fromJson(Map<String, dynamic> json) => DocDocument(
    id: json['id'] as String? ?? '',
    templateId: json['template_id'] as String? ?? '',
    kind: json['kind'] as String? ?? 'contract',
    contactId: json['contact_id'] as String?,
    handoverId: json['handover_id'] as String?,
    title: json['title'] as String? ?? '',
    bodyFilled: json['body_filled'] as String? ?? '',
    amountCents: (json['amount_cents'] as num?)?.toInt(),
    currency: json['currency'] as String? ?? 'CNY',
    status: json['status'] as String? ?? 'draft',
    issuedAt: DateTime.tryParse(json['issued_at'] as String? ?? '')?.toUtc(),
    notes: json['notes'] as String?,
    version: (json['version'] as num?)?.toInt() ?? 1,
    contactName: json['contact_name'] as String?,
  );
}

class DocTemplateDraft {
  const DocTemplateDraft({
    required this.name,
    this.bodyText = '',
  });

  final String name;
  final String bodyText;
}

class ContractDraft {
  const ContractDraft({
    required this.templateId,
    this.contactId,
    this.handoverId,
    this.title = '',
    this.notes,
    this.contactName,
    this.hamsterName,
  });

  final String templateId;
  final String? contactId;
  final String? handoverId;
  final String title;
  final String? notes;
  final String? contactName;
  final String? hamsterName;
}

class ReceiptDraft {
  const ReceiptDraft({
    required this.templateId,
    this.contactId,
    this.title = '',
    required this.amountCents,
    this.currency = 'CNY',
    this.notes,
    this.contactName,
  });

  final String templateId;
  final String? contactId;
  final String title;
  final int amountCents;
  final String currency;
  final String? notes;
  final String? contactName;
}
