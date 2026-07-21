// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/crm/crm_models.dart';
import 'package:scolvpet_mobile/features/crm/crm_repository.dart';

class MemoryCrmRepository implements CrmRepository {
  final List<CrmContact> _contacts = [];
  final List<CrmReservation> _reservations = [];
  final List<CrmHandover> _handovers = [];
  int _seq = 0;

  @override
  Future<List<CrmContact>> listContacts() async =>
      List<CrmContact>.from(_contacts);

  @override
  Future<CrmContact> createContact(CrmContactDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) throw const CrmRepositoryException('客户名称必填');
    final contact = CrmContact(
      id: 'contact-${_seq++}',
      name: name,
      phone: draft.phone,
      wechat: draft.wechat,
      notes: draft.notes,
      status: draft.status,
      version: 1,
    );
    _contacts.insert(0, contact);
    return contact;
  }

  @override
  Future<List<CrmReservation>> listReservations() async {
    return _reservations.where((r) => r.status != 'cancelled').map((r) {
      final contact = _contacts.cast<CrmContact?>().firstWhere(
        (c) => c?.id == r.contactId,
        orElse: () => null,
      );
      return CrmReservation(
        id: r.id,
        contactId: r.contactId,
        hamsterId: r.hamsterId,
        title: r.title,
        status: r.status,
        reservedAt: r.reservedAt,
        notes: r.notes,
        version: r.version,
        contactName: contact?.name,
        hamsterName: r.hamsterName,
      );
    }).toList();
  }

  @override
  Future<CrmReservation> createReservation(CrmReservationDraft draft) async {
    if (!_contacts.any((c) => c.id == draft.contactId)) {
      throw const CrmRepositoryException('客户不存在');
    }
    final contact = _contacts.firstWhere((c) => c.id == draft.contactId);
    final item = CrmReservation(
      id: 'res-${_seq++}',
      contactId: draft.contactId,
      hamsterId: draft.hamsterId,
      title: draft.title.trim().isEmpty ? '预订' : draft.title.trim(),
      status: 'held',
      reservedAt: DateTime.now().toUtc(),
      notes: draft.notes,
      version: 1,
      contactName: contact.name,
      hamsterName: null,
    );
    _reservations.insert(0, item);
    return item;
  }

  @override
  Future<CrmReservation> confirmReservation(String id, int version) async {
    return _setReservationStatus(id, version, 'confirmed');
  }

  @override
  Future<CrmReservation> cancelReservation(String id, int version) async {
    return _setReservationStatus(id, version, 'cancelled');
  }

  Future<CrmReservation> _setReservationStatus(
    String id,
    int version,
    String status,
  ) async {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index < 0) throw const CrmRepositoryException('预订不存在');
    final current = _reservations[index];
    if (current.version != version) {
      throw const CrmRepositoryException('版本冲突');
    }
    if (!current.isOpen && status != 'cancelled') {
      throw const CrmRepositoryException('当前预订不可变更');
    }
    final next = CrmReservation(
      id: current.id,
      contactId: current.contactId,
      hamsterId: current.hamsterId,
      title: current.title,
      status: status,
      reservedAt: current.reservedAt,
      notes: current.notes,
      version: current.version + 1,
      contactName: current.contactName,
      hamsterName: current.hamsterName,
    );
    _reservations[index] = next;
    return next;
  }

  @override
  Future<List<CrmHandover>> listHandovers() async {
    return _handovers.where((h) => h.status != 'cancelled').map((h) {
      final contact = _contacts.cast<CrmContact?>().firstWhere(
        (c) => c?.id == h.contactId,
        orElse: () => null,
      );
      return CrmHandover(
        id: h.id,
        contactId: h.contactId,
        reservationId: h.reservationId,
        hamsterId: h.hamsterId,
        status: h.status,
        scheduledAt: h.scheduledAt,
        completedAt: h.completedAt,
        notes: h.notes,
        version: h.version,
        contactName: contact?.name,
        hamsterName: h.hamsterName,
      );
    }).toList();
  }

  @override
  Future<CrmHandover> createHandover(CrmHandoverDraft draft) async {
    if (!_contacts.any((c) => c.id == draft.contactId)) {
      throw const CrmRepositoryException('客户不存在');
    }
    final contact = _contacts.firstWhere((c) => c.id == draft.contactId);
    final item = CrmHandover(
      id: 'hand-${_seq++}',
      contactId: draft.contactId,
      reservationId: draft.reservationId,
      hamsterId: draft.hamsterId,
      status: 'scheduled',
      scheduledAt: draft.scheduledAt?.toUtc() ?? DateTime.now().toUtc(),
      notes: draft.notes,
      version: 1,
      contactName: contact.name,
      hamsterName: null,
    );
    _handovers.insert(0, item);
    return item;
  }

  @override
  Future<CrmHandover> completeHandover(String id, int version) async {
    final index = _handovers.indexWhere((h) => h.id == id);
    if (index < 0) throw const CrmRepositoryException('交付单不存在');
    final current = _handovers[index];
    if (current.version != version) {
      throw const CrmRepositoryException('版本冲突');
    }
    if (!current.isOpen) {
      throw const CrmRepositoryException('仅待交付可完成');
    }
    final next = CrmHandover(
      id: current.id,
      contactId: current.contactId,
      reservationId: current.reservationId,
      hamsterId: current.hamsterId,
      status: 'completed',
      scheduledAt: current.scheduledAt,
      completedAt: DateTime.now().toUtc(),
      notes: current.notes,
      version: current.version + 1,
      contactName: current.contactName,
      hamsterName: current.hamsterName,
    );
    _handovers[index] = next;
    if (current.reservationId != null) {
      final ri = _reservations.indexWhere((r) => r.id == current.reservationId);
      if (ri >= 0) {
        final r = _reservations[ri];
        _reservations[ri] = CrmReservation(
          id: r.id,
          contactId: r.contactId,
          hamsterId: r.hamsterId,
          title: r.title,
          status: 'handed_over',
          reservedAt: r.reservedAt,
          notes: r.notes,
          version: r.version + 1,
          contactName: r.contactName,
        );
      }
    }
    final ci = _contacts.indexWhere((c) => c.id == current.contactId);
    if (ci >= 0 && _contacts[ci].status == 'lead') {
      final c = _contacts[ci];
      _contacts[ci] = CrmContact(
        id: c.id,
        name: c.name,
        phone: c.phone,
        wechat: c.wechat,
        notes: c.notes,
        status: 'active',
        version: c.version + 1,
      );
    }
    return next;
  }
}
