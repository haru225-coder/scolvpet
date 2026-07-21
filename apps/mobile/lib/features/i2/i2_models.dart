import 'dart:convert';
import 'dart:typed_data';

enum I2AsyncStatus { idle, loading, data, empty, error, conflict }

class I2AsyncState<T> {
  const I2AsyncState._({
    required this.status,
    this.data,
    this.message,
    this.retryable = false,
  });

  const I2AsyncState.idle() : this._(status: I2AsyncStatus.idle);

  const I2AsyncState.loading() : this._(status: I2AsyncStatus.loading);

  const I2AsyncState.data(T value)
    : this._(status: I2AsyncStatus.data, data: value);

  const I2AsyncState.empty({String? message, bool retryable = false})
    : this._(
        status: I2AsyncStatus.empty,
        message: message,
        retryable: retryable,
      );

  const I2AsyncState.error(String value, {bool retryable = true})
    : this._(status: I2AsyncStatus.error, message: value, retryable: retryable);

  const I2AsyncState.conflict(String value)
    : this._(status: I2AsyncStatus.conflict, message: value, retryable: true);

  final I2AsyncStatus status;
  final T? data;
  final String? message;
  final bool retryable;

  bool get hasValue => status == I2AsyncStatus.data && data != null;
}

class I2Hamster {
  const I2Hamster({
    required this.id,
    required this.internalCode,
    required this.name,
    required this.sex,
    required this.varietyCode,
    required this.lifecycleStatus,
    required this.breedingStatus,
    required this.birthDate,
    required this.currentEnclosureId,
    required this.litterId,
    this.coverMediaId,
    this.avatarUrl,
    this.avatarBytes,
    required this.notes,
    required this.version,
  });

  final String id;
  final String internalCode;
  final String? name;
  final String sex;
  final String? varietyCode;
  final String lifecycleStatus;
  final String breedingStatus;
  final DateTime? birthDate;
  final String? currentEnclosureId;
  final String? litterId;
  final String? coverMediaId;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final String? notes;
  final int version;

  String get displayName => name == null || name!.trim().isEmpty
      ? internalCode
      : '$name · $internalCode';

  /// Core-table phenotype label (from variety_code `series|label` or bare label).
  String? get corePhenotypeLabel {
    final raw = varietyCode?.trim();
    if (raw == null || raw.isEmpty) return null;
    final sep = raw.indexOf('|');
    if (sep > 0 && sep < raw.length - 1) return raw.substring(sep + 1);
    return raw;
  }

  /// Core-table series code when encoded as `series|label`.
  String? get coreSeriesCode {
    final raw = varietyCode?.trim();
    if (raw == null || raw.isEmpty) return null;
    final sep = raw.indexOf('|');
    if (sep > 0) return raw.substring(0, sep);
    return null;
  }

  bool get hasCorePhenotype =>
      corePhenotypeLabel != null && corePhenotypeLabel!.isNotEmpty;

  factory I2Hamster.fromJson(Map<String, dynamic> json) {
    // Prefer structured phenotype.label when present (API authority path).
    String? variety = json['variety_code'] as String?;
    final phenotype = json['phenotype'];
    if (phenotype is Map) {
      final series = phenotype['series']?.toString().trim();
      final label = phenotype['label']?.toString().trim();
      if (series != null &&
          series.isNotEmpty &&
          label != null &&
          label.isNotEmpty) {
        variety = '$series|$label';
      } else if ((variety == null || variety.isEmpty) &&
          label != null &&
          label.isNotEmpty) {
        variety = label;
      }
    }
    return I2Hamster(
      id: json['id'] as String? ?? '',
      internalCode: json['internal_code'] as String? ?? '',
      name: json['name'] as String?,
      sex: json['sex'] as String? ?? 'unknown',
      varietyCode: variety,
      lifecycleStatus: json['lifecycle_status'] as String? ?? 'active',
      breedingStatus: json['breeding_status'] as String? ?? 'candidate',
      birthDate: _date(json['birth_date']),
      currentEnclosureId: json['current_enclosure_id'] as String?,
      litterId: json['litter_id'] as String?,
      coverMediaId: json['cover_media_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      avatarBytes: _bytes(json['avatar_bytes']),
      notes: json['notes'] as String?,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'internal_code': internalCode,
    'name': name,
    'sex': sex,
    'variety_code': varietyCode,
    'lifecycle_status': lifecycleStatus,
    'breeding_status': breedingStatus,
    'birth_date': birthDate?.toIso8601String(),
    'current_enclosure_id': currentEnclosureId,
    'litter_id': litterId,
    'cover_media_id': coverMediaId,
    'avatar_url': avatarUrl,
    'avatar_bytes': avatarBytes == null ? null : base64Encode(avatarBytes!),
    'notes': notes,
    'version': version,
  };
}

/// Encode core phenotype into variety_code for API transport.
String encodeCoreVarietyCode(String series, String label) =>
    '${series.trim()}|${label.trim()}';

class I2HamsterDraft {
  const I2HamsterDraft({
    required this.internalCode,
    required this.speciesRuleVersionId,
    required this.sex,
    required this.sourceType,
    this.name,
    this.varietyCode,
    this.sexConfidence,
    this.birthDate,
    this.notes,
    this.sireId,
    this.damId,
    this.litterId,
  });

  final String internalCode;
  final String speciesRuleVersionId;
  final String sex;
  final String sourceType;
  final String? name;
  final String? varietyCode;
  final num? sexConfidence;
  final DateTime? birthDate;
  final String? notes;
  final String? sireId;
  final String? damId;
  final String? litterId;

  Map<String, dynamic> toJson() => {
    'internal_code': internalCode,
    'species_rule_version_id': speciesRuleVersionId,
    'sex': sex,
    'source_type': sourceType,
    'name': name,
    'variety_code': varietyCode,
    'sex_confidence': sexConfidence,
    'birth_date': birthDate?.toIso8601String(),
    'notes': notes,
    'sire_id': sireId,
    'dam_id': damId,
    'litter_id': litterId,
  };
}

class I2HamsterUpdate {
  const I2HamsterUpdate({
    this.internalCode,
    this.name,
    this.varietyCode,
    this.sex,
    this.sexConfidence,
    this.birthDate,
    this.lifecycleStatus,
    this.breedingStatus,
    this.notes,
    this.coverMediaId,
  });

  final String? internalCode;
  final String? name;
  final String? varietyCode;
  final String? sex;
  final num? sexConfidence;
  final DateTime? birthDate;
  final String? lifecycleStatus;
  final String? breedingStatus;
  final String? notes;
  final String? coverMediaId;
}

class I2Litter {
  const I2Litter({
    required this.id,
    required this.code,
    required this.origin,
    required this.bornAt,
    required this.initialAliveCount,
    required this.currentManagedCount,
    required this.state,
    required this.enclosureId,
    required this.sireId,
    required this.damId,
    required this.version,
  });

  final String id;
  final String? code;
  final String origin;
  final DateTime bornAt;
  final int initialAliveCount;
  final int currentManagedCount;
  final String state;
  final String enclosureId;
  final String sireId;
  final String damId;
  final int version;

  factory I2Litter.fromJson(Map<String, dynamic> json) => I2Litter(
    id: json['id'] as String? ?? '',
    code: json['code'] as String?,
    origin: json['origin'] as String? ?? 'breeding',
    bornAt: _date(json['born_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    initialAliveCount: json['initial_alive_count'] as int? ?? 0,
    currentManagedCount: json['current_managed_count'] as int? ?? 0,
    state: json['state'] as String? ?? 'closed',
    enclosureId: json['enclosure_id'] as String? ?? '',
    sireId: json['sire_id'] as String? ?? '',
    damId: json['dam_id'] as String? ?? '',
    version: json['version'] as int? ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'origin': origin,
    'born_at': bornAt.toIso8601String(),
    'initial_alive_count': initialAliveCount,
    'current_managed_count': currentManagedCount,
    'state': state,
    'enclosure_id': enclosureId,
    'sire_id': sireId,
    'dam_id': damId,
    'version': version,
  };
}

class I2HamsterDetail {
  const I2HamsterDetail({
    required this.hamster,
    required this.litters,
    required this.weights,
  });

  final I2Hamster hamster;
  final List<I2Litter> litters;
  final List<I2WeightRecord> weights;
}

class I2Enclosure {
  const I2Enclosure({
    required this.id,
    required this.code,
    required this.rackCode,
    required this.levelCode,
    required this.state,
    required this.cleanlinessState,
    required this.capacity,
    required this.equipment,
    required this.lastCleanedAt,
    required this.currentHamsterIds,
    required this.version,
  });

  final String id;
  final String code;
  final String? rackCode;
  final String? levelCode;
  final String state;
  final String cleanlinessState;
  final int? capacity;
  final List<String> equipment;
  final DateTime? lastCleanedAt;
  final List<String> currentHamsterIds;
  final int version;

  String get rackLabel =>
      rackCode?.trim().isNotEmpty == true ? rackCode! : '未分架';

  String get levelLabel =>
      levelCode?.trim().isNotEmpty == true ? levelCode! : '未分层';

  factory I2Enclosure.fromJson(Map<String, dynamic> json) => I2Enclosure(
    id: json['id'] as String? ?? '',
    code: json['code'] as String? ?? '',
    rackCode: json['rack_code'] as String?,
    levelCode: json['level_code'] as String?,
    state: json['state'] as String? ?? 'vacant',
    cleanlinessState: json['cleanliness_state'] as String? ?? 'clean',
    capacity: json['capacity'] as int?,
    equipment: ((json['equipment'] as List?) ?? const <dynamic>[])
        .whereType<String>()
        .toList(),
    lastCleanedAt: _date(json['last_cleaned_at']),
    currentHamsterIds: ((json['current_stays'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((value) => value['hamster_id'])
        .whereType<String>()
        .toList(),
    version: json['version'] as int? ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'rack_code': rackCode,
    'level_code': levelCode,
    'state': state,
    'cleanliness_state': cleanlinessState,
    'capacity': capacity,
    'equipment': equipment,
    'last_cleaned_at': lastCleanedAt?.toIso8601String(),
    'current_stays': currentHamsterIds.map((id) => {'hamster_id': id}).toList(),
    'version': version,
  };
}

class I2EnclosureDraft {
  const I2EnclosureDraft({
    required this.code,
    this.rackCode,
    this.levelCode,
    this.capacity = 1,
    this.equipment = const <String>[],
  });

  final String code;
  final String? rackCode;
  final String? levelCode;
  final int capacity;
  final List<String> equipment;
}

class I2EnclosureStay {
  const I2EnclosureStay({
    required this.id,
    required this.enclosureId,
    required this.hamsterId,
    required this.purpose,
    required this.startedAt,
    required this.endedAt,
    required this.reason,
    required this.version,
  });

  final String id;
  final String enclosureId;
  final String hamsterId;
  final String purpose;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? reason;
  final int version;

  factory I2EnclosureStay.fromJson(Map<String, dynamic> json) =>
      I2EnclosureStay(
        id: json['id'] as String? ?? '',
        enclosureId: json['enclosure_id'] as String? ?? '',
        hamsterId: json['hamster_id'] as String? ?? '',
        purpose: json['purpose'] as String? ?? 'single',
        startedAt:
            _date(json['started_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        endedAt: _date(json['ended_at']),
        reason: json['reason'] as String?,
        version: json['version'] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'enclosure_id': enclosureId,
    'hamster_id': hamsterId,
    'purpose': purpose,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'reason': reason,
    'version': version,
  };
}

class I2EnclosureDetail {
  const I2EnclosureDetail({required this.enclosure, required this.stays});

  final I2Enclosure enclosure;
  final List<I2EnclosureStay> stays;
}

class I2MoveDraft {
  const I2MoveDraft({
    required this.enclosureId,
    required this.hamsterId,
    required this.purpose,
    required this.startedAt,
    this.previousStayId,
    this.reason,
  });

  final String enclosureId;
  final String hamsterId;
  final String purpose;
  final DateTime startedAt;
  final String? previousStayId;
  final String? reason;
}

/// Map stay purpose → enclosure state after move (T-P0-08).
String enclosureStateForPurpose(String purpose, {required int occupantCount}) {
  switch (purpose) {
    case 'isolation':
    case 'quarantine':
      return 'isolation';
    case 'pairing_temp':
      return 'pairing_temp';
    case 'gestation':
      return 'gestation';
    case 'dam_with_litter':
      return 'dam_with_litter';
    default:
      if (occupantCount <= 0) return 'vacant';
      if (occupantCount == 1) return 'occupied_single';
      return 'occupied';
  }
}

class I2WeightRecord {
  const I2WeightRecord({
    required this.id,
    required this.hamsterId,
    required this.litterId,
    required this.measurementKind,
    required this.subjectCount,
    required this.weightG,
    required this.recordedAt,
    required this.source,
    required this.previousWeightG,
    required this.changeFromPreviousG,
    this.birthWeightG,
    this.alertFlags = const <String>[],
    required this.notes,
  });

  final String id;
  final String? hamsterId;
  final String? litterId;
  final String measurementKind;
  final int? subjectCount;
  final num weightG;
  final DateTime recordedAt;
  final String source;
  final num? previousWeightG;
  final num? changeFromPreviousG;
  final num? birthWeightG;
  final List<String> alertFlags;
  final String? notes;

  bool get hasAlert => alertFlags.isNotEmpty;

  factory I2WeightRecord.fromJson(Map<String, dynamic> json) => I2WeightRecord(
    id: json['id'] as String? ?? '',
    hamsterId: json['hamster_id'] as String?,
    litterId: json['litter_id'] as String?,
    measurementKind: json['measurement_kind'] as String? ?? 'individual',
    subjectCount: json['subject_count'] as int?,
    weightG: (json['weight_g'] as num?) ?? 0,
    recordedAt:
        _date(json['recorded_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    source: json['source'] as String? ?? 'manual',
    previousWeightG: json['previous_weight_g'] as num?,
    changeFromPreviousG: json['change_from_previous_g'] as num?,
    birthWeightG: json['birth_weight_g'] as num?,
    alertFlags: ((json['alert_flags'] as List?) ?? const <dynamic>[])
        .map((e) => e.toString())
        .toList(),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hamster_id': hamsterId,
    'litter_id': litterId,
    'measurement_kind': measurementKind,
    'subject_count': subjectCount,
    'weight_g': weightG,
    'recorded_at': recordedAt.toIso8601String(),
    'source': source,
    'previous_weight_g': previousWeightG,
    'change_from_previous_g': changeFromPreviousG,
    'birth_weight_g': birthWeightG,
    'alert_flags': alertFlags,
    'notes': notes,
  };
}

class I2WeightDraft {
  const I2WeightDraft({
    this.hamsterId,
    this.litterId,
    this.measurementKind = 'individual',
    this.subjectCount,
    required this.weightG,
    required this.recordedAt,
    this.notes,
  });

  final String? hamsterId;
  final String? litterId;
  final String measurementKind;
  final int? subjectCount;
  final num weightG;
  final DateTime recordedAt;
  final String? notes;
}

class I2WeightBatchFailure {
  const I2WeightBatchFailure({required this.hamsterId, required this.message});

  final String? hamsterId;
  final String message;
}

class I2WeightBatchResult {
  const I2WeightBatchResult({
    required this.totalCount,
    required this.successfulHamsterIds,
    required this.failures,
  });

  final int totalCount;
  final List<String> successfulHamsterIds;
  final List<I2WeightBatchFailure> failures;

  int get successCount => successfulHamsterIds.length;
  int get failureCount => failures.length;
  bool get isCompleteSuccess => successCount == totalCount && failures.isEmpty;
  bool get isCompleteFailure => successCount == 0 && failures.isNotEmpty;
  bool get isPartialSuccess => successCount > 0 && failures.isNotEmpty;
}

class I2CleaningRecord {
  const I2CleaningRecord({
    required this.id,
    required this.enclosureId,
    required this.type,
    required this.completedAt,
    required this.reason,
    required this.healthRecordId,
    required this.operatorLabel,
    this.supplies = const <String, Object?>{},
    this.correctsCleaningRecordId,
    this.correctionReason,
    this.createdAt,
  });

  final String id;
  final String enclosureId;
  final String type;
  final DateTime completedAt;
  final String? reason;
  final String? healthRecordId;
  final String? operatorLabel;
  final Map<String, Object?> supplies;
  final String? correctsCleaningRecordId;
  final String? correctionReason;
  final DateTime? createdAt;

  factory I2CleaningRecord.fromJson(
    Map<String, dynamic> json,
  ) => I2CleaningRecord(
    id: json['id'] as String? ?? '',
    enclosureId: json['enclosure_id'] as String? ?? '',
    type: json['cleaning_type'] as String? ?? json['type'] as String? ?? 'full',
    completedAt:
        _date(json['performed_at']) ??
        _date(json['completed_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    reason: json['notes'] as String? ?? json['reason'] as String?,
    healthRecordId: json['health_record_id'] as String?,
    operatorLabel: json['operator_label'] as String?,
    supplies: ((json['supplies'] as Map?) ?? const <dynamic, dynamic>{}).map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    correctsCleaningRecordId: json['corrects_cleaning_record_id'] as String?,
    correctionReason: json['correction_reason'] as String?,
    createdAt: _date(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'enclosure_id': enclosureId,
    'type': type,
    'cleaning_type': type,
    'completed_at': completedAt.toIso8601String(),
    'performed_at': completedAt.toIso8601String(),
    'reason': reason,
    'notes': reason,
    'health_record_id': healthRecordId,
    'operator_label': operatorLabel,
    'supplies': supplies,
    'corrects_cleaning_record_id': correctsCleaningRecordId,
    'correction_reason': correctionReason,
    'created_at': createdAt?.toIso8601String(),
  };
}

class I2CleaningDraft {
  const I2CleaningDraft({
    required this.enclosureId,
    required this.type,
    required this.completedAt,
    this.enclosureVersion = 1,
    this.reason,
    this.healthRecordId,
    this.supplies = const <String, Object?>{},
    this.correctsCleaningRecordId,
    this.correctionReason,
  });

  final String enclosureId;
  final String type;
  final DateTime completedAt;
  final int enclosureVersion;
  final String? reason;
  final String? healthRecordId;
  final Map<String, Object?> supplies;
  final String? correctsCleaningRecordId;
  final String? correctionReason;
}

enum I2ImportStage {
  idle,
  uploading,
  mapping,
  preflight,
  conflictPreview,
  committing,
  report,
  error,
}

class I2CsvUpload {
  const I2CsvUpload({
    required this.fileName,
    required this.bytes,
    required this.sha256,
    required this.template,
  });

  final String fileName;
  final Uint8List bytes;
  final String sha256;
  final String template;
}

class I2ImportMapping {
  const I2ImportMapping({
    required this.sourceColumn,
    required this.targetField,
  });

  final String sourceColumn;
  final String targetField;
}

class I2ImportIssue {
  const I2ImportIssue({
    required this.rowNumber,
    required this.code,
    required this.message,
    required this.severity,
    this.columnName,
    this.suggestion,
  });

  final int rowNumber;
  final String code;
  final String message;
  final String severity;
  final String? columnName;
  final String? suggestion;
}

class I2ImportRowResult {
  const I2ImportRowResult({
    required this.rowNumber,
    required this.status,
    required this.mappedValues,
    required this.issues,
    this.resourceId,
  });

  final int rowNumber;
  final String status;
  final Map<String, Object?> mappedValues;
  final List<I2ImportIssue> issues;
  final String? resourceId;
}

class I2ImportJob {
  const I2ImportJob({
    required this.id,
    required this.version,
    required this.phase,
    required this.status,
    required this.progressPercent,
    required this.sourceColumns,
    required this.mapping,
    required this.preflightVersion,
    required this.totalRows,
    required this.validRows,
    required this.warningRows,
    required this.invalidRows,
    required this.blockingIssueCount,
    required this.importedRows,
  });

  final String id;
  final int version;
  final String phase;
  final String status;
  final int progressPercent;
  final List<String> sourceColumns;
  final Map<String, String> mapping;
  final int? preflightVersion;
  final int totalRows;
  final int validRows;
  final int warningRows;
  final int invalidRows;
  final int blockingIssueCount;
  final int importedRows;

  bool get hasBlockingIssues => blockingIssueCount > 0 || invalidRows > 0;
}

class I2Snapshot {
  const I2Snapshot({
    required this.hamsters,
    required this.litters,
    required this.enclosures,
    required this.lastSyncedAt,
    this.recentWeights = const <I2WeightRecord>[],
  });

  final List<I2Hamster> hamsters;
  final List<I2Litter> litters;
  final List<I2Enclosure> enclosures;
  final DateTime? lastSyncedAt;

  /// Latest/recent individual weights used for home/list alerts.
  final List<I2WeightRecord> recentWeights;

  Map<String, dynamic> toJson() => {
    'hamsters': hamsters.map((value) => value.toJson()).toList(),
    'litters': litters.map((value) => value.toJson()).toList(),
    'enclosures': enclosures.map((value) => value.toJson()).toList(),
    'last_synced_at': lastSyncedAt?.toIso8601String(),
    'recent_weights': recentWeights.map((value) => value.toJson()).toList(),
  };

  factory I2Snapshot.fromJson(Map<String, dynamic> json) => I2Snapshot(
    hamsters: ((json['hamsters'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((value) => I2Hamster.fromJson(Map<String, dynamic>.from(value)))
        .toList(),
    litters: ((json['litters'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((value) => I2Litter.fromJson(Map<String, dynamic>.from(value)))
        .toList(),
    enclosures: ((json['enclosures'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((value) => I2Enclosure.fromJson(Map<String, dynamic>.from(value)))
        .toList(),
    lastSyncedAt: _date(json['last_synced_at']),
    recentWeights: ((json['recent_weights'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map(
          (value) => I2WeightRecord.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList(),
  );
}

class I2Draft {
  const I2Draft({required this.id, required this.kind, required this.payload});

  final String id;
  final String kind;
  final Map<String, dynamic> payload;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

Uint8List? _bytes(Object? value) {
  if (value is Uint8List) return value;
  if (value is! String || value.isEmpty) return null;
  try {
    return base64Decode(value);
  } on FormatException {
    return null;
  }
}
