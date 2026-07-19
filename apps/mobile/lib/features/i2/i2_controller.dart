import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../data/i2_repository.dart';
import 'i2_models.dart';

class I2Controller extends ChangeNotifier {
  I2Controller({required this.repository, I2LocalStore? localStore})
    : localStore = localStore ?? MemoryI2LocalStore();

  final I2Repository repository;
  final I2LocalStore localStore;

  I2AsyncState<I2Snapshot> snapshotState = const I2AsyncState.idle();
  I2AsyncState<I2HamsterDetail> hamsterDetailState = const I2AsyncState.idle();
  I2AsyncState<I2EnclosureDetail> enclosureDetailState =
      const I2AsyncState.idle();
  I2AsyncState<List<I2CleaningRecord>> cleaningState =
      const I2AsyncState.idle();
  I2AsyncState<List<I2WeightRecord>> weightState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  I2AsyncState<void> avatarState = const I2AsyncState.idle();
  I2WeightBatchResult? weightBatchResult;
  I2ImportStage importStage = I2ImportStage.idle;
  I2ImportJob? importJob;
  List<I2ImportRowResult> importRows = const <I2ImportRowResult>[];
  List<I2Draft> drafts = const <I2Draft>[];
  bool offline = false;
  bool _authorizedToWrite = true;
  String? lastSyncLabel;
  int _restoreGeneration = 0;
  I2Hamster? _pendingAvatarHamster;
  I2AvatarUpload? _pendingAvatarUpload;

  bool get canWrite => !offline && _authorizedToWrite;
  bool get hasWritePermission => _authorizedToWrite;
  bool get canRetryAvatarUpload =>
      canWrite &&
      _pendingAvatarHamster != null &&
      _pendingAvatarUpload != null &&
      (avatarState.status == I2AsyncStatus.error ||
          avatarState.status == I2AsyncStatus.conflict);

  void setWritePermission(bool allowed) {
    if (_authorizedToWrite == allowed) return;
    _authorizedToWrite = allowed;
    notifyListeners();
  }

  Future<void> restore() async {
    final generation = ++_restoreGeneration;
    snapshotState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final restoredDrafts = await localStore.readDrafts();
      if (!_isCurrentRestore(generation)) return;
      drafts = restoredDrafts;
      notifyListeners();
    } on Object {
      if (!_isCurrentRestore(generation)) return;
      drafts = const <I2Draft>[];
    }
    try {
      final loadedSnapshot = await repository.loadSnapshot();
      if (!_isCurrentRestore(generation)) return;
      I2Snapshot? previousSnapshot;
      try {
        previousSnapshot = await localStore.readSnapshot();
      } on Object {
        previousSnapshot = null;
      }
      final snapshot = _mergeAvatarCache(loadedSnapshot, previousSnapshot);
      try {
        await localStore.saveSnapshot(snapshot);
      } on Object {
        // A cache write failure must not downgrade a successful online load.
      }
      if (!_isCurrentRestore(generation)) return;
      offline = false;
      lastSyncLabel = _syncLabel(snapshot.lastSyncedAt);
      snapshotState =
          snapshot.hamsters.isEmpty &&
              snapshot.litters.isEmpty &&
              snapshot.enclosures.isEmpty
          ? const I2AsyncState.empty(message: '还没有仓鼠、窝次或笼盒记录')
          : I2AsyncState.data(snapshot);
    } catch (error) {
      if (!_isCurrentRestore(generation)) return;
      I2Snapshot? cached;
      try {
        cached = await localStore.readSnapshot();
      } on Object {
        cached = null;
      }
      if (!_isCurrentRestore(generation)) return;
      if (cached != null && _isOfflineError(error)) {
        offline = true;
        lastSyncLabel = _syncLabel(cached.lastSyncedAt);
        snapshotState =
            cached.hamsters.isEmpty &&
                cached.litters.isEmpty &&
                cached.enclosures.isEmpty
            ? const I2AsyncState.empty(message: '暂无缓存数据')
            : I2AsyncState.data(cached);
      } else {
        // A response/serialization/business error is not proof that the
        // device is offline. Keep the cached data available, but surface an
        // error state with retry instead of incorrectly disabling all writes.
        offline = false;
        snapshotState = I2AsyncState.error(_message(error));
      }
    }
    if (_isCurrentRestore(generation)) notifyListeners();
  }

  Future<void> retry() => restore();

  Future<void> loadHamsterDetail(String hamsterId) async {
    hamsterDetailState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final value = await repository.getHamsterDetail(hamsterId);
      hamsterDetailState = I2AsyncState.data(value);
    } catch (error) {
      I2Hamster? cachedHamster;
      for (final hamster in
          snapshotState.data?.hamsters ?? const <I2Hamster>[]) {
        if (hamster.id == hamsterId) {
          cachedHamster = hamster;
          break;
        }
      }
      if (offline && cachedHamster != null) {
        hamsterDetailState = I2AsyncState.data(
          I2HamsterDetail(
            hamster: cachedHamster,
            litters: (snapshotState.data?.litters ?? const <I2Litter>[])
                .where(
                  (litter) =>
                      litter.sireId == hamsterId || litter.damId == hamsterId,
                )
                .toList(),
            weights: (snapshotState.data?.recentWeights ??
                    const <I2WeightRecord>[])
                .where((weight) => weight.hamsterId == hamsterId)
                .toList()
              ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)),
          ),
        );
      } else {
        hamsterDetailState = _errorState(error);
      }
    }
    notifyListeners();
  }

  Future<void> loadEnclosureDetail(String enclosureId) async {
    enclosureDetailState = const I2AsyncState.loading();
    notifyListeners();
    try {
      enclosureDetailState = I2AsyncState.data(
        await repository.getEnclosureDetail(enclosureId),
      );
    } catch (error) {
      I2Enclosure? cachedEnclosure;
      for (final enclosure in
          snapshotState.data?.enclosures ?? const <I2Enclosure>[]) {
        if (enclosure.id == enclosureId) {
          cachedEnclosure = enclosure;
          break;
        }
      }
      enclosureDetailState = offline && cachedEnclosure != null
          ? I2AsyncState.data(
              I2EnclosureDetail(
                enclosure: cachedEnclosure,
                stays: const <I2EnclosureStay>[],
              ),
            )
          : _errorState(error);
    }
    notifyListeners();
    await loadCleaningHistory(enclosureId);
  }

  Future<void> loadCleaningHistory(String enclosureId) async {
    cleaningState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final values = await repository.listCleaningHistory(enclosureId);
      cleaningState = values.isEmpty
          ? const I2AsyncState.empty(message: '暂无清洁记录')
          : I2AsyncState.data(values);
    } catch (error) {
      cleaningState = offline
          ? const I2AsyncState.empty(
              message: '离线状态下暂无可用的清洁历史',
            )
          : _errorState(error);
    }
    notifyListeners();
  }

  Future<void> loadWeights(String hamsterId) async {
    weightState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final values = await repository.listWeights(hamsterId);
      weightState = values.isEmpty
          ? const I2AsyncState.empty(message: '还没有体重记录')
          : I2AsyncState.data(values);
    } catch (error) {
      final cached = (snapshotState.data?.recentWeights ??
              const <I2WeightRecord>[])
          .where((weight) => weight.hamsterId == hamsterId)
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      if (offline) {
        weightState = cached.isEmpty
            ? const I2AsyncState.empty(message: '离线状态下暂无缓存体重')
            : I2AsyncState.data(cached);
      } else {
        weightState = _errorState(error);
      }
    }
    notifyListeners();
  }

  Future<void> createHamster(I2HamsterDraft draft) async {
    if (!await _ensureWritable(
      draft: I2Draft(
        id: 'hamster-${DateTime.now().microsecondsSinceEpoch}',
        kind: 'hamster',
        payload: draft.toJson(),
      ),
    )) {
      return;
    }
    await _runAction(() async {
      await repository.createHamster(draft);
      await restore();
    });
  }

  Future<void> createEnclosure(I2EnclosureDraft draft) async {
    if (!await _ensureWritable(
      draft: I2Draft(
        id: 'enclosure-${DateTime.now().microsecondsSinceEpoch}',
        kind: 'enclosure',
        payload: {
          'code': draft.code,
          'rack_code': draft.rackCode,
          'level_code': draft.levelCode,
          'capacity': draft.capacity,
          'equipment': draft.equipment,
        },
      ),
    )) {
      return;
    }
    await _runAction(() async {
      await repository.createEnclosure(draft);
      await restore();
    });
  }

  Future<void> createHamsters(List<I2HamsterDraft> values) async {
    if (values.isEmpty) return;
    if (!await _ensureWritable(
      draft: I2Draft(
        id: 'hamsters-${DateTime.now().microsecondsSinceEpoch}',
        kind: 'hamsters',
        payload: {'items': values.map((value) => value.toJson()).toList()},
      ),
    )) {
      return;
    }
    await _runAction(() async {
      await repository.createHamsters(values);
      await restore();
    });
  }

  Future<void> updateHamster(
    String hamsterId,
    int version,
    I2HamsterUpdate update,
  ) async {
    if (!await _ensureWritable()) return;
    await _runAction(() async {
      await repository.updateHamster(hamsterId, version, update);
      await restore();
    });
  }

  Future<void> moveHamster(
    I2MoveDraft draft, {
    int enclosureVersion = 1,
  }) async {
    if (!await _ensureWritable(
      draft: I2Draft(
        id: 'move-${DateTime.now().microsecondsSinceEpoch}',
        kind: 'move',
        payload: {
          'enclosure_id': draft.enclosureId,
          'enclosure_version': enclosureVersion,
          'hamster_id': draft.hamsterId,
          'purpose': draft.purpose,
          'started_at': draft.startedAt.toIso8601String(),
          'reason': draft.reason,
        },
      ),
    )) {
      return;
    }
    await _runAction(() async {
      await repository.moveHamster(draft, enclosureVersion: enclosureVersion);
      await restore();
    });
  }

  Future<void> closeStay(
    String stayId,
    int version, {
    DateTime? endedAt,
    String? reason,
  }) async {
    if (!await _ensureWritable()) return;
    await _runAction(() async {
      await repository.closeStay(
        stayId,
        version,
        endedAt: endedAt,
        reason: reason,
      );
      await restore();
    });
  }

  Future<void> cleanEnclosure(
    String enclosureId,
    int version, {
    DateTime? cleanedAt,
  }) async {
    if (!await _ensureWritable()) return;
    await _runAction(() async {
      await repository.cleanEnclosure(
        enclosureId,
        version,
        cleanedAt: cleanedAt,
      );
      await restore();
    });
  }

  Future<void> recordCleaning(I2CleaningDraft draft) async {
    if (!await _ensureWritable(
      draft: I2Draft(
        id: 'cleaning-${DateTime.now().microsecondsSinceEpoch}',
        kind: 'cleaning',
        payload: {
          'enclosure_id': draft.enclosureId,
          'enclosure_version': draft.enclosureVersion,
          'type': draft.type,
          'completed_at': draft.completedAt.toIso8601String(),
          'reason': draft.reason,
          'health_record_id': draft.healthRecordId,
          'supplies': draft.supplies,
          'corrects_cleaning_record_id': draft.correctsCleaningRecordId,
          'correction_reason': draft.correctionReason,
        },
      ),
    )) {
      return;
    }
    await _runAction(() async {
      await repository.recordCleaning(draft);
      await loadEnclosureDetail(draft.enclosureId);
    });
  }

  Future<void> createWeight(I2WeightDraft draft) async {
    if (!await _ensureWritable(
      draft: I2Draft(
        id: 'weight-${DateTime.now().microsecondsSinceEpoch}',
        kind: 'weight',
        payload: {
          'hamster_id': draft.hamsterId,
          'weight_g': draft.weightG,
          'recorded_at': draft.recordedAt.toIso8601String(),
          'notes': draft.notes,
        },
      ),
    )) {
      return;
    }
    await _runAction(() async {
      await repository.createWeight(draft);
      if (draft.hamsterId != null) {
        await loadWeights(draft.hamsterId!);
      }
      await restore();
    });
  }

  Future<bool> uploadAvatar(I2Hamster hamster, I2AvatarUpload upload) async {
    if (avatarState.status == I2AsyncStatus.loading) return false;
    final avatarRepository = repository;
    if (avatarRepository is! I2AvatarRepository) {
      avatarState = const I2AsyncState.error('当前数据源未启用头像上传');
      notifyListeners();
      return false;
    }
    if (!canWrite) {
      avatarState = I2AsyncState.error(
        offline ? '离线状态暂不能上传头像' : '当前角色没有修改头像的权限',
        retryable: false,
      );
      notifyListeners();
      return false;
    }
    _pendingAvatarHamster = hamster;
    _pendingAvatarUpload = upload;
    avatarState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final updated = await (avatarRepository as I2AvatarRepository)
          .uploadAvatar(hamster, upload);
      try {
        await _saveAvatarCache(updated, upload.bytes);
      } on Object {
        // A local cache failure must not turn a completed upload into a retry.
      }
      _pendingAvatarHamster = null;
      _pendingAvatarUpload = null;
      avatarState = const I2AsyncState.data(null);
      await restore();
      await loadHamsterDetail(hamster.id);
      return true;
    } catch (error) {
      avatarState = _errorState(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> retryAvatarUpload() async {
    final hamster = _pendingAvatarHamster;
    final upload = _pendingAvatarUpload;
    if (hamster == null || upload == null) return false;
    return uploadAvatar(hamster, upload);
  }

  Future<bool> removeAvatar(I2Hamster hamster) async {
    final avatarRepository = repository;
    if (avatarState.status == I2AsyncStatus.loading) return false;
    if (avatarRepository is! I2AvatarRepository) {
      avatarState = const I2AsyncState.error(
        '当前数据源未启用头像管理',
        retryable: false,
      );
      notifyListeners();
      return false;
    }
    if (!canWrite) {
      avatarState = I2AsyncState.error(
        offline ? '离线状态暂不能移除头像' : '当前角色没有修改头像的权限',
        retryable: false,
      );
      notifyListeners();
      return false;
    }
    avatarState = const I2AsyncState.loading();
    notifyListeners();
    try {
      await (avatarRepository as I2AvatarRepository).removeAvatar(hamster);
      avatarState = const I2AsyncState.data(null);
      await restore();
      await loadHamsterDetail(hamster.id);
      return true;
    } catch (error) {
      avatarState = _errorState(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveAvatarCache(I2Hamster updated, Uint8List bytes) async {
    final snapshot = snapshotState.data;
    if (snapshot == null) return;
    final cachedHamster = I2Hamster.fromJson(<String, dynamic>{
      ...updated.toJson(),
      'avatar_bytes': bytes,
    });
    final cached = I2Snapshot(
      hamsters: [
        for (final hamster in snapshot.hamsters)
          hamster.id == updated.id ? cachedHamster : hamster,
      ],
      litters: snapshot.litters,
      enclosures: snapshot.enclosures,
      lastSyncedAt: snapshot.lastSyncedAt,
      recentWeights: snapshot.recentWeights,
    );
    await localStore.saveSnapshot(cached);
  }

  I2Snapshot _mergeAvatarCache(I2Snapshot current, I2Snapshot? previous) {
    if (previous == null) return current;
    final cachedByHamster = <String, I2Hamster>{
      for (final hamster in previous.hamsters)
        if (hamster.avatarBytes != null) hamster.id: hamster,
    };
    return I2Snapshot(
      hamsters: [
        for (final hamster in current.hamsters)
          if (cachedByHamster[hamster.id] case final cached?)
            I2Hamster.fromJson(<String, dynamic>{
              ...hamster.toJson(),
              if (hamster.coverMediaId == cached.coverMediaId)
                'avatar_bytes': cached.avatarBytes,
            })
          else
            hamster,
      ],
      litters: current.litters,
      enclosures: current.enclosures,
      lastSyncedAt: current.lastSyncedAt,
      recentWeights: current.recentWeights,
    );
  }

  Future<I2WeightBatchResult?> createWeightsBatch(
    List<I2WeightDraft> drafts,
  ) async {
    if (drafts.isEmpty || actionState.status == I2AsyncStatus.loading) {
      return null;
    }
    weightBatchResult = null;
    if (!await _ensureWritable()) return null;
    actionState = const I2AsyncState.loading();
    notifyListeners();

    final successfulHamsterIds = <String>[];
    final failures = <I2WeightBatchFailure>[];
    for (final draft in drafts) {
      try {
        await repository.createWeight(draft);
        final hamsterId = draft.hamsterId;
        if (hamsterId != null && hamsterId.isNotEmpty) {
          successfulHamsterIds.add(hamsterId);
        }
      } catch (error) {
        failures.add(
          I2WeightBatchFailure(
            hamsterId: draft.hamsterId,
            message: _message(error),
          ),
        );
      }
    }

    if (successfulHamsterIds.isNotEmpty) {
      await restore();
    }
    final result = I2WeightBatchResult(
      totalCount: drafts.length,
      successfulHamsterIds: successfulHamsterIds,
      failures: failures,
    );
    weightBatchResult = result;
    actionState = result.isCompleteFailure
        ? I2AsyncState.error(
            '${result.failureCount} 条体重均未保存，请检查后重试',
            retryable: false,
          )
        : const I2AsyncState.data(null);
    notifyListeners();
    return result;
  }

  Future<void> uploadCsv(I2CsvUpload upload) async {
    if (!await _ensureWritable()) return;
    importStage = I2ImportStage.uploading;
    actionState = const I2AsyncState.loading();
    notifyListeners();
    try {
      importJob = await repository.uploadCsv(upload);
      importStage = I2ImportStage.mapping;
      actionState = const I2AsyncState.data(null);
    } catch (error) {
      importStage = I2ImportStage.error;
      actionState = _errorState(error);
    }
    notifyListeners();
  }

  Future<void> setImportMapping(List<I2ImportMapping> mappings) async {
    final job = importJob;
    if (job == null || !await _ensureWritable()) return;
    importStage = I2ImportStage.mapping;
    await _runAction(() async {
      importJob = await repository.setImportMapping(
        job.id,
        job.version,
        mappings,
      );
      importStage = I2ImportStage.preflight;
    });
  }

  Future<void> preflightImport() async {
    final job = importJob;
    if (job == null || !await _ensureWritable()) return;
    importStage = I2ImportStage.preflight;
    await _runAction(() async {
      importJob = await repository.preflightImport(job.id, job.version);
      importStage = I2ImportStage.conflictPreview;
    });
  }

  Future<void> commitImport({
    Set<I2ImportApprovedUpdate> approvedUpdates =
        const <I2ImportApprovedUpdate>{},
  }) async {
    final job = importJob;
    if (job == null || !await _ensureWritable()) return;
    if (job.hasBlockingIssues) {
      actionState = const I2AsyncState.conflict('存在阻塞问题，修复并重新预检后才能提交');
      importStage = I2ImportStage.conflictPreview;
      notifyListeners();
      return;
    }
    importStage = I2ImportStage.committing;
    await _runAction(() async {
      importJob = await repository.commitImport(
        job.id,
        job.preflightVersion ?? job.version,
        approvedUpdates: approvedUpdates,
      );
      importRows = await repository.listImportRows(job.id);
      importStage = I2ImportStage.report;
    });
  }

  Future<void> retryImportRows() async {
    final job = importJob;
    if (job == null) return;
    await _runAction(() async {
      importRows = await repository.listImportRows(job.id);
      importStage = I2ImportStage.report;
    });
  }

  Future<void> saveDraft(I2Draft draft) async {
    await localStore.saveDraft(draft);
    drafts = await localStore.readDrafts();
    notifyListeners();
  }

  Future<void> deleteDraft(String id) async {
    await localStore.deleteDraft(id);
    drafts = await localStore.readDrafts();
    notifyListeners();
  }

  Future<bool> _ensureWritable({I2Draft? draft}) async {
    if (canWrite) return true;
    if (!_authorizedToWrite) {
      actionState = const I2AsyncState.error(
        '当前角色没有编辑权限',
        retryable: false,
      );
      notifyListeners();
      return false;
    }
    if (draft != null) await saveDraft(draft);
    actionState = I2AsyncState.error(
      draft == null
          ? '离线只读，联网后再提交'
          : '离线只读，草稿已保存；联网后由用户明确提交',
      retryable: false,
    );
    notifyListeners();
    return false;
  }

  Future<void> _runAction(Future<void> Function() action) async {
    actionState = const I2AsyncState.loading();
    notifyListeners();
    try {
      await action();
      if (actionState.status == I2AsyncStatus.loading) {
        actionState = const I2AsyncState.data(null);
      }
    } catch (error) {
      actionState = _errorState(error);
      if (error is I2RepositoryException && error.conflict) {
        actionState = I2AsyncState.conflict(error.message);
      }
    }
    notifyListeners();
  }

  I2AsyncState<T> _errorState<T>(Object error) {
    if (error is I2RepositoryException && error.conflict) {
      return I2AsyncState.conflict(error.message);
    }
    return I2AsyncState.error(_message(error));
  }

  String _message(Object error) =>
      error is I2RepositoryException ? error.message : '请求未完成，请稍后重试';

  static bool _isOfflineError(Object error) =>
      (error is DioException &&
          switch (error.type) {
            DioExceptionType.connectionError ||
            DioExceptionType.connectionTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.receiveTimeout => true,
            _ => false,
          }) ||
      (error is I2RepositoryException && error.message == '请求未完成，请稍后重试');

  bool _isCurrentRestore(int generation) => generation == _restoreGeneration;

  static String? _syncLabel(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    final now = DateTime.now();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return '今天 $time';
    }
    return '${local.month}月${local.day}日 $time';
  }
}

Uint8List csvBytes(String value) => Uint8List.fromList(value.codeUnits);
