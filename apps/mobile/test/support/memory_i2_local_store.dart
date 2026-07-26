import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';

/// Test-only in-memory I2 local store.
class MemoryI2LocalStore implements I2LocalStore {
  I2Snapshot? _snapshot;
  final Map<String, I2Draft> _drafts = <String, I2Draft>{};

  @override
  Future<I2Snapshot?> readSnapshot() async => _snapshot;

  @override
  Future<void> saveSnapshot(I2Snapshot snapshot) async => _snapshot = snapshot;

  @override
  Future<List<I2Draft>> readDrafts() async => _drafts.values.toList();

  @override
  Future<void> saveDraft(I2Draft draft) async => _drafts[draft.id] = draft;

  @override
  Future<void> deleteDraft(String id) async => _drafts.remove(id);
}
