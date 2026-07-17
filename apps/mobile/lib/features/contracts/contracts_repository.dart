import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import 'contracts_models.dart';

abstract interface class ContractsRepository {
  Future<List<DocTemplate>> listTemplates(String kind);
  Future<DocTemplate> createTemplate(String kind, DocTemplateDraft draft);

  Future<List<DocDocument>> listDocuments(String kind);
  Future<DocDocument> createContract(ContractDraft draft);
  Future<DocDocument> createReceipt(ReceiptDraft draft);
  Future<DocDocument> issueDocument(String kind, String id, int version);
}

class ContractsRepositoryException implements Exception {
  const ContractsRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String contractsErrorMessage(Object error) {
  if (error is ContractsRepositoryException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return '合同/回执请求失败';
  }
  return error.toString();
}

String fillTemplate(String body, Map<String, String> vars) {
  var out = body;
  vars.forEach((key, value) {
    out = out.replaceAll('{{$key}}', value);
  });
  return out;
}

String defaultTemplateBody(String kind) {
  if (kind == 'receipt') {
    return '回执\n\n客户：{{contact_name}}\n项目：{{title}}\n金额：{{amount}}\n日期：{{date}}\n备注：{{notes}}\n\n已确认收款。';
  }
  return '交接协议\n\n客户：{{contact_name}}\n项目：{{title}}\n个体：{{hamster_name}}\n日期：{{date}}\n\n双方确认交付事项。\n备注：{{notes}}';
}

class MemoryContractsRepository implements ContractsRepository {
  final List<DocTemplate> _templates = [];
  final List<DocDocument> _documents = [];
  int _seq = 0;

  @override
  Future<List<DocTemplate>> listTemplates(String kind) async =>
      _templates.where((t) => t.kind == kind).toList();

  @override
  Future<DocTemplate> createTemplate(String kind, DocTemplateDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw const ContractsRepositoryException('模板名称必填');
    }
    final body = draft.bodyText.trim().isEmpty
        ? defaultTemplateBody(kind)
        : draft.bodyText.trim();
    final item = DocTemplate(
      id: 'tpl-${_seq++}',
      kind: kind,
      name: name,
      bodyText: body,
      version: 1,
    );
    _templates.insert(0, item);
    return item;
  }

  @override
  Future<List<DocDocument>> listDocuments(String kind) async => _documents
      .where((d) => d.kind == kind && d.status != 'archived')
      .toList();

  @override
  Future<DocDocument> createContract(ContractDraft draft) async {
    final tpl = _requireTemplate(draft.templateId, 'contract');
    final title = draft.title.trim().isEmpty ? tpl.name : draft.title.trim();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final filled = fillTemplate(tpl.bodyText, {
      'contact_name': draft.contactName?.trim() ?? '',
      'title': title,
      'hamster_name': draft.hamsterName?.trim() ?? '',
      'amount': '',
      'date': today,
      'notes': draft.notes?.trim() ?? '',
    });
    final item = DocDocument(
      id: 'doc-${_seq++}',
      templateId: tpl.id,
      kind: 'contract',
      contactId: draft.contactId,
      handoverId: draft.handoverId,
      title: title,
      bodyFilled: filled,
      currency: 'CNY',
      status: 'draft',
      notes: draft.notes,
      version: 1,
      contactName: draft.contactName,
    );
    _documents.insert(0, item);
    return item;
  }

  @override
  Future<DocDocument> createReceipt(ReceiptDraft draft) async {
    final tpl = _requireTemplate(draft.templateId, 'receipt');
    if (draft.amountCents < 0) {
      throw const ContractsRepositoryException('金额不能为负');
    }
    final title = draft.title.trim().isEmpty ? tpl.name : draft.title.trim();
    final currency = draft.currency.trim().isEmpty ? 'CNY' : draft.currency.trim();
    final amountYuan = (draft.amountCents / 100).toStringAsFixed(2);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final filled = fillTemplate(tpl.bodyText, {
      'contact_name': draft.contactName?.trim() ?? '',
      'title': title,
      'hamster_name': '',
      'amount': '$amountYuan $currency',
      'date': today,
      'notes': draft.notes?.trim() ?? '',
    });
    final item = DocDocument(
      id: 'doc-${_seq++}',
      templateId: tpl.id,
      kind: 'receipt',
      contactId: draft.contactId,
      title: title,
      bodyFilled: filled,
      amountCents: draft.amountCents,
      currency: currency,
      status: 'draft',
      notes: draft.notes,
      version: 1,
      contactName: draft.contactName,
    );
    _documents.insert(0, item);
    return item;
  }

  @override
  Future<DocDocument> issueDocument(String kind, String id, int version) async {
    final index = _documents.indexWhere((d) => d.id == id && d.kind == kind);
    if (index < 0) throw const ContractsRepositoryException('单据不存在');
    final current = _documents[index];
    if (current.version != version) {
      throw const ContractsRepositoryException('版本冲突');
    }
    if (!current.isDraft) {
      throw const ContractsRepositoryException('仅草稿可签发');
    }
    final next = DocDocument(
      id: current.id,
      templateId: current.templateId,
      kind: current.kind,
      contactId: current.contactId,
      handoverId: current.handoverId,
      title: current.title,
      bodyFilled: current.bodyFilled,
      amountCents: current.amountCents,
      currency: current.currency,
      status: 'issued',
      issuedAt: DateTime.now().toUtc(),
      notes: current.notes,
      version: current.version + 1,
      contactName: current.contactName,
    );
    _documents[index] = next;
    return next;
  }

  DocTemplate _requireTemplate(String id, String kind) {
    return _templates.firstWhere(
      (t) => t.id == id && t.kind == kind,
      orElse: () => throw const ContractsRepositoryException('模板不存在'),
    );
  }
}

class DefaultApiContractsRepository implements ContractsRepository {
  DefaultApiContractsRepository({required this.client});

  final ApiClient client;
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
  Future<DocDocument> createContract(ContractDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/contracts',
      data: {
        'template_id': draft.templateId,
        if (draft.contactId != null) 'contact_id': draft.contactId,
        if (draft.handoverId != null) 'handover_id': draft.handoverId,
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
        if (draft.title.trim().isNotEmpty) 'title': draft.title,
        'amount_cents': draft.amountCents,
        'currency': draft.currency,
        if (draft.notes != null) 'notes': draft.notes,
        if (draft.contactName != null) 'contact_name': draft.contactName,
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
        headers: {
          'Idempotency-Key': _key(),
          'If-Match': '"$version"',
        },
      ),
    );
    return DocDocument.fromJson(_data(response));
  }
}
