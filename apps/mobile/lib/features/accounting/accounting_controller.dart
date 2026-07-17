import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'accounting_models.dart';
import 'accounting_repository.dart';

class AccountingController extends ChangeNotifier {
  AccountingController({required this.repository});

  final AccountingRepository repository;

  I2AsyncState<List<AccountingCategory>> categoriesState =
      const I2AsyncState.idle();
  I2AsyncState<List<AccountingRecord>> recordsState = const I2AsyncState.idle();
  I2AsyncState<AccountingSummary> summaryState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([
      refreshCategories(),
      refreshRecords(),
      refreshSummary(),
    ]);
  }

  Future<void> refreshCategories() async {
    categoriesState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listCategories();
      categoriesState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无分类')
          : I2AsyncState.data(items);
    } catch (error) {
      categoriesState = I2AsyncState.error(accountingErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshRecords() async {
    recordsState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listRecords();
      recordsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无流水')
          : I2AsyncState.data(items);
    } catch (error) {
      recordsState = I2AsyncState.error(accountingErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshSummary() async {
    summaryState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final summary = await repository.getSummary();
      summaryState = I2AsyncState.data(summary);
    } catch (error) {
      summaryState = I2AsyncState.error(accountingErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> createCategory(AccountingCategoryDraft draft) => _run(() async {
    await repository.createCategory(draft);
    lastMessage = '分类已创建';
    await refreshCategories();
  });

  Future<bool> createRecord(AccountingRecordDraft draft) => _run(() async {
    await repository.createRecord(draft);
    lastMessage = '流水已记账';
    await Future.wait([refreshRecords(), refreshSummary()]);
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
      final message = accountingErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
