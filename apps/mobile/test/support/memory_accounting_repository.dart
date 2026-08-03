// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/accounting/accounting_models.dart';
import 'package:scolvpet_mobile/features/accounting/accounting_repository.dart';

class MemoryAccountingRepository implements AccountingRepository {
  MemoryAccountingRepository({List<AccountingContactOption>? contacts})
    : _contacts = [...?contacts];

  final List<AccountingContactOption> _contacts;
  final List<AccountingCategory> _categories = [];
  final List<AccountingRecord> _records = [];
  int _seq = 0;

  @override
  Future<List<AccountingContactOption>> listContacts() async =>
      List<AccountingContactOption>.from(_contacts);

  @override
  Future<List<AccountingCategory>> listCategories({String? entryType}) async {
    final items = List<AccountingCategory>.from(_categories);
    if (entryType == null) return items;
    return items.where((c) => c.entryType == entryType).toList();
  }

  @override
  Future<AccountingCategory> createCategory(
    AccountingCategoryDraft draft,
  ) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw const AccountingRepositoryException('分类名称必填');
    }
    if (draft.entryType != 'income' && draft.entryType != 'expense') {
      throw const AccountingRepositoryException('类型无效');
    }
    if (_categories.any(
      (c) => c.entryType == draft.entryType && c.name == name,
    )) {
      throw const AccountingRepositoryException('同类型分类名称已存在');
    }
    final item = AccountingCategory(
      id: 'acat-${_seq++}',
      entryType: draft.entryType,
      name: name,
      sortOrder: draft.sortOrder,
      version: 1,
    );
    _categories.add(item);
    _categories.sort((a, b) {
      final bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;
      return a.name.compareTo(b.name);
    });
    return item;
  }

  @override
  Future<List<AccountingRecord>> listRecords({String? entryType}) async {
    var items = _records.map((r) {
      final cat = _categories.cast<AccountingCategory?>().firstWhere(
        (c) => c?.id == r.categoryId,
        orElse: () => null,
      );
      return AccountingRecord(
        id: r.id,
        categoryId: r.categoryId,
        entryType: r.entryType,
        amountCents: r.amountCents,
        currency: r.currency,
        title: r.title,
        notes: r.notes,
        contactId: r.contactId,
        occurredAt: r.occurredAt,
        version: r.version,
        categoryName: cat?.name,
        contactName: _contacts
            .cast<AccountingContactOption?>()
            .firstWhere(
              (contact) => contact?.id == r.contactId,
              orElse: () => null,
            )
            ?.name,
      );
    }).toList();
    if (entryType != null) {
      items = items.where((r) => r.entryType == entryType).toList();
    }
    items.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return items;
  }

  @override
  Future<AccountingRecord> createRecord(AccountingRecordDraft draft) async {
    if (draft.entryType != 'income' && draft.entryType != 'expense') {
      throw const AccountingRepositoryException('类型无效');
    }
    if (draft.amountCents <= 0) {
      throw const AccountingRepositoryException('金额须大于 0');
    }
    final title = draft.title.trim();
    if (title.isEmpty) {
      throw const AccountingRepositoryException('标题必填');
    }
    String? categoryName;
    if (draft.categoryId != null) {
      final cat = _categories.cast<AccountingCategory?>().firstWhere(
        (c) => c?.id == draft.categoryId,
        orElse: () => null,
      );
      if (cat == null) {
        throw const AccountingRepositoryException('分类不存在');
      }
      if (cat.entryType != draft.entryType) {
        throw const AccountingRepositoryException('分类收支类型不匹配');
      }
      categoryName = cat.name;
    }
    String? contactName;
    if (draft.contactId != null) {
      final contact = _contacts.cast<AccountingContactOption?>().firstWhere(
        (item) => item?.id == draft.contactId,
        orElse: () => null,
      );
      if (contact == null) {
        throw const AccountingRepositoryException('关联客户不存在');
      }
      contactName = contact.name;
    }
    final item = AccountingRecord(
      id: 'arec-${_seq++}',
      categoryId: draft.categoryId,
      entryType: draft.entryType,
      amountCents: draft.amountCents,
      currency: draft.currency.trim().isEmpty ? 'CNY' : draft.currency.trim(),
      title: title,
      notes: draft.notes,
      contactId: draft.contactId,
      occurredAt: draft.occurredAt?.toUtc() ?? DateTime.now().toUtc(),
      version: 1,
      categoryName: categoryName,
      contactName: contactName,
    );
    _records.insert(0, item);
    return item;
  }

  @override
  Future<AccountingSummary> getSummary({DateTime? from, DateTime? to}) async {
    // 未传范围时汇总全部记录（与生产透传语义一致）；此前按「系统当月」
    // 过滤会让固定日期的测试数据在跨月后失配（如 7 月 18 的记录在 8 月跑
    // 测试时被当月过滤掉）。
    final inRange = from == null && to == null
        ? List<AccountingRecord>.from(_records)
        : _records.where((r) {
            final lo = from ?? DateTime.fromMillisecondsSinceEpoch(0);
            final hi = to ?? DateTime.fromMillisecondsSinceEpoch(1 << 62);
            return !r.occurredAt.isBefore(lo) && !r.occurredAt.isAfter(hi);
          }).toList();
    final rangeFrom = from ?? (inRange.isEmpty
        ? DateTime.now()
        : inRange.map((r) => r.occurredAt).reduce((a, b) => a.isBefore(b) ? a : b));
    final rangeTo = to ?? (inRange.isEmpty
        ? DateTime.now()
        : inRange.map((r) => r.occurredAt).reduce((a, b) => a.isAfter(b) ? a : b));
    var income = 0;
    var expense = 0;
    final map = <String, AccountingCategorySum>{};
    for (final r in inRange) {
      if (r.isIncome) {
        income += r.amountCents;
      } else {
        expense += r.amountCents;
      }
      final key = '${r.entryType}:${r.categoryId ?? 'none'}';
      final existing = map[key];
      final name = r.categoryName?.isNotEmpty == true ? r.categoryName! : '未分类';
      if (existing == null) {
        map[key] = AccountingCategorySum(
          categoryId: r.categoryId,
          categoryName: name,
          entryType: r.entryType,
          amountCents: r.amountCents,
          count: 1,
        );
      } else {
        map[key] = AccountingCategorySum(
          categoryId: existing.categoryId,
          categoryName: existing.categoryName,
          entryType: existing.entryType,
          amountCents: existing.amountCents + r.amountCents,
          count: existing.count + 1,
        );
      }
    }
    final byCategory = map.values.toList()
      ..sort((a, b) => b.amountCents.compareTo(a.amountCents));
    return AccountingSummary(
      from: rangeFrom,
      to: rangeTo,
      incomeCents: income,
      expenseCents: expense,
      netCents: income - expense,
      currency: 'CNY',
      recordCount: inRange.length,
      byCategory: byCategory,
    );
  }
}
