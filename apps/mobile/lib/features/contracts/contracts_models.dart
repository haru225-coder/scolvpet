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
  const DocTemplateDraft({required this.name, this.bodyText = ''});

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
    this.handoverId,
    this.title = '',
    required this.amountCents,
    this.currency = 'CNY',
    this.notes,
    this.contactName,
    this.hamsterName,
  });

  final String templateId;
  final String? contactId;
  final String? handoverId;
  final String title;
  final int amountCents;
  final String currency;
  final String? notes;
  final String? contactName;
  final String? hamsterName;
}

class ContractsLaunchContext {
  const ContractsLaunchContext({
    this.kind = 'contract',
    this.contactId,
    this.contactName,
    this.handoverId,
    this.hamsterId,
    this.hamsterName,
  });

  final String kind;
  final String? contactId;
  final String? contactName;
  final String? handoverId;
  final String? hamsterId;
  final String? hamsterName;
}

const starterContractTemplates = <DocTemplateDraft>[
  DocTemplateDraft(
    name: '仓鼠交接协议',
    bodyText: '''仓鼠交接协议

客户：{{contact_name}}
交接事项：{{title}}
交接个体：{{hamster_name}}
交接日期：{{date}}

一、熊舍已向客户说明该个体的基础档案、近期观察、日常饮食与饲养注意事项。
二、客户已核对交接个体，并确认收到双方约定的随附用品和资料。
三、交接后的环境、饮食和作息调整应循序渐进；如出现异常，应及时联系熊舍并寻求专业兽医意见。
四、双方确认本协议记录的信息真实、完整，未填写事项以双方另行确认的记录为准。

补充约定：{{notes}}

熊舍确认：________________
客户确认：________________''',
  ),
  DocTemplateDraft(
    name: '预订确认单',
    bodyText: '''预订确认单

客户：{{contact_name}}
预订事项：{{title}}
意向个体：{{hamster_name}}
确认日期：{{date}}

双方确认已就预订范围、后续沟通方式和预计交付安排完成说明。最终交付以个体健康状况、双方确认记录和实际交接为准。

补充约定：{{notes}}

熊舍确认：________________
客户确认：________________''',
  ),
];

const starterReceiptTemplates = <DocTemplateDraft>[
  DocTemplateDraft(
    name: '订金收款回执',
    bodyText: '''订金收款回执

客户：{{contact_name}}
收款项目：{{title}}
关联个体：{{hamster_name}}
收款金额：{{amount}}
收款日期：{{date}}

现确认收到以上款项。本回执用于记录本次收款，后续交付内容以双方确认的预订和交接记录为准。

备注：{{notes}}

经办确认：________________
客户确认：________________''',
  ),
  DocTemplateDraft(
    name: '尾款及交付回执',
    bodyText: '''尾款及交付回执

客户：{{contact_name}}
交付项目：{{title}}
交付个体：{{hamster_name}}
收款金额：{{amount}}
交付日期：{{date}}

现确认收到以上款项，并已按双方确认的交接记录完成相关资料与用品说明。

备注：{{notes}}

熊舍确认：________________
客户确认：________________''',
  ),
];
