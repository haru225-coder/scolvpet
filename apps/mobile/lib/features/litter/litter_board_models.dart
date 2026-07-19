// Litter board domain for T-P0-03 (wean / sex-separate / individualize).

class LitterPup {
  const LitterPup({
    required this.id,
    required this.temporaryCode,
    required this.outcomeStatus,
    this.sex,
    this.weaned = false,
    this.sexAssigned = false,
    this.individualized = false,
    this.hamsterId,
    this.destinationEnclosureId,
  });

  final String id;
  final String temporaryCode;
  final String outcomeStatus;
  final String? sex;
  final bool weaned;
  final bool sexAssigned;
  final bool individualized;
  final String? hamsterId;
  final String? destinationEnclosureId;

  bool get isAlive => outcomeStatus == 'alive';

  LitterPup copyWith({
    String? outcomeStatus,
    String? sex,
    bool? weaned,
    bool? sexAssigned,
    bool? individualized,
    String? hamsterId,
    String? destinationEnclosureId,
  }) => LitterPup(
    id: id,
    temporaryCode: temporaryCode,
    outcomeStatus: outcomeStatus ?? this.outcomeStatus,
    sex: sex ?? this.sex,
    weaned: weaned ?? this.weaned,
    sexAssigned: sexAssigned ?? this.sexAssigned,
    individualized: individualized ?? this.individualized,
    hamsterId: hamsterId ?? this.hamsterId,
    destinationEnclosureId:
        destinationEnclosureId ?? this.destinationEnclosureId,
  );

  factory LitterPup.fromJson(Map<String, dynamic> json) => LitterPup(
    id: json['id'] as String? ?? '',
    temporaryCode:
        json['temporary_code'] as String? ?? json['code'] as String? ?? '',
    outcomeStatus: json['outcome_status'] as String? ?? 'alive',
    sex: json['sex'] as String?,
    weaned: json['weaned'] as bool? ?? false,
    sexAssigned: json['sex_assigned'] as bool? ?? false,
    individualized: json['individualized'] as bool? ?? false,
    hamsterId: json['hamster_id'] as String?,
    destinationEnclosureId: json['destination_enclosure_id'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'temporary_code': temporaryCode,
    'outcome_status': outcomeStatus,
    'sex': sex,
    'weaned': weaned,
    'sex_assigned': sexAssigned,
    'individualized': individualized,
    'hamster_id': hamsterId,
    'destination_enclosure_id': destinationEnclosureId,
  };
}

/// One confirmed destination for a living pup during sex separation.
class LitterPupSeparation {
  const LitterPupSeparation({
    required this.pupIdentityId,
    required this.sex,
    required this.destinationEnclosureId,
    this.requiresRecheck = false,
  });

  final String pupIdentityId;
  final String sex;
  final String destinationEnclosureId;
  final bool requiresRecheck;
}

/// Profile fields used when turning a pup identity into a hamster record.
class LitterPupProfileDraft {
  const LitterPupProfileDraft({
    required this.pupIdentityId,
    required this.internalCode,
    this.name,
  });

  final String pupIdentityId;
  final String internalCode;
  final String? name;
}

class LitterBoard {
  const LitterBoard({
    required this.id,
    required this.state,
    required this.version,
    required this.bornAt,
    required this.initialAliveCount,
    required this.currentManagedCount,
    required this.enclosureId,
    required this.pups,
    this.code,
    this.sireId,
    this.damId,
  });

  final String id;
  final String? code;
  final String state;
  final int version;
  final DateTime bornAt;
  final int initialAliveCount;
  final int currentManagedCount;
  final String enclosureId;
  final String? sireId;
  final String? damId;
  final List<LitterPup> pups;

  String get displayName {
    final c = code?.trim();
    if (c != null && c.isNotEmpty) return c;
    return '${bornAt.month}月${bornAt.day}日出生的一窝';
  }

  List<LitterPup> get alivePups => pups.where((p) => p.isAlive).toList();

  LitterBoard copyWith({
    String? state,
    int? version,
    int? currentManagedCount,
    List<LitterPup>? pups,
  }) => LitterBoard(
    id: id,
    code: code,
    state: state ?? this.state,
    version: version ?? this.version,
    bornAt: bornAt,
    initialAliveCount: initialAliveCount,
    currentManagedCount: currentManagedCount ?? this.currentManagedCount,
    enclosureId: enclosureId,
    sireId: sireId,
    damId: damId,
    pups: pups ?? this.pups,
  );

  factory LitterBoard.fromJson(Map<String, dynamic> json) => LitterBoard(
    id: json['id'] as String? ?? '',
    code: json['code'] as String?,
    state: json['state'] as String? ?? 'litter_nursing',
    version: json['version'] as int? ?? 1,
    bornAt:
        DateTime.tryParse(json['born_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    initialAliveCount: json['initial_alive_count'] as int? ?? 0,
    currentManagedCount: json['current_managed_count'] as int? ?? 0,
    enclosureId: json['enclosure_id'] as String? ?? '',
    sireId: json['sire_id'] as String?,
    damId: json['dam_id'] as String?,
    pups: ((json['pups'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => LitterPup.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

/// Next primary board action for the happy path.
enum LitterBoardAction { wean, sexAndSeparate, individualize }

LitterBoardAction? nextLitterAction(String state) {
  switch (state) {
    case 'weaning_due':
      return LitterBoardAction.wean;
    case 'sexing_due':
    case 'sex_separation_due':
      return LitterBoardAction.sexAndSeparate;
    case 'individualizing':
      return LitterBoardAction.individualize;
    default:
      return null;
  }
}

bool isLitterTerminal(String state) => state == 'closed' || state == 'voided';

String litterWaitingMessage(String state) => switch (state) {
  'litter_nursing' || 'nursing' || 'newborn' =>
    '幼崽仍在带崽期。到达断奶日后，系统会开放断奶操作。',
  'closed' => '这一窝已完成，已建档幼崽可在仓鼠列表查看。',
  'voided' => '这一窝已作废，不再继续阶段操作。',
  _ => '当前状态没有可执行的阶段操作，请刷新后再次检查。',
};

String litterActionLabel(LitterBoardAction action) => switch (action) {
  LitterBoardAction.wean => '断奶',
  LitterBoardAction.sexAndSeparate => '分性分笼',
  LitterBoardAction.individualize => '个体化建档',
};

String litterBoardStateLabel(String state) => switch (state) {
  'litter_nursing' || 'nursing' => '带崽中',
  'newborn' => '新生',
  'weaning_due' => '待断奶',
  'sexing_due' || 'sex_separation_due' => '待分性分笼',
  'individualizing' => '待个体化',
  'closed' => '已关闭',
  'voided' => '已作废',
  _ => '状态待更新',
};

String litterPupOutcomeLabel(String status) => switch (status) {
  'alive' => '存活',
  'dead' || 'stillborn' => '未存活',
  'adopted' => '已送养',
  'missing' => '待确认',
  _ => '状态待更新',
};

String litterPupSexLabel(String? sex) => switch (sex) {
  'male' => '公',
  'female' => '母',
  'unknown' || null => '性别待定',
  _ => '性别待定',
};
