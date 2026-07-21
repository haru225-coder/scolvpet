// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/contracts/contracts_models.dart';
import 'package:scolvpet_mobile/features/contracts/contracts_repository.dart';

class MemoryContractsRepository implements ContractsRepository {
  final List<DocTemplate> _templates = [];
  final List<DocDocument> _documents = [];
  int _seq = 0;

  @override
  Future<List<DocTemplate>> listTemplates(String kind) async =>
      _templates.where((t) => t.kind == kind).toList();

  @override
  Future<DocTemplate> createTemplate(
    String kind,
    DocTemplateDraft draft,
  ) async {
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
    final currency = draft.currency.trim().isEmpty
        ? 'CNY'
        : draft.currency.trim();
    final amountYuan = (draft.amountCents / 100).toStringAsFixed(2);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final filled = fillTemplate(tpl.bodyText, {
      'contact_name': draft.contactName?.trim() ?? '',
      'title': title,
      'hamster_name': draft.hamsterName?.trim() ?? '',
      'amount': '$amountYuan $currency',
      'date': today,
      'notes': draft.notes?.trim() ?? '',
    });
    final item = DocDocument(
      id: 'doc-${_seq++}',
      templateId: tpl.id,
      kind: 'receipt',
      contactId: draft.contactId,
      handoverId: draft.handoverId,
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
    final token = current.publicToken ?? 'doc_mem_${current.id}';
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
      publicToken: token,
      publicPath: '/d/$token',
      publicUrl: 'https://example.test/d/$token',
    );
    _documents[index] = next;
    return next;
  }

  @override
  Future<DocDocument> revokeDocument(
    String kind,
    String id,
    int version,
  ) async {
    final index = _documents.indexWhere((d) => d.id == id && d.kind == kind);
    if (index < 0) throw const ContractsRepositoryException('单据不存在');
    final current = _documents[index];
    if (current.version != version) {
      throw const ContractsRepositoryException('版本冲突');
    }
    if (current.status != 'issued') {
      throw const ContractsRepositoryException('仅已签发单据可撤销');
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
      status: 'archived',
      issuedAt: current.issuedAt,
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
