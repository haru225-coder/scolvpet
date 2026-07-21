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
