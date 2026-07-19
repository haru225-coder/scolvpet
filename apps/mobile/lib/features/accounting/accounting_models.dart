String formatAccountingAmount(
  int cents, {
  String currency = 'CNY',
  bool showPositiveSign = false,
}) {
  final negative = cents < 0;
  final absolute = cents.abs();
  final whole = (absolute ~/ 100).toString();
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final sign = negative ? '-' : (showPositiveSign ? '+' : '');
  final symbol = currency.toUpperCase() == 'CNY' ? '¥' : '$currency ';
  return '$sign$symbol$grouped.$fraction';
}

class AccountingContactOption {
  const AccountingContactOption({
    required this.id,
    required this.name,
    this.status,
  });

  final String id;
  final String name;
  final String? status;

  factory AccountingContactOption.fromJson(Map<String, dynamic> json) =>
      AccountingContactOption(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        status: json['status'] as String?,
      );
}

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
    return formatAccountingAmount(
      isIncome ? amountCents : -amountCents,
      currency: currency,
      showPositiveSign: isIncome,
    );
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
    return formatAccountingAmount(amountCents);
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

  String get incomeLabel =>
      formatAccountingAmount(incomeCents, currency: currency);
  String get expenseLabel =>
      formatAccountingAmount(expenseCents, currency: currency);
  String get netLabel => formatAccountingAmount(netCents, currency: currency);

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
                .map(
                  (e) => AccountingCategorySum.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
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

/// 首次使用财务模块时的起步分类，实际写入当前账号后仍可继续自定义。
const defaultAccountingCategoryDrafts = <AccountingCategoryDraft>[
  AccountingCategoryDraft(entryType: 'expense', name: '饲料', sortOrder: 10),
  AccountingCategoryDraft(entryType: 'expense', name: '垫料', sortOrder: 20),
  AccountingCategoryDraft(entryType: 'expense', name: '医疗', sortOrder: 30),
  AccountingCategoryDraft(entryType: 'expense', name: '设备', sortOrder: 40),
  AccountingCategoryDraft(entryType: 'income', name: '交付收入', sortOrder: 10),
  AccountingCategoryDraft(entryType: 'income', name: '配对 / 服务', sortOrder: 20),
  AccountingCategoryDraft(entryType: 'income', name: '其他收入', sortOrder: 30),
];

class AccountingRecordDraft {
  const AccountingRecordDraft({
    required this.entryType,
    required this.amountCents,
    required this.title,
    this.categoryId,
    this.currency = 'CNY',
    this.notes,
    this.contactId,
    this.occurredAt,
  });

  final String entryType;
  final int amountCents;
  final String title;
  final String? categoryId;
  final String currency;
  final String? notes;
  final String? contactId;
  final DateTime? occurredAt;
}
