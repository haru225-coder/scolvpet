// Health quick-record models (体验补强 · 健康快捷记录).

class HealthRecordItem {
  const HealthRecordItem({
    required this.id,
    this.hamsterId,
    this.litterId,
    required this.type,
    required this.observedAt,
    this.severity,
    this.notes,
    this.followUpAt,
    this.structuredChecks = const <String, dynamic>{},
    this.medication = const <String, dynamic>{},
    required this.version,
  });

  final String id;
  final String? hamsterId;
  final String? litterId;
  final String type;
  final DateTime observedAt;
  final String? severity;
  final String? notes;
  final DateTime? followUpAt;
  final Map<String, dynamic> structuredChecks;
  final Map<String, dynamic> medication;
  final int version;

  String get typeLabel => healthTypeLabel(type);

  factory HealthRecordItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapOf(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return const <String, dynamic>{};
    }

    return HealthRecordItem(
      id: json['id'] as String? ?? '',
      hamsterId: json['hamster_id'] as String?,
      litterId: json['litter_id'] as String?,
      type: json['type'] as String? ?? 'daily_check',
      observedAt:
          DateTime.tryParse(json['observed_at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      severity: json['severity'] as String?,
      notes: json['notes'] as String?,
      followUpAt: DateTime.tryParse(
        json['follow_up_at'] as String? ?? '',
      )?.toUtc(),
      structuredChecks: mapOf(json['structured_checks']),
      medication: mapOf(json['medication']),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hamster_id': hamsterId,
    'litter_id': litterId,
    'type': type,
    'observed_at': observedAt.toIso8601String(),
    'severity': severity,
    'notes': notes,
    'follow_up_at': followUpAt?.toIso8601String(),
    'structured_checks': structuredChecks,
    'medication': medication,
    'version': version,
  };
}

class HealthRecordDraft {
  const HealthRecordDraft({
    this.hamsterId,
    this.litterId,
    required this.type,
    required this.observedAt,
    this.severity,
    this.notes,
    this.followUpAt,
    this.structuredChecks = const <String, dynamic>{},
    this.medication = const <String, dynamic>{},
    this.createFollowUpTask = true,
  });

  final String? hamsterId;
  final String? litterId;
  final String type;
  final DateTime observedAt;
  final String? severity;
  final String? notes;
  final DateTime? followUpAt;
  final Map<String, dynamic> structuredChecks;
  final Map<String, dynamic> medication;

  /// When true and followUpAt is set, also create a care task.
  final bool createFollowUpTask;
}

String healthTypeLabel(String type) => switch (type) {
  'daily_check' => '日常检查',
  'anomaly' => '异常',
  'medication' => '用药',
  'follow_up' => '复查',
  'isolation' => '隔离',
  'death' => '死亡记录',
  _ => type,
};

String healthSeverityLabel(String? severity) => switch (severity) {
  'info' => '信息',
  'low' => '低',
  'medium' => '中',
  'high' => '高',
  'critical' => '危急',
  null || '' => '未标',
  _ => severity,
};

const healthQuickTypes = <String>[
  'daily_check',
  'anomaly',
  'medication',
  'follow_up',
  'isolation',
];
