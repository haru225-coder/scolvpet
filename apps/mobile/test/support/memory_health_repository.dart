// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/health/health_models.dart';
import 'package:scolvpet_mobile/features/health/health_repository.dart';

// Duplicated from lib validate (library-private); keep test double self-contained.
void _validateHealthDraft(HealthRecordDraft draft) {
  if ((draft.hamsterId == null || draft.hamsterId!.isEmpty) &&
      (draft.litterId == null || draft.litterId!.isEmpty)) {
    throw const HealthRepositoryException('必须关联仓鼠或窝次');
  }
  if (healthTypeRequiresSeverity(draft.type) &&
      (draft.severity == null || draft.severity!.trim().isEmpty)) {
    throw const HealthRepositoryException('异常记录必须选择严重度');
  }
  if (healthTypeRequiresMedicationPlan(draft.type)) {
    final plan = (draft.medication['plan'] ?? draft.medication['name'])
        ?.toString()
        .trim();
    if (plan == null || plan.isEmpty) {
      throw const HealthRepositoryException('用药记录必须填写用药方案');
    }
  }
}

class MemoryHealthRepository implements HealthRepository {
  MemoryHealthRepository({List<HealthRecordItem>? seed})
    : _records = [...?seed];

  final List<HealthRecordItem> _records;
  int _seq = 0;

  @override
  Future<List<HealthRecordItem>> listRecords({
    String? hamsterId,
    String? litterId,
  }) async {
    var values = List<HealthRecordItem>.from(_records);
    if (hamsterId != null) {
      values = values.where((r) => r.hamsterId == hamsterId).toList();
    }
    if (litterId != null) {
      values = values.where((r) => r.litterId == litterId).toList();
    }
    values.sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return values;
  }

  @override
  Future<HealthRecordItem> createRecord(HealthRecordDraft draft) async {
    _validateHealthDraft(draft);
    final record = HealthRecordItem(
      id: 'health-${_seq++}',
      hamsterId: draft.hamsterId,
      litterId: draft.litterId,
      type: draft.type,
      observedAt: draft.observedAt.toUtc(),
      severity: draft.severity,
      notes: draft.notes,
      followUpAt: draft.followUpAt?.toUtc(),
      structuredChecks: draft.structuredChecks,
      medication: draft.medication,
      version: 1,
    );
    _records.insert(0, record);
    return record;
  }
}
