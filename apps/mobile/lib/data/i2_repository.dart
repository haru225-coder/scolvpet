import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../features/i2/i2_models.dart';
import '../features/weight/weight_alerts.dart';

abstract interface class I2Repository {
  Future<I2Snapshot> loadSnapshot();

  Future<I2HamsterDetail> getHamsterDetail(String hamsterId);

  Future<I2EnclosureDetail> getEnclosureDetail(String enclosureId);

  Future<List<I2CleaningRecord>> listCleaningHistory(String enclosureId);

  Future<I2Hamster> createHamster(I2HamsterDraft draft);

  Future<List<I2Hamster>> createHamsters(List<I2HamsterDraft> drafts);

  Future<I2Hamster> updateHamster(
    String hamsterId,
    int version,
    I2HamsterUpdate update,
  );

  Future<I2EnclosureStay> moveHamster(
    I2MoveDraft draft, {
    int enclosureVersion = 1,
  });

  Future<I2EnclosureStay> closeStay(
    String stayId,
    int version, {
    DateTime? endedAt,
    String? reason,
  });

  Future<I2Enclosure> cleanEnclosure(
    String enclosureId,
    int version, {
    DateTime? cleanedAt,
  });

  Future<I2CleaningRecord> recordCleaning(I2CleaningDraft draft);

  Future<I2WeightRecord> createWeight(I2WeightDraft draft);

  Future<List<I2WeightRecord>> listWeights(String hamsterId);

  Future<I2ImportJob> uploadCsv(I2CsvUpload upload);

  Future<I2ImportJob> setImportMapping(
    String jobId,
    int version,
    List<I2ImportMapping> mappings,
  );

  Future<I2ImportJob> preflightImport(String jobId, int version);

  Future<I2ImportJob> commitImport(
    String jobId,
    int version, {
    Set<I2ImportApprovedUpdate> approvedUpdates =
        const <I2ImportApprovedUpdate>{},
  });

  Future<List<I2ImportRowResult>> listImportRows(String jobId);
}

abstract interface class I2LocalStore {
  Future<I2Snapshot?> readSnapshot();

  Future<void> saveSnapshot(I2Snapshot snapshot);

  Future<List<I2Draft>> readDrafts();

  Future<void> saveDraft(I2Draft draft);

  Future<void> deleteDraft(String id);
}

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

class SharedPreferencesI2LocalStore implements I2LocalStore {
  SharedPreferencesI2LocalStore({
    required this.preferences,
    this.snapshotKey = 'scolvpet.i2.snapshot',
    this.draftsKey = 'scolvpet.i2.drafts',
  });

  final SharedPreferences preferences;
  final String snapshotKey;
  final String draftsKey;

  @override
  Future<I2Snapshot?> readSnapshot() async {
    final raw = preferences.getString(snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return I2Snapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveSnapshot(I2Snapshot snapshot) async {
    await preferences.setString(snapshotKey, jsonEncode(snapshot.toJson()));
  }

  @override
  Future<List<I2Draft>> readDrafts() async {
    final raw = preferences.getString(draftsKey);
    if (raw == null || raw.isEmpty) return const <I2Draft>[];
    try {
      final values = (jsonDecode(raw) as List).whereType<Map>();
      return values
          .map(
            (value) => I2Draft(
              id: value['id'] as String? ?? '',
              kind: value['kind'] as String? ?? 'unknown',
              payload: Map<String, dynamic>.from(value['payload'] as Map),
            ),
          )
          .where((draft) => draft.id.isNotEmpty)
          .toList();
    } on Object {
      return const <I2Draft>[];
    }
  }

  @override
  Future<void> saveDraft(I2Draft draft) async {
    final drafts = await readDrafts();
    final next = [...drafts.where((value) => value.id != draft.id), draft];
    await preferences.setString(
      draftsKey,
      jsonEncode(
        next
            .map(
              (value) => {
                'id': value.id,
                'kind': value.kind,
                'payload': value.payload,
              },
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> deleteDraft(String id) async {
    final drafts = await readDrafts();
    await preferences.setString(
      draftsKey,
      jsonEncode(
        drafts
            .where((value) => value.id != id)
            .map(
              (value) => {
                'id': value.id,
                'kind': value.kind,
                'payload': value.payload,
              },
            )
            .toList(),
      ),
    );
  }
}

class I2ImportApprovedUpdate {
  const I2ImportApprovedUpdate({
    required this.rowNumber,
    required this.resourceId,
    required this.expectedVersion,
    required this.fields,
  });

  final int rowNumber;
  final String resourceId;
  final int expectedVersion;
  final Set<String> fields;
}

/// 新版 OpenAPI 生成后由主 Agent 用 DefaultApi 实现此 gateway；页面和 I2Repository
/// 只依赖这个稳定的领域接口，避免把 generated 类型扩散到功能切片。
abstract interface class I2CleaningHistoryGateway {
  Future<List<I2CleaningRecord>> list(String enclosureId);

  Future<I2CleaningRecord> create(I2CleaningDraft draft);
}

/// 生产实现只依赖 DefaultApi 和 ApiClient，不让页面直接接触生成模型。
class DefaultApiI2Repository implements I2Repository {
  DefaultApiI2Repository({required this.client, this.cleaningHistoryGateway});

  final ApiClient client;
  final I2CleaningHistoryGateway? cleaningHistoryGateway;
  DefaultApi get api => client.api;

  String _key() => 'i2-${DateTime.now().microsecondsSinceEpoch}';

  String _etag(int version) => '"$version"';

  @override
  Future<I2Snapshot> loadSnapshot() async {
    final results = await Future.wait<Object>([
      api.listHamsters(limit: 100),
      api.listLitters(limit: 100),
      api.listEnclosures(limit: 100),
      api.listWeightRecords(limit: 100),
    ]);
    final hamsterResponse = (results[0] as Response<HamsterListResponse>).data!;
    final litterResponse = (results[1] as Response<LitterListResponse>).data!;
    final enclosureResponse =
        (results[2] as Response<EnclosureListResponse>).data!;
    final weightResponse =
        (results[3] as Response<WeightRecordListResponse>).data!;
    return I2Snapshot(
      hamsters: hamsterResponse.data
          .map((value) => I2Hamster.fromJson(value.toJson()))
          .toList(),
      litters: litterResponse.data
          .map((value) => I2Litter.fromJson(value.toJson()))
          .toList(),
      enclosures: enclosureResponse.data
          .map((value) => I2Enclosure.fromJson(value.toJson()))
          .toList(),
      lastSyncedAt: DateTime.now(),
      recentWeights: weightResponse.data
          .map((value) => I2WeightRecord.fromJson(value.toJson()))
          .toList(),
    );
  }

  @override
  Future<I2HamsterDetail> getHamsterDetail(String hamsterId) async {
    final hamsterResponse = await api.getHamster(hamsterId: hamsterId);
    final weightsResponse = await api.listWeightRecords(
      hamsterId: hamsterId,
      limit: 100,
    );
    final littersResponse = await api.listLitters(limit: 100);
    final hamster = I2Hamster.fromJson(hamsterResponse.data!.data.toJson());
    final litters = littersResponse.data!.data
        .where((value) => value.sireId == hamsterId || value.damId == hamsterId)
        .map((value) => I2Litter.fromJson(value.toJson()))
        .toList();
    return I2HamsterDetail(
      hamster: hamster,
      litters: litters,
      weights: weightsResponse.data!.data
          .map((value) => I2WeightRecord.fromJson(value.toJson()))
          .toList(),
    );
  }

  @override
  Future<I2EnclosureDetail> getEnclosureDetail(String enclosureId) async {
    final enclosureResponse = await api.getEnclosure(enclosureId: enclosureId);
    final staysResponse = await api.listEnclosureStays(
      enclosureId: enclosureId,
      limit: 100,
    );
    return I2EnclosureDetail(
      enclosure: I2Enclosure.fromJson(enclosureResponse.data!.data.toJson()),
      stays: staysResponse.data!.data
          .map((value) => I2EnclosureStay.fromJson(value.toJson()))
          .toList(),
    );
  }

  @override
  Future<List<I2CleaningRecord>> listCleaningHistory(String enclosureId) async {
    final gateway = cleaningHistoryGateway;
    if (gateway != null) return gateway.list(enclosureId);
    final response = await api.listEnclosureCleanings(
      enclosureId: enclosureId,
      limit: 100,
    );
    return response.data!.data.map(_cleaningRecord).toList();
  }

  @override
  Future<I2Hamster> createHamster(I2HamsterDraft draft) async {
    final response = await api.createHamster(
      idempotencyKey: _key(),
      hamsterCreateRequest: HamsterCreateRequest(
        internalCode: draft.internalCode,
        name: draft.name,
        speciesRuleVersionId: draft.speciesRuleVersionId,
        varietyCode: draft.varietyCode,
        sex: _sex(draft.sex),
        sexConfidence: draft.sexConfidence,
        birthDate: draft.birthDate,
        sourceType: _sourceType(draft.sourceType),
        notes: draft.notes,
        sireId: draft.sireId,
        damId: draft.damId,
        litterId: draft.litterId,
      ),
    );
    return I2Hamster.fromJson(response.data!.data.toJson());
  }

  @override
  Future<List<I2Hamster>> createHamsters(List<I2HamsterDraft> drafts) async {
    final response = await api.batchCreateHamsters(
      idempotencyKey: _key(),
      hamsterBatchCreateRequest: HamsterBatchCreateRequest(
        atomic: true,
        items: drafts
            .asMap()
            .entries
            .map(
              (entry) => HamsterBatchCreateRequestItemsInner(
                clientItemId: 'i2-${entry.key}',
                hamster: HamsterCreateRequest(
                  internalCode: entry.value.internalCode,
                  name: entry.value.name,
                  speciesRuleVersionId: entry.value.speciesRuleVersionId,
                  varietyCode: entry.value.varietyCode,
                  sex: _sex(entry.value.sex),
                  sexConfidence: entry.value.sexConfidence,
                  birthDate: entry.value.birthDate,
                  sourceType: _sourceType(entry.value.sourceType),
                  notes: entry.value.notes,
                  sireId: entry.value.sireId,
                  damId: entry.value.damId,
                  litterId: entry.value.litterId,
                ),
              ),
            )
            .toList(),
      ),
    );
    final data = response.data!.data.toJson();
    final rawItems = (data['items'] as List?) ?? const <dynamic>[];
    return rawItems
        .whereType<Map>()
        .map(
          (item) => I2Hamster.fromJson(
            Map<String, dynamic>.from(item['hamster'] as Map),
          ),
        )
        .toList();
  }

  @override
  Future<I2Hamster> updateHamster(
    String hamsterId,
    int version,
    I2HamsterUpdate update,
  ) async {
    final response = await api.updateHamster(
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      hamsterId: hamsterId,
      hamsterUpdateRequest: HamsterUpdateRequest(
        internalCode: update.internalCode,
        name: update.name,
        varietyCode: update.varietyCode,
        sex: update.sex == null ? null : _sex(update.sex!),
        sexConfidence: update.sexConfidence,
        birthDate: update.birthDate,
        notes: update.notes,
      ),
    );
    return I2Hamster.fromJson(response.data!.data.toJson());
  }

  @override
  Future<I2EnclosureStay> moveHamster(
    I2MoveDraft draft, {
    int enclosureVersion = 1,
  }) async {
    final response = await api.createEnclosureStay(
      idempotencyKey: _key(),
      ifMatch: _etag(enclosureVersion),
      enclosureId: draft.enclosureId,
      enclosureStayCreateRequest: EnclosureStayCreateRequest(
        hamsterId: draft.hamsterId,
        purpose: _stayPurpose(draft.purpose),
        startedAt: draft.startedAt,
        previousStayId: draft.previousStayId,
        reason: draft.reason,
      ),
    );
    return I2EnclosureStay.fromJson(response.data!.data.toJson());
  }

  @override
  Future<I2EnclosureStay> closeStay(
    String stayId,
    int version, {
    DateTime? endedAt,
    String? reason,
  }) async {
    final response = await api.updateEnclosureStay(
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      stayId: stayId,
      enclosureStayUpdateRequest: EnclosureStayUpdateRequest(
        endedAt: endedAt ?? DateTime.now(),
        reason: reason,
      ),
    );
    return I2EnclosureStay.fromJson(response.data!.data.toJson());
  }

  @override
  Future<I2Enclosure> cleanEnclosure(
    String enclosureId,
    int version, {
    DateTime? cleanedAt,
  }) async {
    await api.createEnclosureCleaning(
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      enclosureId: enclosureId,
      enclosureCleaningCreateRequest: EnclosureCleaningCreateRequest(
        cleaningType: EnclosureCleaningType.full,
        performedAt: cleanedAt ?? DateTime.now(),
      ),
    );
    final response = await api.getEnclosure(enclosureId: enclosureId);
    return I2Enclosure.fromJson(response.data!.data.toJson());
  }

  @override
  Future<I2CleaningRecord> recordCleaning(I2CleaningDraft draft) async {
    final gateway = cleaningHistoryGateway;
    if (gateway != null) return gateway.create(draft);
    final supplies = <String, Object>{
      for (final entry in draft.supplies.entries)
        if (entry.value != null) entry.key: entry.value!,
      if (draft.healthRecordId != null)
        'health_record_id': draft.healthRecordId!,
    };
    final response = await api.createEnclosureCleaning(
      idempotencyKey: _key(),
      ifMatch: _etag(draft.enclosureVersion),
      enclosureId: draft.enclosureId,
      enclosureCleaningCreateRequest: EnclosureCleaningCreateRequest(
        cleaningType: _cleaningType(draft.type),
        performedAt: draft.completedAt,
        supplies: supplies,
        notes: draft.reason,
        correctsCleaningRecordId: draft.correctsCleaningRecordId,
        correctionReason: draft.correctionReason,
      ),
    );
    return _cleaningRecord(response.data!.data);
  }

  @override
  Future<I2WeightRecord> createWeight(I2WeightDraft draft) async {
    final response = await api.createWeightRecord(
      idempotencyKey: _key(),
      weightRecordCreateRequest: WeightRecordCreateRequest(
        hamsterId: draft.hamsterId,
        litterId: draft.litterId,
        measurementKind: _measurementKind(draft.measurementKind),
        subjectCount: draft.subjectCount,
        weightG: draft.weightG,
        recordedAt: draft.recordedAt,
        source_: WeightRecordCreateRequestSource_Enum.manual,
        notes: draft.notes,
      ),
    );
    return I2WeightRecord.fromJson(response.data!.data.toJson());
  }

  @override
  Future<List<I2WeightRecord>> listWeights(String hamsterId) async {
    final response = await api.listWeightRecords(
      hamsterId: hamsterId,
      limit: 100,
    );
    return response.data!.data
        .map((value) => I2WeightRecord.fromJson(value.toJson()))
        .toList();
  }

  @override
  Future<I2ImportJob> uploadCsv(I2CsvUpload upload) async {
    final uploadResponse = await api.createImportUpload(
      idempotencyKey: _key(),
      importUploadCreateRequest: ImportUploadCreateRequest(
        fileName: upload.fileName,
        sizeBytes: upload.bytes.length,
        sha256: upload.sha256,
      ),
    );
    final session = uploadResponse.data!.data;
    await client.dio.put<Object>(
      session.uploadUrl,
      data: upload.bytes,
      options: Options(headers: session.headers, contentType: 'text/csv'),
    );
    final jobResponse = await api.createImportJob(
      idempotencyKey: _key(),
      importJobCreateRequest: ImportJobCreateRequest(
        uploadId: session.id,
        templateType: _templateType(upload.template),
        templateVersion: 'v1',
        sourceEncoding: ImportJobCreateRequestSourceEncodingEnum.utf8,
      ),
    );
    return _importJob(jobResponse.data!.data);
  }

  @override
  Future<I2ImportJob> setImportMapping(
    String jobId,
    int version,
    List<I2ImportMapping> mappings,
  ) async {
    final response = await api.setImportMapping(
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      jobId: jobId,
      importMappingRequest: ImportMappingRequest(
        timezone: 'Asia/Shanghai',
        mappings: mappings
            .map(
              (value) => ImportMappingRequestMappingsInner(
                sourceColumn: value.sourceColumn,
                targetField: value.targetField,
                emptyValuePolicy:
                    ImportMappingRequestMappingsInnerEmptyValuePolicyEnum
                        .keepNull,
              ),
            )
            .toList(),
      ),
    );
    return _importJob(response.data!.data);
  }

  @override
  Future<I2ImportJob> preflightImport(String jobId, int version) async {
    final response = await api.preflightImportJob(
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      jobId: jobId,
      importPreflightRequest: ImportPreflightRequest(
        strictReferences: ImportPreflightRequestStrictReferencesEnum.true_,
        historicalLitterPolicy:
            ImportPreflightRequestHistoricalLitterPolicyEnum.createIfComplete,
        parentageConflictPolicy:
            ImportPreflightRequestParentageConflictPolicyEnum.reject,
        existingFieldPolicy:
            ImportPreflightRequestExistingFieldPolicyEnum.preserveNonNull,
      ),
    );
    return _importJob(response.data!.data);
  }

  @override
  Future<I2ImportJob> commitImport(
    String jobId,
    int version, {
    Set<I2ImportApprovedUpdate> approvedUpdates =
        const <I2ImportApprovedUpdate>{},
  }) async {
    final response = await api.commitImportJob(
      idempotencyKey: _key(),
      ifMatch: _etag(version),
      jobId: jobId,
      importCommitRequest: ImportCommitRequest(
        preflightVersion: version,
        batchKey: _key(),
        partialFailurePolicy:
            ImportCommitRequestPartialFailurePolicyEnum.continueAndReport,
        approvedUpdates: approvedUpdates
            .map(
              (value) => ImportCommitRequestApprovedUpdatesInner(
                rowNumber: value.rowNumber,
                resourceId: value.resourceId,
                expectedVersion: value.expectedVersion,
                fields: value.fields,
              ),
            )
            .toSet(),
      ),
    );
    return _importJob(response.data!.data);
  }

  @override
  Future<List<I2ImportRowResult>> listImportRows(String jobId) async {
    final response = await api.listImportRowResults(jobId: jobId, limit: 100);
    return response.data!.data.map((value) => _importRow(value)).toList();
  }
}

I2ImportJob _importJob(ImportJob value) => I2ImportJob(
  id: value.id,
  version: value.version,
  phase: value.phase.value,
  status: value.status.value,
  progressPercent: value.progressPercent,
  sourceColumns: value.sourceColumns,
  mapping: value.mapping,
  preflightVersion: value.preflightVersion,
  totalRows: value.totalRows,
  validRows: value.validRows,
  warningRows: value.warningRows,
  invalidRows: value.invalidRows,
  blockingIssueCount: value.blockingIssueCount,
  importedRows: value.importedRows,
);

I2ImportRowResult _importRow(ImportRowResult value) => I2ImportRowResult(
  rowNumber: value.rowNumber,
  status: value.status.value,
  mappedValues: Map<String, Object?>.from(value.mappedValues),
  resourceId: value.resourceId,
  issues: value.issues
      .map(
        (issue) => I2ImportIssue(
          rowNumber: issue.rowNumber,
          code: issue.code,
          message: issue.message,
          severity: issue.severity.value,
          columnName: issue.columnName,
          suggestion: issue.suggestion,
        ),
      )
      .toList(),
);

Sex _sex(String value) => Sex.values.firstWhere(
  (item) => item.value == value,
  orElse: () => Sex.unknown,
);

HamsterSourceType _sourceType(String value) =>
    HamsterSourceType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => HamsterSourceType.introduced,
    );

EnclosureStayCreateRequestPurposeEnum _stayPurpose(String value) =>
    EnclosureStayCreateRequestPurposeEnum.values.firstWhere(
      (item) => item.value == value,
      orElse: () => EnclosureStayCreateRequestPurposeEnum.single,
    );

EnclosureCleaningType _cleaningType(String value) =>
    EnclosureCleaningType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => EnclosureCleaningType.full,
    );

WeightRecordCreateRequestMeasurementKindEnum _measurementKind(String value) =>
    WeightRecordCreateRequestMeasurementKindEnum.values.firstWhere(
      (item) => item.value == value,
      orElse: () => WeightRecordCreateRequestMeasurementKindEnum.individual,
    );

I2CleaningRecord _cleaningRecord(EnclosureCleaning value) {
  final json = value.toJson();
  final supplies = json['supplies'];
  if (supplies is Map && supplies['health_record_id'] != null) {
    json['health_record_id'] = supplies['health_record_id'];
  }
  return I2CleaningRecord.fromJson(json);
}

ImportTemplateType _templateType(String value) =>
    ImportTemplateType.values.firstWhere(
      (item) => item.value == value,
      orElse: () => ImportTemplateType.hamster,
    );

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
    final weights =
        _weights.where((w) => w.hamsterId == hamsterId).toList()
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
    final stays =
        _stays.where((s) => s.enclosureId == enclosureId).toList()
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
      final history =
          _weights.where((w) => w.hamsterId == hamsterId).toList()
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
    final values =
        _weights.where((w) => w.hamsterId == hamsterId).toList()
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

class I2RepositoryException implements Exception {
  const I2RepositoryException(this.message, {this.conflict = false});

  final String message;
  final bool conflict;

  @override
  String toString() => message;
}
