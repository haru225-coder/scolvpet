import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'contracts_models.dart';
import 'contracts_repository.dart';

class ContractsController extends ChangeNotifier {
  ContractsController({required this.repository});

  final ContractsRepository repository;

  I2AsyncState<List<DocTemplate>> contractTemplates = const I2AsyncState.idle();
  I2AsyncState<List<DocTemplate>> receiptTemplates = const I2AsyncState.idle();
  I2AsyncState<List<DocDocument>> contracts = const I2AsyncState.idle();
  I2AsyncState<List<DocDocument>> receipts = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;
  bool _installingStarterTemplates = false;

  Future<void> refreshAll({bool installStarterTemplates = true}) async {
    await Future.wait([
      refreshContractTemplates(),
      refreshReceiptTemplates(),
      refreshContracts(),
      refreshReceipts(),
    ]);
    if (installStarterTemplates) await _ensureStarterTemplates();
  }

  Future<void> _ensureStarterTemplates() async {
    if (_installingStarterTemplates) return;
    final contractsNow = contractTemplates.data ?? const <DocTemplate>[];
    final receiptsNow = receiptTemplates.data ?? const <DocTemplate>[];
    final missingContracts = starterContractTemplates
        .where((draft) => !contractsNow.any((item) => item.name == draft.name))
        .toList();
    final missingReceipts = starterReceiptTemplates
        .where((draft) => !receiptsNow.any((item) => item.name == draft.name))
        .toList();
    if (missingContracts.isEmpty && missingReceipts.isEmpty) return;

    _installingStarterTemplates = true;
    try {
      for (final draft in missingContracts) {
        await repository.createTemplate('contract', draft);
      }
      for (final draft in missingReceipts) {
        await repository.createTemplate('receipt', draft);
      }
      await Future.wait([
        refreshContractTemplates(),
        refreshReceiptTemplates(),
      ]);
    } catch (error) {
      lastMessage = contractsErrorMessage(error);
    } finally {
      _installingStarterTemplates = false;
      notifyListeners();
    }
  }

  Future<void> refreshContractTemplates() =>
      _refreshTemplates('contract', (s) => contractTemplates = s);

  Future<void> refreshReceiptTemplates() =>
      _refreshTemplates('receipt', (s) => receiptTemplates = s);

  Future<void> refreshContracts() =>
      _refreshDocuments('contract', (s) => contracts = s);

  Future<void> refreshReceipts() =>
      _refreshDocuments('receipt', (s) => receipts = s);

  Future<void> _refreshTemplates(
    String kind,
    void Function(I2AsyncState<List<DocTemplate>>) assign,
  ) async {
    assign(const I2AsyncState.loading());
    notifyListeners();
    try {
      final items = await repository.listTemplates(kind);
      assign(
        items.isEmpty
            ? const I2AsyncState.empty(message: '暂无模板')
            : I2AsyncState.data(items),
      );
    } catch (error) {
      assign(I2AsyncState.error(contractsErrorMessage(error)));
    }
    notifyListeners();
  }

  Future<void> _refreshDocuments(
    String kind,
    void Function(I2AsyncState<List<DocDocument>>) assign,
  ) async {
    assign(const I2AsyncState.loading());
    notifyListeners();
    try {
      final items = await repository.listDocuments(kind);
      assign(
        items.isEmpty
            ? const I2AsyncState.empty(message: '暂无单据')
            : I2AsyncState.data(items),
      );
    } catch (error) {
      assign(I2AsyncState.error(contractsErrorMessage(error)));
    }
    notifyListeners();
  }

  Future<bool> createTemplate(String kind, DocTemplateDraft draft) =>
      _run(() async {
        await repository.createTemplate(kind, draft);
        lastMessage = '模板已创建';
        if (kind == 'receipt') {
          await refreshReceiptTemplates();
        } else {
          await refreshContractTemplates();
        }
      });

  Future<bool> createContract(ContractDraft draft) => _run(() async {
    await repository.createContract(draft);
    lastMessage = '合同草稿已创建';
    await refreshContracts();
  });

  Future<bool> createReceipt(ReceiptDraft draft) => _run(() async {
    await repository.createReceipt(draft);
    lastMessage = '回执草稿已创建';
    await refreshReceipts();
  });

  Future<bool> issueDocument(DocDocument item) => _run(() async {
    await repository.issueDocument(item.kind, item.id, item.version);
    lastMessage = '${item.kindLabel}已签发';
    if (item.kind == 'receipt') {
      await refreshReceipts();
    } else {
      await refreshContracts();
    }
  });

  Future<bool> revokeDocument(DocDocument item) => _run(() async {
    await repository.revokeDocument(item.kind, item.id, item.version);
    lastMessage = '${item.kindLabel}已撤销，客户链接已失效';
    if (item.kind == 'receipt') {
      await refreshReceipts();
    } else {
      await refreshContracts();
    }
  });

  Future<bool> _run(Future<void> Function() body) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await body();
      actionState = const I2AsyncState.data(null);
      notifyListeners();
      return true;
    } catch (error) {
      final message = contractsErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
