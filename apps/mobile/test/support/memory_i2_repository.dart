// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/weight/weight_alerts.dart';

// 用于测试和离线演示的简单 repository 骨架，业务接线可替换为真实 adapter。
class MemoryI2Repository implements I2Repository {
  MemoryI2Repository({
    I2Snapshot? snapshot,
    this.failReads = false,
    this.failWrites = false,
    List<I2WeightRecord>? weights,
  }) : _snapshot =
           snapshot ??
           I2Snapshot(
             hamsters: const <I2Hamster>[],
             litters: const <I2Litter>[],
             enclosures: const <I2Enclosure>[],
             lastSyncedAt: null,
           ),
       _weights = [...?weights, ...?snapshot?.recentWeights];

  I2Snapshot _snapshot;
  final List<I2WeightRecord> _weights;
  final List<I2EnclosureStay> _stays = <I2EnclosureStay>[];
  final bool failReads;
  final bool failWrites;
  final List<I2ImportRowResult> _rows = <I2ImportRowResult>[];
  int _sequence = 0;

  void _readGuard() {
    if (failReads) throw const I2RepositoryException('请求未完成，请稍后重试');
  }

  void _writeGuard() {
    if (failWrites) throw const I2RepositoryException('离线只读，联网后重新提交/再操作');
  }

  @override
  Future<I2Snapshot> loadSnapshot() async {
    _readGuard();
    return I2Snapshot(
      hamsters: _snapshot.hamsters,
      litters: _snapshot.litters,
      enclosures: _snapshot.enclosures,
      lastSyncedAt: _snapshot.lastSyncedAt ?? DateTime.now(),
      recentWeights: List<I2WeightRecord>.from(_weights),
    );
  }

  @override
  Future<I2HamsterDetail> getHamsterDetail(String hamsterId) async {
    _readGuard();
    final hamster = _snapshot.hamsters.firstWhere(
      (value) => value.id == hamsterId,
    );
    final weights = _weights.where((w) => w.hamsterId == hamsterId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return I2HamsterDetail(
      hamster: hamster,
      litters: _snapshot.litters
          .where(
            (value) => value.sireId == hamsterId || value.damId == hamsterId,
          )
          .toList(),
      weights: weights,
    );
  }

  @override
  Future<I2EnclosureDetail> getEnclosureDetail(String enclosureId) async {
    _readGuard();
    final stays = _stays.where((s) => s.enclosureId == enclosureId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return I2EnclosureDetail(
      enclosure: _snapshot.enclosures.firstWhere(
        (value) => value.id == enclosureId,
      ),
      stays: stays,
    );
  }

  @override
  Future<List<I2CleaningRecord>> listCleaningHistory(String enclosureId) async {
    _readGuard();
    return const <I2CleaningRecord>[];
  }

  @override
  Future<I2Hamster> createHamster(I2HamsterDraft draft) async {
    _writeGuard();
    final hamster = I2Hamster(
      id: 'memory-${_sequence++}',
      internalCode: draft.internalCode,
      name: draft.name,
      sex: draft.sex,
      varietyCode: draft.varietyCode,
      lifecycleStatus: 'active',
      breedingStatus: 'candidate',
      birthDate: draft.birthDate,
      currentEnclosureId: null,
      litterId: draft.litterId,
      notes: draft.notes,
      version: 1,
    );
    _snapshot = I2Snapshot(
      hamsters: [..._snapshot.hamsters, hamster],
      litters: _snapshot.litters,
      enclosures: _snapshot.enclosures,
      lastSyncedAt: DateTime.now(),
    );
    return hamster;
  }

  @override
  Future<I2Enclosure> createEnclosure(I2EnclosureDraft draft) async {
    _writeGuard();
    final enclosure = I2Enclosure(
      id: 'memory-enclosure-${_sequence++}',
      code: draft.code,
      rackCode: draft.rackCode,
      levelCode: draft.levelCode,
      state: 'vacant',
      cleanlinessState: 'clean',
      capacity: draft.capacity,
      equipment: draft.equipment,
      lastCleanedAt: null,
      currentHamsterIds: const <String>[],
      version: 1,
    );
    _snapshot = I2Snapshot(
      hamsters: _snapshot.hamsters,
      litters: _snapshot.litters,
      enclosures: [..._snapshot.enclosures, enclosure],
      lastSyncedAt: DateTime.now(),
      recentWeights: _snapshot.recentWeights,
    );
    return enclosure;
  }

  @override
  Future<List<I2Hamster>> createHamsters(List<I2HamsterDraft> drafts) async =>
      Future.wait(drafts.map(createHamster));

  @override
  Future<I2Hamster> updateHamster(
    String hamsterId,
    int version,
    I2HamsterUpdate update,
  ) async {
    _writeGuard();
    final index = _snapshot.hamsters.indexWhere(
      (value) => value.id == hamsterId,
    );
    if (index < 0) throw const I2RepositoryException('仓鼠不存在');
    final old = _snapshot.hamsters[index];
    final next = I2Hamster(
      id: old.id,
      internalCode: update.internalCode ?? old.internalCode,
      name: update.name ?? old.name,
      sex: update.sex ?? old.sex,
      varietyCode: update.varietyCode ?? old.varietyCode,
      lifecycleStatus: update.lifecycleStatus ?? old.lifecycleStatus,
      breedingStatus: update.breedingStatus ?? old.breedingStatus,
      birthDate: update.birthDate ?? old.birthDate,
      currentEnclosureId: old.currentEnclosureId,
      litterId: old.litterId,
      notes: update.notes ?? old.notes,
      version: old.version + 1,
    );
    final hamsters = [..._snapshot.hamsters]..[index] = next;
    _snapshot = I2Snapshot(
      hamsters: hamsters,
      litters: _snapshot.litters,
      enclosures: _snapshot.enclosures,
      lastSyncedAt: DateTime.now(),
    );
    return next;
  }

  @override
  Future<I2EnclosureStay> moveHamster(
    I2MoveDraft draft, {
    int enclosureVersion = 1,
  }) async {
    _writeGuard();
    final encIndex = _snapshot.enclosures.indexWhere(
      (e) => e.id == draft.enclosureId,
    );
    if (encIndex < 0) throw const I2RepositoryException('笼盒不存在');
    final target = _snapshot.enclosures[encIndex];
    if (target.version != enclosureVersion) {
      throw const I2RepositoryException('笼盒版本冲突，请刷新后重试');
    }
    final hamIndex = _snapshot.hamsters.indexWhere(
      (h) => h.id == draft.hamsterId,
    );
    if (hamIndex < 0) throw const I2RepositoryException('仓鼠不存在');

    // Close open stays for this hamster elsewhere.
    final now = draft.startedAt;
    for (var i = 0; i < _stays.length; i++) {
      final stay = _stays[i];
      if (stay.hamsterId == draft.hamsterId && stay.endedAt == null) {
        _stays[i] = I2EnclosureStay(
          id: stay.id,
          enclosureId: stay.enclosureId,
          hamsterId: stay.hamsterId,
          purpose: stay.purpose,
          startedAt: stay.startedAt,
          endedAt: now,
          reason: draft.reason ?? '移笼关闭',
          version: stay.version + 1,
        );
      }
    }

    // Remove hamster from any previous enclosure occupant list.
    final enclosures = _snapshot.enclosures.map((e) {
      final ids = e.currentHamsterIds
          .where((id) => id != draft.hamsterId)
          .toList();
      if (ids.length == e.currentHamsterIds.length && e.id != target.id) {
        return e;
      }
      final nextIds = e.id == target.id
          ? {...ids, draft.hamsterId}.toList()
          : ids;
      final changed =
          e.id == target.id || nextIds.length != e.currentHamsterIds.length;
      return I2Enclosure(
        id: e.id,
        code: e.code,
        rackCode: e.rackCode,
        levelCode: e.levelCode,
        state: e.id == target.id
            ? enclosureStateForPurpose(
                draft.purpose,
                occupantCount: nextIds.length,
              )
            : (nextIds.isEmpty ? 'vacant' : e.state),
        cleanlinessState: e.cleanlinessState,
        capacity: e.capacity,
        equipment: e.equipment,
        lastCleanedAt: e.lastCleanedAt,
        currentHamsterIds: nextIds,
        version: changed ? e.version + 1 : e.version,
      );
    }).toList();

    // Ensure target has correct occupants/state (map above handles it).
    final stay = I2EnclosureStay(
      id: 'stay-${_sequence++}',
      enclosureId: draft.enclosureId,
      hamsterId: draft.hamsterId,
      purpose: draft.purpose,
      startedAt: now,
      endedAt: null,
      reason: draft.reason,
      version: 1,
    );
    _stays.insert(0, stay);

    final oldHamster = _snapshot.hamsters[hamIndex];
    final hamsters = [..._snapshot.hamsters];
    hamsters[hamIndex] = I2Hamster(
      id: oldHamster.id,
      internalCode: oldHamster.internalCode,
      name: oldHamster.name,
      sex: oldHamster.sex,
      varietyCode: oldHamster.varietyCode,
      lifecycleStatus: oldHamster.lifecycleStatus,
      breedingStatus: oldHamster.breedingStatus,
      birthDate: oldHamster.birthDate,
      currentEnclosureId: draft.enclosureId,
      litterId: oldHamster.litterId,
      notes: oldHamster.notes,
      version: oldHamster.version + 1,
    );

    _snapshot = I2Snapshot(
      hamsters: hamsters,
      litters: _snapshot.litters,
      enclosures: enclosures,
      lastSyncedAt: DateTime.now(),
      recentWeights: _snapshot.recentWeights,
    );
    return stay;
  }

  @override
  Future<I2EnclosureStay> closeStay(
    String stayId,
    int version, {
    DateTime? endedAt,
    String? reason,
  }) async {
    _writeGuard();
    final index = _stays.indexWhere((s) => s.id == stayId);
    if (index < 0) throw const I2RepositoryException('入住记录不存在');
    final stay = _stays[index];
    if (stay.version != version) {
      throw const I2RepositoryException('版本冲突，请刷新后重试');
    }
    final closed = I2EnclosureStay(
      id: stay.id,
      enclosureId: stay.enclosureId,
      hamsterId: stay.hamsterId,
      purpose: stay.purpose,
      startedAt: stay.startedAt,
      endedAt: endedAt ?? DateTime.now(),
      reason: reason ?? stay.reason,
      version: stay.version + 1,
    );
    _stays[index] = closed;

    // Drop occupant from enclosure if this was the active stay.
    final encIndex = _snapshot.enclosures.indexWhere(
      (e) => e.id == stay.enclosureId,
    );
    if (encIndex >= 0) {
      final e = _snapshot.enclosures[encIndex];
      final ids = e.currentHamsterIds
          .where((id) => id != stay.hamsterId)
          .toList();
      final enclosures = [..._snapshot.enclosures];
      enclosures[encIndex] = I2Enclosure(
        id: e.id,
        code: e.code,
        rackCode: e.rackCode,
        levelCode: e.levelCode,
        state: ids.isEmpty ? 'vacant' : e.state,
        cleanlinessState: e.cleanlinessState,
        capacity: e.capacity,
        equipment: e.equipment,
        lastCleanedAt: e.lastCleanedAt,
        currentHamsterIds: ids,
        version: e.version + 1,
      );
      final hamIndex = _snapshot.hamsters.indexWhere(
        (h) => h.id == stay.hamsterId,
      );
      final hamsters = [..._snapshot.hamsters];
      if (hamIndex >= 0) {
        final h = hamsters[hamIndex];
        hamsters[hamIndex] = I2Hamster(
          id: h.id,
          internalCode: h.internalCode,
          name: h.name,
          sex: h.sex,
          varietyCode: h.varietyCode,
          lifecycleStatus: h.lifecycleStatus,
          breedingStatus: h.breedingStatus,
          birthDate: h.birthDate,
          currentEnclosureId: null,
          litterId: h.litterId,
          notes: h.notes,
          version: h.version + 1,
        );
      }
      _snapshot = I2Snapshot(
        hamsters: hamsters,
        litters: _snapshot.litters,
        enclosures: enclosures,
        lastSyncedAt: DateTime.now(),
        recentWeights: _snapshot.recentWeights,
      );
    }
    return closed;
  }

  @override
  Future<I2Enclosure> cleanEnclosure(
    String enclosureId,
    int version, {
    DateTime? cleanedAt,
  }) async => throw const I2RepositoryException('测试 repository 未实现清洁写入');

  @override
  Future<I2CleaningRecord> recordCleaning(I2CleaningDraft draft) async =>
      throw const I2RepositoryException('测试 repository 未实现清洁历史写入');

  @override
  Future<I2WeightRecord> createWeight(I2WeightDraft draft) async {
    _writeGuard();
    if (draft.weightG <= 0) {
      throw const I2RepositoryException('体重必须大于 0 克');
    }
    final hamsterId = draft.hamsterId;
    I2WeightRecord? previous;
    if (hamsterId != null) {
      final history = _weights.where((w) => w.hamsterId == hamsterId).toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      if (history.isNotEmpty) previous = history.first;
    }
    final record = buildWeightRecord(
      id: 'weight-${_sequence++}',
      draft: draft,
      previous: previous,
    );
    _weights.insert(0, record);
    return record;
  }

  @override
  Future<List<I2WeightRecord>> listWeights(String hamsterId) async {
    _readGuard();
    final values = _weights.where((w) => w.hamsterId == hamsterId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return values;
  }

  @override
  Future<I2ImportJob> uploadCsv(I2CsvUpload upload) async =>
      throw const I2RepositoryException('测试 repository 未实现 CSV 上传');

  @override
  Future<I2ImportJob> setImportMapping(
    String jobId,
    int version,
    List<I2ImportMapping> mappings,
  ) async => throw const I2RepositoryException('测试 repository 未实现 CSV 映射');

  @override
  Future<I2ImportJob> preflightImport(String jobId, int version) async =>
      throw const I2RepositoryException('测试 repository 未实现 CSV 预检');

  @override
  Future<I2ImportJob> commitImport(
    String jobId,
    int version, {
    Set<I2ImportApprovedUpdate> approvedUpdates =
        const <I2ImportApprovedUpdate>{},
  }) async => throw const I2RepositoryException('测试 repository 未实现 CSV 提交');

  @override
  Future<List<I2ImportRowResult>> listImportRows(String jobId) async => _rows;
}
