import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'crm_models.dart';
import 'crm_repository.dart';

class CrmController extends ChangeNotifier {
  CrmController({required this.repository});

  final CrmRepository repository;

  I2AsyncState<List<CrmContact>> contactsState = const I2AsyncState.idle();
  I2AsyncState<List<CrmReservation>> reservationsState =
      const I2AsyncState.idle();
  I2AsyncState<List<CrmHandover>> handoversState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([
      refreshContacts(),
      refreshReservations(),
      refreshHandovers(),
    ]);
  }

  Future<void> refreshContacts() async {
    contactsState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listContacts();
      contactsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无客户')
          : I2AsyncState.data(items);
    } catch (error) {
      contactsState = I2AsyncState.error(crmErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshReservations() async {
    reservationsState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listReservations();
      reservationsState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无预订')
          : I2AsyncState.data(items);
    } catch (error) {
      reservationsState = I2AsyncState.error(crmErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshHandovers() async {
    handoversState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listHandovers();
      handoversState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无交付')
          : I2AsyncState.data(items);
    } catch (error) {
      handoversState = I2AsyncState.error(crmErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> createContact(CrmContactDraft draft) => _run(() async {
    await repository.createContact(draft);
    lastMessage = '客户已创建';
    await refreshContacts();
  });

  Future<bool> createReservation(CrmReservationDraft draft) => _run(() async {
    await repository.createReservation(draft);
    lastMessage = '预订已创建';
    await refreshReservations();
  });

  Future<bool> confirmReservation(CrmReservation item) => _run(() async {
    await repository.confirmReservation(item.id, item.version);
    lastMessage = '预订已确认';
    await refreshReservations();
  });

  Future<bool> cancelReservation(CrmReservation item) => _run(() async {
    await repository.cancelReservation(item.id, item.version);
    lastMessage = '预订已取消';
    await refreshReservations();
  });

  Future<bool> createHandover(CrmHandoverDraft draft) => _run(() async {
    await repository.createHandover(draft);
    lastMessage = '交付单已创建';
    await refreshHandovers();
  });

  Future<bool> completeHandover(CrmHandover item) => _run(() async {
    await repository.completeHandover(item.id, item.version);
    lastMessage = '交付已完成';
    await Future.wait([
      refreshHandovers(),
      refreshReservations(),
      refreshContacts(),
    ]);
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
      final message = crmErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
