// Domain models for the breeding plan wizard (T-P0-02).

class BreedingPlan {
  const BreedingPlan({
    required this.id,
    required this.sireId,
    required this.damId,
    required this.ruleVersionId,
    required this.state,
    required this.version,
    this.name,
    this.plannedPairingAt,
    this.matingBaselineAt,
    this.activePairingAttemptId,
    this.litterId,
    this.expectedBirthStart,
    this.expectedBirthEnd,
    this.actualBirthAt,
    this.notes,
  });

  final String id;
  final String sireId;
  final String damId;
  final String ruleVersionId;
  final String state;
  final int version;
  final String? name;
  final DateTime? plannedPairingAt;
  /// 进入孕期时的权威交配基准日（Backend `mating_baseline_at`）。
  final DateTime? matingBaselineAt;
  final String? activePairingAttemptId;
  final String? litterId;
  final DateTime? expectedBirthStart;
  final DateTime? expectedBirthEnd;
  final DateTime? actualBirthAt;
  final String? notes;

  String get displayName {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final date = plannedPairingAt;
    if (date != null) return '${date.month}月${date.day}日的配对计划';
    return '新的配对计划';
  }

  BreedingPlan copyWith({
    String? state,
    int? version,
    String? name,
    DateTime? plannedPairingAt,
    DateTime? matingBaselineAt,
    String? activePairingAttemptId,
    String? litterId,
    DateTime? expectedBirthStart,
    DateTime? expectedBirthEnd,
    DateTime? actualBirthAt,
    String? notes,
  }) => BreedingPlan(
    id: id,
    sireId: sireId,
    damId: damId,
    ruleVersionId: ruleVersionId,
    state: state ?? this.state,
    version: version ?? this.version,
    name: name ?? this.name,
    plannedPairingAt: plannedPairingAt ?? this.plannedPairingAt,
    matingBaselineAt: matingBaselineAt ?? this.matingBaselineAt,
    activePairingAttemptId:
        activePairingAttemptId ?? this.activePairingAttemptId,
    litterId: litterId ?? this.litterId,
    expectedBirthStart: expectedBirthStart ?? this.expectedBirthStart,
    expectedBirthEnd: expectedBirthEnd ?? this.expectedBirthEnd,
    actualBirthAt: actualBirthAt ?? this.actualBirthAt,
    notes: notes ?? this.notes,
  );

  factory BreedingPlan.fromJson(Map<String, dynamic> json) => BreedingPlan(
    id: json['id'] as String? ?? '',
    sireId: json['sire_id'] as String? ?? '',
    damId: json['dam_id'] as String? ?? '',
    ruleVersionId: json['rule_version_id'] as String? ?? '',
    state: json['state'] as String? ?? 'draft',
    version: json['version'] as int? ?? 1,
    name: json['name'] as String?,
    plannedPairingAt: _dt(json['planned_pairing_at']),
    matingBaselineAt: _dt(json['mating_baseline_at']),
    activePairingAttemptId: json['active_pairing_attempt_id'] as String?,
    litterId: json['litter_id'] as String?,
    expectedBirthStart: _dt(json['expected_birth_start']),
    expectedBirthEnd: _dt(json['expected_birth_end']),
    actualBirthAt: _dt(json['actual_birth_at']),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sire_id': sireId,
    'dam_id': damId,
    'rule_version_id': ruleVersionId,
    'state': state,
    'version': version,
    'name': name,
    'planned_pairing_at': plannedPairingAt?.toIso8601String(),
    'mating_baseline_at': matingBaselineAt?.toIso8601String(),
    'active_pairing_attempt_id': activePairingAttemptId,
    'litter_id': litterId,
    'expected_birth_start': expectedBirthStart?.toIso8601String(),
    'expected_birth_end': expectedBirthEnd?.toIso8601String(),
    'actual_birth_at': actualBirthAt?.toIso8601String(),
    'notes': notes,
  };
}

class PairingAttempt {
  const PairingAttempt({
    required this.id,
    required this.breedingPlanId,
    required this.enclosureId,
    required this.status,
    required this.version,
    this.startedAt,
    this.separatedAt,
    this.result,
  });

  final String id;
  final String breedingPlanId;
  final String enclosureId;
  final String status;
  final int version;
  final DateTime? startedAt;
  final DateTime? separatedAt;
  final String? result;

  factory PairingAttempt.fromJson(Map<String, dynamic> json) => PairingAttempt(
    id: json['id'] as String? ?? '',
    breedingPlanId: json['breeding_plan_id'] as String? ?? '',
    enclosureId: json['enclosure_id'] as String? ?? '',
    status: json['status'] as String? ?? 'active',
    version: json['version'] as int? ?? 1,
    startedAt: _dt(json['started_at']),
    separatedAt: _dt(json['separated_at']),
    result: json['result'] as String?,
  );
}

class CreateBreedingPlanInput {
  const CreateBreedingPlanInput({
    required this.sireId,
    required this.damId,
    required this.ruleVersionId,
    this.name,
    this.notes,
  });

  final String sireId;
  final String damId;
  final String ruleVersionId;
  final String? name;
  final String? notes;
}

/// Ordered wizard steps for the main happy path.
enum BreedingWizardStep {
  draft,
  pairReady,
  pairing,
  postPair,
  gestation,
  litterNursing,
  other,
}

BreedingWizardStep wizardStepForState(String state) {
  switch (state) {
    case 'draft':
      return BreedingWizardStep.draft;
    case 'pair_ready':
      return BreedingWizardStep.pairReady;
    case 'pairing':
      return BreedingWizardStep.pairing;
    case 'post_pair':
      return BreedingWizardStep.postPair;
    case 'gestation':
      return BreedingWizardStep.gestation;
    case 'litter_nursing':
    case 'weaning_due':
    case 'sex_separation_due':
    case 'individualizing':
    case 'completed':
      return BreedingWizardStep.litterNursing;
    default:
      return BreedingWizardStep.other;
  }
}

String breedingStateLabel(String state) => switch (state) {
  'draft' => '草稿',
  'pair_ready' => '待配对',
  'pairing' => '配对中',
  'post_pair' => '已分笼',
  'gestation' => '孕期观察',
  'litter_nursing' => '带崽中',
  'weaning_due' => '待断奶',
  'sex_separation_due' => '待分性分笼',
  'individualizing' => '个体化中',
  'completed' => '已完成',
  'no_litter_outcome' => '无活仔',
  'hold' => '挂起',
  'unsuccessful' => '未成功',
  'cancelled' => '已取消',
  _ => '状态待更新',
};

/// Next primary action label for the happy path, or null if terminal/other.
String? nextActionLabel(String state) => switch (state) {
  'draft' => '发布计划',
  'pair_ready' => '开始配对',
  'pairing' => '确认分笼',
  'post_pair' => '进入孕期',
  'gestation' => '确认产仔',
  _ => null,
};

/// 本地日历日差（同一天 = 0）；起点晚于 now 时返回 null。
int? breedingCalendarDayIndex(DateTime start, DateTime now) {
  final s = DateTime(
    start.toLocal().year,
    start.toLocal().month,
    start.toLocal().day,
  );
  final n = DateTime(now.toLocal().year, now.toLocal().month, now.toLocal().day);
  if (n.isBefore(s)) return null;
  return n.difference(s).inDays;
}

String formatBreedingDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Draft / Planned：展示计划配对日，不显示 Day N。
String? breedingPlannedPairingLabel(BreedingPlan plan) {
  if (plan.state != 'draft' && plan.state != 'pair_ready') return null;
  final planned = plan.plannedPairingAt;
  if (planned == null) return null;
  return '计划配对日 ${formatBreedingDate(planned)}';
}

/// 真实进程 Day N。
///
/// 权威起点：
/// - pairing：配对尝试 `started_at`（调用方传入 [pairingStartedAt]）
/// - gestation：`mating_baseline_at`
///
/// 禁止用 `planned_pairing_at` 冒充进程日（陈旧计划会出 Day 201）。
/// 完成/取消/无活仔等终态不显示 Day N。
String? breedingDayProgressLabel(
  BreedingPlan plan, {
  DateTime? now,
  DateTime? pairingStartedAt,
}) {
  final clock = now ?? DateTime.now();
  final DateTime? origin = switch (plan.state) {
    'pairing' => pairingStartedAt,
    'gestation' => plan.matingBaselineAt,
    _ => null,
  };
  if (origin == null) return null;
  final day = breedingCalendarDayIndex(origin, clock);
  if (day == null) return null;
  return 'Day $day';
}

DateTime? _dt(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
