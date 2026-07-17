import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'stud_models.dart';
import 'stud_repository.dart';

class StudController extends ChangeNotifier {
  StudController({required this.repository});

  final StudRepository repository;

  I2AsyncState<List<StudListing>> listingsState = const I2AsyncState.idle();
  I2AsyncState<List<StudDeal>> dealsState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([refreshListings(), refreshDeals()]);
  }

  Future<void> refreshListings() async {
    listingsState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listListings();
      listingsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无借配挂牌')
          : I2AsyncState.data(items);
    } catch (error) {
      listingsState = I2AsyncState.error(studErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshDeals() async {
    dealsState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listDeals();
      dealsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无借配履约单')
          : I2AsyncState.data(items);
    } catch (error) {
      dealsState = I2AsyncState.error(studErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> createListing(StudListingDraft draft) => _run(() async {
    await repository.createListing(draft);
    lastMessage = '挂牌已发布';
    await refreshListings();
  });

  Future<bool> unpublishListing(StudListing item) => _run(() async {
    await repository.unpublishListing(item.id);
    lastMessage = '已下架挂牌';
    await refreshListings();
  });

  Future<bool> createDeal(StudDealDraft draft) => _run(() async {
    await repository.createDeal(draft);
    lastMessage = '借配单已创建';
    await refreshDeals();
  });

  Future<bool> confirm(StudDeal item) => _run(() async {
    await repository.confirm(item.id);
    lastMessage = '已确认';
    await refreshDeals();
  });

  Future<bool> start(StudDeal item) => _run(() async {
    await repository.start(item.id);
    lastMessage = '已开始借配';
    await refreshDeals();
  });

  Future<bool> complete(StudDeal item) => _run(() async {
    await repository.complete(item.id);
    lastMessage = '借配已完成';
    await refreshDeals();
  });

  Future<bool> cancel(StudDeal item) => _run(() async {
    await repository.cancel(item.id);
    lastMessage = '已取消';
    await refreshDeals();
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
      final message = studErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
