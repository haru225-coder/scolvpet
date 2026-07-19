import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'accounting_models.dart';
import 'accounting_repository.dart';

class AccountingController extends ChangeNotifier {
  AccountingController({required this.repository});

  final AccountingRepository repository;

  I2AsyncState<List<AccountingContactOption>> contactsState =
      const I2AsyncState.idle();
  I2AsyncState<List<AccountingCategory>> categoriesState =
      const I2AsyncState.idle();
  I2AsyncState<List<AccountingRecord>> recordsState = const I2AsyncState.idle();
  I2AsyncState<AccountingSummary> summaryState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;
  bool _refreshing = false;
  bool _disposed = false;

  bool get isBusy => actionState.status == I2AsyncStatus.loading;
  bool get isRefreshing => _refreshing;

  Future<void> refreshAll({bool bootstrapCategories = true}) async {
    if (_refreshing) return;
    _refreshing = true;
    _notifyIfActive();
    try {
      await Future.wait([
        refreshContacts(),
        refreshCategories(bootstrapDefaults: bootstrapCategories),
        refreshRecords(),
        refreshSummary(),
      ]);
    } finally {
      _refreshing = false;
      _notifyIfActive();
    }
  }

  Future<void> refreshContacts() async {
    contactsState = const I2AsyncState.loading();
    _notifyIfActive();
    try {
      final items = await repository.listContacts();
      contactsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无客户')
          : I2AsyncState.data(items);
    } catch (error) {
      contactsState = I2AsyncState.error(accountingErrorMessage(error));
    }
    _notifyIfActive();
  }

  Future<void> refreshCategories({bool bootstrapDefaults = true}) async {
    categoriesState = const I2AsyncState.loading();
    _notifyIfActive();
    try {
      var items = await repository.listCategories();
      if (items.isEmpty && bootstrapDefaults) {
        for (final draft in defaultAccountingCategoryDrafts) {
          try {
            await repository.createCategory(draft);
          } on Object {
            // A partially initialized account may already contain one of the
            // defaults; keep loading the categories that are available.
          }
        }
        items = await repository.listCategories();
      }
      categoriesState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无分类')
          : I2AsyncState.data(items);
    } catch (error) {
      categoriesState = I2AsyncState.error(accountingErrorMessage(error));
    }
    _notifyIfActive();
  }

  Future<void> refreshRecords() async {
    recordsState = const I2AsyncState.loading();
    _notifyIfActive();
    try {
      final items = await repository.listRecords();
      recordsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无流水')
          : I2AsyncState.data(items);
    } catch (error) {
      recordsState = I2AsyncState.error(accountingErrorMessage(error));
    }
    _notifyIfActive();
  }

  Future<void> refreshSummary() async {
    summaryState = const I2AsyncState.loading();
    _notifyIfActive();
    try {
      final summary = await repository.getSummary();
      summaryState = I2AsyncState.data(summary);
    } catch (error) {
      summaryState = I2AsyncState.error(accountingErrorMessage(error));
    }
    _notifyIfActive();
  }

  Future<bool> createCategory(AccountingCategoryDraft draft) => _run(() async {
    await repository.createCategory(draft);
    lastMessage = '分类已创建';
    await refreshCategories(bootstrapDefaults: false);
  });

  Future<bool> createRecord(AccountingRecordDraft draft) => _run(() async {
    await repository.createRecord(draft);
    lastMessage = '流水已记账';
    await Future.wait([refreshRecords(), refreshSummary()]);
  });

  Future<bool> _run(Future<void> Function() body) async {
    if (isBusy) {
      lastMessage = '正在处理上一项操作，请稍候';
      _notifyIfActive();
      return false;
    }
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    _notifyIfActive();
    try {
      await body();
      actionState = const I2AsyncState.data(null);
      _notifyIfActive();
      return true;
    } catch (error) {
      final message = accountingErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      _notifyIfActive();
      return false;
    }
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
