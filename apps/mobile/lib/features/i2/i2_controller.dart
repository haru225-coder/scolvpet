import 'package:flutter/foundation.dart';

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
  I2ImportStage importStage = I2ImportStage.idle;
  I2ImportJob? importJob;
  List<I2ImportRowResult> importRows = const <I2ImportRowResult>[];
  List<I2Draft> drafts = const <I2Draft>[];
  bool offline = false;
  String? lastSyncLabel;

  bool get canWrite => !offline;

  Future<void> restore() async {
    snapshotState = const I2AsyncState.loading();
    drafts = await localStore.readDrafts();
    notifyListeners();
    try {
      final snapshot = await repository.loadSnapshot();
      await localStore.saveSnapshot(snapshot);
      offline = false;
      lastSyncLabel = snapshot.lastSyncedAt?.toLocal().toString();
      snapshotState =
          snapshot.hamsters.isEmpty &&
              snapshot.litters.isEmpty &&
              snapshot.enclosures.isEmpty
          ? const I2AsyncState.empty(message: '还没有仓鼠、窝次或笼盒记录')
          : I2AsyncState.data(snapshot);
    } catch (error) {
      final cached = await localStore.readSnapshot();
      if (cached != null) {
        offline = true;
        lastSyncLabel = cached.lastSyncedAt?.toLocal().toString();
        snapshotState =
            cached.hamsters.isEmpty &&
                cached.litters.isEmpty &&
                cached.enclosures.isEmpty
            ? const I2AsyncState.empty(message: '暂无缓存数据')
            : I2AsyncState.data(cached);
      } else {
        snapshotState = I2AsyncState.error(_message(error));
      }
    }
    notifyListeners();
  }

  Future<void> retry() => restore();

  Future<void> loadHamsterDetail(String hamsterId) async {
    hamsterDetailState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final value = await repository.getHamsterDetail(hamsterId);
      hamsterDetailState = I2AsyncState.data(value);
    } catch (error) {
      hamsterDetailState = _errorState(error);
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
      enclosureDetailState = _errorState(error);
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
      cleaningState = _errorState(error);
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
      weightState = _errorState(error);
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

  Future<void> createWeightsBatch(List<I2WeightDraft> drafts) async {
    if (drafts.isEmpty) return;
    if (!await _ensureWritable()) return;
    await _runAction(() async {
      for (final draft in drafts) {
        await repository.createWeight(draft);
      }
      await restore();
    });
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
    if (draft != null) await saveDraft(draft);
    actionState = const I2AsyncState.error('离线只读，草稿已保存；联网后由用户明确提交');
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
}

Uint8List csvBytes(String value) => Uint8List.fromList(value.codeUnits);
