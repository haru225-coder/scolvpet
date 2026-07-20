// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/stud/stud_models.dart';
import 'package:scolvpet_mobile/features/stud/stud_repository.dart';

class MemoryStudRepository implements StudRepository {
  final List<StudListing> _listings = [];
  final List<StudDeal> _deals = [];
  int _seq = 0;
  final String myOwnerId = 'owner-me';

  @override
  Future<List<StudListing>> listListings({bool mineOnly = false}) async {
    final items = _listings.where((l) {
      if (mineOnly) return l.isMine;
      return l.published || l.isMine;
    }).toList();
    return List<StudListing>.from(items);
  }

  @override
  Future<StudListing> createListing(StudListingDraft draft) async {
    final sire = draft.sireLabel.trim();
    if (sire.isEmpty) throw const StudRepositoryException('种公名称必填');
    final item = StudListing(
      id: 'slist-${_seq++}',
      ownerId: myOwnerId,
      sireLabel: sire,
      title: draft.title.trim().isEmpty ? '$sire 借配' : draft.title.trim(),
      feeCents: draft.feeCents < 0 ? 0 : draft.feeCents,
      currency: draft.currency,
      notes: draft.notes,
      published: draft.published,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
      catteryName: '我的熊舍',
      isMine: true,
    );
    _listings.insert(0, item);
    return item;
  }

  @override
  Future<StudListing> unpublishListing(String id) async {
    final i = _listings.indexWhere((l) => l.id == id && l.isMine);
    if (i < 0) throw const StudRepositoryException('挂牌不存在');
    final c = _listings[i];
    final next = StudListing(
      id: c.id,
      ownerId: c.ownerId,
      sireLabel: c.sireLabel,
      title: c.title,
      feeCents: c.feeCents,
      currency: c.currency,
      notes: c.notes,
      published: false,
      version: c.version + 1,
      updatedAt: DateTime.now().toUtc(),
      catteryName: c.catteryName,
      isMine: true,
    );
    _listings[i] = next;
    return next;
  }

  @override
  Future<List<StudDeal>> listDeals() async =>
      _deals.where((d) => d.status != 'cancelled').toList();

  @override
  Future<StudDeal> createDeal(StudDealDraft draft) async {
    final partner = draft.partnerCatteryName.trim();
    if (partner.isEmpty) {
      throw const StudRepositoryException('对方熊舍名称必填');
    }
    if (draft.side != 'provider' && draft.side != 'requester') {
      throw const StudRepositoryException('side 无效');
    }
    var fee = draft.feeCents;
    var currency = draft.currency;
    String? partnerAnimal = draft.partnerAnimalLabel;
    if (draft.listingId != null) {
      final listing = _listings.cast<StudListing?>().firstWhere(
        (l) => l?.id == draft.listingId,
        orElse: () => null,
      );
      if (listing == null) {
        throw const StudRepositoryException('挂牌不存在');
      }
      if (draft.feeCents == 0) fee = listing.feeCents;
      currency = listing.currency;
      partnerAnimal ??= listing.sireLabel;
    }
    final item = StudDeal(
      id: 'sdeal-${_seq++}',
      listingId: draft.listingId,
      side: draft.side,
      status: draft.side == 'provider' ? 'draft' : 'requested',
      myHamsterLabel: draft.myHamsterLabel,
      partnerCatteryName: partner,
      partnerContact: draft.partnerContact,
      partnerAnimalLabel: partnerAnimal,
      feeCents: fee < 0 ? 0 : fee,
      currency: currency,
      notes: draft.notes,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
    );
    _deals.insert(0, item);
    return item;
  }

  @override
  Future<StudDeal> confirm(String id) => _set(id, (c) {
    if (!c.canConfirm) throw const StudRepositoryException('当前不可确认');
    return _copy(c, status: 'confirmed', confirmedAt: DateTime.now().toUtc());
  });

  @override
  Future<StudDeal> start(String id) => _set(id, (c) {
    if (!c.canStart) throw const StudRepositoryException('当前不可开始');
    return _copy(c, status: 'in_progress', startedAt: DateTime.now().toUtc());
  });

  @override
  Future<StudDeal> complete(String id) => _set(id, (c) {
    if (!c.canComplete) throw const StudRepositoryException('当前不可完成');
    return _copy(c, status: 'completed', completedAt: DateTime.now().toUtc());
  });

  @override
  Future<StudDeal> cancel(String id) => _set(id, (c) {
    if (!c.canCancel) throw const StudRepositoryException('当前不可取消');
    return _copy(c, status: 'cancelled', cancelledAt: DateTime.now().toUtc());
  });

  Future<StudDeal> _set(String id, StudDeal Function(StudDeal) fn) async {
    final i = _deals.indexWhere((d) => d.id == id);
    if (i < 0) throw const StudRepositoryException('借配单不存在');
    final next = fn(_deals[i]);
    _deals[i] = next;
    return next;
  }

  StudDeal _copy(
    StudDeal c, {
    required String status,
    DateTime? confirmedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return StudDeal(
      id: c.id,
      listingId: c.listingId,
      side: c.side,
      status: status,
      myHamsterLabel: c.myHamsterLabel,
      partnerCatteryName: c.partnerCatteryName,
      partnerContact: c.partnerContact,
      partnerAnimalLabel: c.partnerAnimalLabel,
      feeCents: c.feeCents,
      currency: c.currency,
      notes: c.notes,
      confirmedAt: confirmedAt ?? c.confirmedAt,
      startedAt: startedAt ?? c.startedAt,
      completedAt: completedAt ?? c.completedAt,
      cancelledAt: cancelledAt ?? c.cancelledAt,
      version: c.version + 1,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}

