import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'accounting_models.dart';

abstract interface class AccountingRepository {
  Future<List<AccountingContactOption>> listContacts();

  Future<List<AccountingCategory>> listCategories({String? entryType});
  Future<AccountingCategory> createCategory(AccountingCategoryDraft draft);

  Future<List<AccountingRecord>> listRecords({String? entryType});
  Future<AccountingRecord> createRecord(AccountingRecordDraft draft);

  Future<AccountingSummary> getSummary({DateTime? from, DateTime? to});
}

class AccountingRepositoryException implements Exception {
  const AccountingRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String accountingErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '财务请求失败',
  mapLocal: (e) => e is AccountingRepositoryException ? e.message : null,
);

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
    final now = DateTime.now();
    final rangeFrom = from ?? DateTime(now.year, now.month, 1).toUtc();
    final rangeTo =
        to ??
        DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(microseconds: 1)).toUtc();
    final inRange = _records.where((r) {
      return !r.occurredAt.isBefore(rangeFrom) &&
          !r.occurredAt.isAfter(rangeTo);
    }).toList();
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

class DefaultApiAccountingRepository implements AccountingRepository {
  DefaultApiAccountingRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'acct-${_uuid.v4()}';

  List<Map<String, dynamic>> _listData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const AccountingRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<AccountingContactOption>> listContacts() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/crm/contacts',
    );
    return _listData(response).map(AccountingContactOption.fromJson).toList();
  }

  @override
  Future<List<AccountingCategory>> listCategories({String? entryType}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/accounting/categories',
      queryParameters: {if (entryType != null) 'entry_type': entryType},
    );
    return _listData(response).map(AccountingCategory.fromJson).toList();
  }

  @override
  Future<AccountingCategory> createCategory(
    AccountingCategoryDraft draft,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/accounting/categories',
      data: {
        'entry_type': draft.entryType,
        'name': draft.name,
        'sort_order': draft.sortOrder,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return AccountingCategory.fromJson(_data(response));
  }

  @override
  Future<List<AccountingRecord>> listRecords({String? entryType}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/accounting/records',
      queryParameters: {if (entryType != null) 'entry_type': entryType},
    );
    return _listData(response).map(AccountingRecord.fromJson).toList();
  }

  @override
  Future<AccountingRecord> createRecord(AccountingRecordDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/accounting/records',
      data: {
        'entry_type': draft.entryType,
        'amount_cents': draft.amountCents,
        'title': draft.title,
        'currency': draft.currency,
        if (draft.categoryId != null) 'category_id': draft.categoryId,
        if (draft.notes != null) 'notes': draft.notes,
        if (draft.contactId != null) 'contact_id': draft.contactId,
        if (draft.occurredAt != null)
          'occurred_at': draft.occurredAt!.toUtc().toIso8601String(),
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return AccountingRecord.fromJson(_data(response));
  }

  @override
  Future<AccountingSummary> getSummary({DateTime? from, DateTime? to}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/accounting/summary',
      queryParameters: {
        if (from != null) 'from': from.toIso8601String().substring(0, 10),
        if (to != null) 'to': to.toIso8601String().substring(0, 10),
      },
    );
    return AccountingSummary.fromJson(_data(response));
  }
}
