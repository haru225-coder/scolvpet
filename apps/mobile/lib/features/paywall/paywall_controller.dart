import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'paywall_models.dart';
import 'paywall_repository.dart';

class PaywallController extends ChangeNotifier {
  PaywallController({required this.repository});

  final PaywallRepository repository;

  I2AsyncState<List<PlanCatalogEntry>> catalogState = const I2AsyncState.idle();
  I2AsyncState<EntitlementSnapshot> snapshotState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([refreshCatalog(), refreshCurrent()]);
  }

  Future<void> refreshCatalog() async {
    catalogState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listCatalog();
      catalogState = I2AsyncState.data(items);
    } catch (error) {
      catalogState = I2AsyncState.error(paywallErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshCurrent() async {
    snapshotState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final snap = await repository.current();
      snapshotState = I2AsyncState.data(snap);
    } catch (error) {
      snapshotState = I2AsyncState.error(paywallErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> activatePro() => _run(() async {
    await repository.sandboxActivate('pro');
    lastMessage = '已沙箱激活专业版（非真实支付）';
    await refreshCurrent();
  });

  Future<bool> activateFree() => _run(() async {
    await repository.sandboxActivate('free');
    lastMessage = '已回到免费版';
    await refreshCurrent();
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
      final message = paywallErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
