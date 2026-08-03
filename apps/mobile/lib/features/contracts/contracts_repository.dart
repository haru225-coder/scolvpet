import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' show P1Api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'contracts_models.dart';

abstract interface class ContractsRepository {
  Future<List<DocTemplate>> listTemplates(String kind);
  Future<DocTemplate> createTemplate(String kind, DocTemplateDraft draft);

  Future<List<DocDocument>> listDocuments(String kind);
  Future<DocDocument> getDocument(String kind, String id);
  Future<DocDocument> createContract(ContractDraft draft);
  Future<DocDocument> createReceipt(ReceiptDraft draft);
  Future<DocDocument> issueDocument(String kind, String id, int version);
  Future<DocDocument> revokeDocument(String kind, String id, int version);
}

class ContractsRepositoryException implements Exception {
  const ContractsRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String contractsErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '合同/回执请求失败',
  mapLocal: (e) => e is ContractsRepositoryException ? e.message : null,
);

String fillTemplate(String body, Map<String, String> vars) {
  var out = body;
  vars.forEach((key, value) {
    out = out.replaceAll('{{$key}}', value);
  });
  return out;
}

String defaultTemplateBody(String kind) {
  if (kind == 'receipt') {
    return starterReceiptTemplates.first.bodyText;
  }
  return starterContractTemplates.first.bodyText;
}

class DefaultApiContractsRepository implements ContractsRepository {
  DefaultApiContractsRepository({required this.client})
    : _p1Api = P1Api(client.p2Dio);

  final ApiClient client;
  final P1Api _p1Api;
  final _uuid = const Uuid();
  String _key() => 'doc-${_uuid.v4()}';

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
      throw const ContractsRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  String _base(String kind) => kind == 'receipt' ? '/receipts' : '/contracts';

  @override
  Future<List<DocTemplate>> listTemplates(String kind) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '${_base(kind)}/templates',
    );
    return _listData(response).map(DocTemplate.fromJson).toList();
  }

  @override
  Future<DocTemplate> createTemplate(
    String kind,
    DocTemplateDraft draft,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(kind)}/templates',
      data: {
        'name': draft.name,
        if (draft.bodyText.trim().isNotEmpty) 'body_text': draft.bodyText,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return DocTemplate.fromJson(_data(response));
  }

  @override
  Future<List<DocDocument>> listDocuments(String kind) async {
    final response = await client.dio.get<Map<String, dynamic>>(_base(kind));
    return _listData(response).map(DocDocument.fromJson).toList();
  }

  @override
  Future<DocDocument> getDocument(String kind, String id) async {
    final response = kind == 'receipt'
        ? await _p1Api.getReceipt(documentId: id)
        : await _p1Api.getContract(documentId: id);
    final data = response.data?.data;
    if (data == null) {
      throw const ContractsRepositoryException('响应为空');
    }
    return DocDocument.fromJson(data.toJson());
  }

  @override
  Future<DocDocument> createContract(ContractDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/contracts',
      data: {
        'template_id': draft.templateId,
        if (draft.contactId != null) 'contact_id': draft.contactId,
        if (draft.handoverId != null) 'handover_id': draft.handoverId,
        if (draft.reservationId != null) 'reservation_id': draft.reservationId,
        if (draft.title.trim().isNotEmpty) 'title': draft.title,
        if (draft.notes != null) 'notes': draft.notes,
        if (draft.contactName != null) 'contact_name': draft.contactName,
        if (draft.hamsterName != null) 'hamster_name': draft.hamsterName,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return DocDocument.fromJson(_data(response));
  }

  @override
  Future<DocDocument> createReceipt(ReceiptDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/receipts',
      data: {
        'template_id': draft.templateId,
        if (draft.contactId != null) 'contact_id': draft.contactId,
        if (draft.handoverId != null) 'handover_id': draft.handoverId,
        if (draft.reservationId != null) 'reservation_id': draft.reservationId,
        if (draft.title.trim().isNotEmpty) 'title': draft.title,
        'amount_cents': draft.amountCents,
        'currency': draft.currency,
        if (draft.notes != null) 'notes': draft.notes,
        if (draft.contactName != null) 'contact_name': draft.contactName,
        if (draft.hamsterName != null) 'hamster_name': draft.hamsterName,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return DocDocument.fromJson(_data(response));
  }

  @override
  Future<DocDocument> issueDocument(String kind, String id, int version) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(kind)}/$id/issue',
      options: Options(
        headers: {'Idempotency-Key': _key(), 'If-Match': '"$version"'},
      ),
    );
    return DocDocument.fromJson(_data(response));
  }

  @override
  Future<DocDocument> revokeDocument(
    String kind,
    String id,
    int version,
  ) async {
    final response = kind == 'receipt'
        ? await _p1Api.revokeReceipt(
            documentId: id,
            ifMatch: '"$version"',
            idempotencyKey: _key(),
          )
        : await _p1Api.revokeContract(
            documentId: id,
            ifMatch: '"$version"',
            idempotencyKey: _key(),
          );
    final data = response.data?.data;
    if (data == null) {
      throw const ContractsRepositoryException('响应为空');
    }
    return DocDocument.fromJson(data.toJson());
  }
}
