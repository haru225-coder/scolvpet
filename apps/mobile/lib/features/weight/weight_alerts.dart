import '../i2/i2_models.dart';

/// Client-side weight anomaly rules (T-P0-04).
///
/// Defaults are suitable for Syrian hamsters in grams; species rules can
/// override absolute floor later.
class WeightAlertRules {
  const WeightAlertRules({
    this.minWeightG = 20,
    this.dropThresholdG = 3,
    this.dropRatio = 0.08,
  });

  /// Absolute floor in grams (highlight if latest weight is below).
  final num minWeightG;

  /// Absolute drop from previous recording in grams.
  final num dropThresholdG;

  /// Relative drop ratio from previous recording (0–1).
  final num dropRatio;

  static const syrianDefault = WeightAlertRules();
}

class WeightAlert {
  const WeightAlert({
    required this.hamsterId,
    required this.record,
    required this.flags,
  });

  final String hamsterId;
  final I2WeightRecord record;
  final List<String> flags;

  bool get isAbnormal => flags.isNotEmpty;

  String get summary {
    if (flags.contains('drop_from_previous')) {
      final change = record.changeFromPreviousG;
      return change == null
          ? '掉重'
          : '掉重 ${change.toStringAsFixed(1)} g';
    }
    if (flags.contains('below_min_weight')) {
      return '低于阈值 ${record.weightG} g';
    }
    if (flags.contains('below_birth_weight')) {
      return '低于出生重';
    }
    if (flags.contains('outside_reference')) {
      return '偏离参考区间';
    }
    return flags.join(',');
  }
}

/// Evaluate alert flags for a single weight record.
List<String> evaluateWeightFlags(
  I2WeightRecord record, {
  WeightAlertRules rules = WeightAlertRules.syrianDefault,
}) {
  final flags = <String>[...record.alertFlags];
  void add(String flag) {
    if (!flags.contains(flag)) flags.add(flag);
  }

  if (record.weightG > 0 && record.weightG < rules.minWeightG) {
    add('below_min_weight');
  }

  final previous = record.previousWeightG;
  final change = record.changeFromPreviousG;
  if (previous != null && previous > 0) {
    final delta = change ?? (record.weightG - previous);
    if (delta <= -rules.dropThresholdG) {
      add('drop_from_previous');
    } else if (delta < 0 && (-delta / previous) >= rules.dropRatio) {
      add('drop_from_previous');
    }
  }

  final birth = record.birthWeightG;
  if (birth != null && record.weightG < birth) {
    add('below_birth_weight');
  }

  // Server-provided flags already included via record.alertFlags.
  for (final flag in record.alertFlags) {
    if (flag == 'outside_reference') add(flag);
  }

  return flags;
}

/// Build alerts from the latest record per hamster.
List<WeightAlert> buildWeightAlerts(
  Iterable<I2WeightRecord> records, {
  WeightAlertRules rules = WeightAlertRules.syrianDefault,
}) {
  final latest = <String, I2WeightRecord>{};
  for (final record in records) {
    final hamsterId = record.hamsterId;
    if (hamsterId == null || hamsterId.isEmpty) continue;
    final existing = latest[hamsterId];
    if (existing == null || record.recordedAt.isAfter(existing.recordedAt)) {
      latest[hamsterId] = record;
    }
  }

  final alerts = <WeightAlert>[];
  for (final entry in latest.entries) {
    final flags = evaluateWeightFlags(entry.value, rules: rules);
    if (flags.isEmpty) continue;
    alerts.add(
      WeightAlert(hamsterId: entry.key, record: entry.value, flags: flags),
    );
  }
  alerts.sort((a, b) => b.record.recordedAt.compareTo(a.record.recordedAt));
  return alerts;
}

/// Compute previous/change/alerts when creating a local weight record.
I2WeightRecord buildWeightRecord({
  required String id,
  required I2WeightDraft draft,
  I2WeightRecord? previous,
  WeightAlertRules rules = WeightAlertRules.syrianDefault,
}) {
  final previousG = previous?.weightG;
  final change = previousG == null
      ? null
      : draft.weightG - previousG;
  final provisional = I2WeightRecord(
    id: id,
    hamsterId: draft.hamsterId,
    litterId: draft.litterId,
    measurementKind: draft.measurementKind,
    subjectCount: draft.subjectCount,
    weightG: draft.weightG,
    recordedAt: draft.recordedAt,
    source: 'manual',
    previousWeightG: previousG,
    changeFromPreviousG: change,
    birthWeightG: previous?.birthWeightG ?? previousG,
    alertFlags: const [],
    notes: draft.notes,
  );
  final flags = evaluateWeightFlags(provisional, rules: rules);
  return I2WeightRecord(
    id: provisional.id,
    hamsterId: provisional.hamsterId,
    litterId: provisional.litterId,
    measurementKind: provisional.measurementKind,
    subjectCount: provisional.subjectCount,
    weightG: provisional.weightG,
    recordedAt: provisional.recordedAt,
    source: provisional.source,
    previousWeightG: provisional.previousWeightG,
    changeFromPreviousG: provisional.changeFromPreviousG,
    birthWeightG: provisional.birthWeightG,
    alertFlags: flags,
    notes: provisional.notes,
  );
}
