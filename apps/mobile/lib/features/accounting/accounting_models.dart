class AccountingCategory {
  const AccountingCategory({
    required this.id,
    required this.entryType,
    required this.name,
    required this.sortOrder,
    required this.version,
  });

  final String id;
  final String entryType;
  final String name;
  final int sortOrder;
  final int version;

  String get entryTypeLabel => entryType == 'income' ? '收入' : '支出';

  factory AccountingCategory.fromJson(Map<String, dynamic> json) =>
      AccountingCategory(
        id: json['id'] as String? ?? '',
        entryType: json['entry_type'] as String? ?? 'expense',
        name: json['name'] as String? ?? '',
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        version: (json['version'] as num?)?.toInt() ?? 1,
      );
}

class AccountingRecord {
  const AccountingRecord({
    required this.id,
    this.categoryId,
    required this.entryType,
    required this.amountCents,
    required this.currency,
    required this.title,
    this.notes,
    this.contactId,
    required this.occurredAt,
    required this.version,
    this.categoryName,
    this.contactName,
  });

  final String id;
  final String? categoryId;
  final String entryType;
  final int amountCents;
  final String currency;
  final String title;
  final String? notes;
  final String? contactId;
  final DateTime occurredAt;
  final int version;
  final String? categoryName;
  final String? contactName;

  bool get isIncome => entryType == 'income';

  String get entryTypeLabel => isIncome ? '收入' : '支出';

  String get amountLabel {
    final yuan = amountCents / 100.0;
    final sign = isIncome ? '+' : '-';
    return '$sign${yuan.toStringAsFixed(2)} $currency';
  }

  factory AccountingRecord.fromJson(Map<String, dynamic> json) =>
      AccountingRecord(
        id: json['id'] as String? ?? '',
        categoryId: json['category_id'] as String?,
        entryType: json['entry_type'] as String? ?? 'expense',
        amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
        currency: json['currency'] as String? ?? 'CNY',
        title: json['title'] as String? ?? '',
        notes: json['notes'] as String?,
        contactId: json['contact_id'] as String?,
        occurredAt:
            DateTime.tryParse(json['occurred_at'] as String? ?? '')?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        version: (json['version'] as num?)?.toInt() ?? 1,
        categoryName: json['category_name'] as String?,
        contactName: json['contact_name'] as String?,
      );
}

class AccountingCategorySum {
  const AccountingCategorySum({
    this.categoryId,
    required this.categoryName,
    required this.entryType,
    required this.amountCents,
    required this.count,
  });

  final String? categoryId;
  final String categoryName;
  final String entryType;
  final int amountCents;
  final int count;

  String get amountLabel {
    final yuan = amountCents / 100.0;
    return '${yuan.toStringAsFixed(2)} CNY';
  }

  factory AccountingCategorySum.fromJson(Map<String, dynamic> json) =>
      AccountingCategorySum(
        categoryId: json['category_id'] as String?,
        categoryName: json['category_name'] as String? ?? '未分类',
        entryType: json['entry_type'] as String? ?? 'expense',
        amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

class AccountingSummary {
  const AccountingSummary({
    required this.from,
    required this.to,
    required this.incomeCents,
    required this.expenseCents,
    required this.netCents,
    required this.currency,
    required this.recordCount,
    required this.byCategory,
  });

  final DateTime from;
  final DateTime to;
  final int incomeCents;
  final int expenseCents;
  final int netCents;
  final String currency;
  final int recordCount;
  final List<AccountingCategorySum> byCategory;

  String _fmt(int cents) => (cents / 100.0).toStringAsFixed(2);

  String get incomeLabel => '${_fmt(incomeCents)} $currency';
  String get expenseLabel => '${_fmt(expenseCents)} $currency';
  String get netLabel => '${_fmt(netCents)} $currency';

  factory AccountingSummary.fromJson(Map<String, dynamic> json) {
    final by = json['by_category'];
    return AccountingSummary(
      from:
          DateTime.tryParse(json['from'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      to:
          DateTime.tryParse(json['to'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      incomeCents: (json['income_cents'] as num?)?.toInt() ?? 0,
      expenseCents: (json['expense_cents'] as num?)?.toInt() ?? 0,
      netCents: (json['net_cents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'CNY',
      recordCount: (json['record_count'] as num?)?.toInt() ?? 0,
      byCategory: by is List
          ? by
                .whereType<Map>()
                .map((e) => AccountingCategorySum.fromJson(
                      Map<String, dynamic>.from(e),
                    ))
                .toList()
          : const [],
    );
  }
}

class AccountingCategoryDraft {
  const AccountingCategoryDraft({
    required this.entryType,
    required this.name,
    this.sortOrder = 0,
  });

  final String entryType;
  final String name;
  final int sortOrder;
}

class AccountingRecordDraft {
  const AccountingRecordDraft({
    required this.entryType,
    required this.amountCents,
    required this.title,
    this.categoryId,
    this.currency = 'CNY',
    this.notes,
    this.contactId,
  });

  final String entryType;
  final int amountCents;
  final String title;
  final String? categoryId;
  final String currency;
  final String? notes;
  final String? contactId;
}
