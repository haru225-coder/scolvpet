import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../features/i2/i2_models.dart';

abstract interface class I2Repository {
  Future<I2Snapshot> loadSnapshot();

  Future<I2HamsterDetail> getHamsterDetail(String hamsterId);

  Future<I2EnclosureDetail> getEnclosureDetail(String enclosureId);

  Future<List<I2CleaningRecord>> listCleaningHistory(String enclosureId);

  Future<I2Hamster> createHamster(I2HamsterDraft draft);

  Future<I2Enclosure> createEnclosure(I2EnclosureDraft draft);

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

class I2AvatarUpload {
  const I2AvatarUpload({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}

abstract interface class I2AvatarRepository {
  Future<I2Hamster> uploadAvatar(I2Hamster hamster, I2AvatarUpload upload);

  Future<I2Hamster> removeAvatar(I2Hamster hamster);
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
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await preferences.remove(snapshotKey);
        return null;
      }
      return I2Snapshot.fromJson(Map<String, dynamic>.from(decoded));
    } on Object {
      try {
        await preferences.remove(snapshotKey);
      } on Object {
        // Returning null still prevents a bad cache from blocking restore.
      }
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
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await preferences.remove(draftsKey);
        return const <I2Draft>[];
      }
      final drafts = <I2Draft>[];
      for (final value in decoded) {
        if (value is! Map) continue;
        final id = value['id'];
        final payload = value['payload'];
        if (id is! String || id.isEmpty || payload is! Map) continue;
        drafts.add(
          I2Draft(
            id: id,
            kind: value['kind'] is String ? value['kind'] as String : 'unknown',
            payload: Map<String, dynamic>.from(payload),
          ),
        );
      }
      return drafts;
    } on Object {
      try {
        await preferences.remove(draftsKey);
      } on Object {
        // Returning an empty list is the safe fallback for invalid drafts.
      }
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
class DefaultApiI2Repository implements I2Repository, I2AvatarRepository {
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
    final hamsters = await Future.wait(
      hamsterResponse.data.map(
        (value) => _resolveAvatar(I2Hamster.fromJson(value.toJson())),
      ),
    );
    return I2Snapshot(
      hamsters: hamsters,
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
    final hamster = await _resolveAvatar(
      I2Hamster.fromJson(hamsterResponse.data!.data.toJson()),
    );
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
  Future<I2Enclosure> createEnclosure(I2EnclosureDraft draft) async {
    final response = await api.createEnclosure(
      idempotencyKey: _key(),
      enclosureCreateRequest: EnclosureCreateRequest(
        code: draft.code,
        rackCode: draft.rackCode,
        levelCode: draft.levelCode,
        capacity: draft.capacity,
        equipment: draft.equipment.isEmpty ? null : draft.equipment,
      ),
    );
    return I2Enclosure.fromJson(response.data!.data.toJson());
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
        coverMediaId: update.coverMediaId,
      ),
    );
    return I2Hamster.fromJson(response.data!.data.toJson());
  }

  @override
  Future<I2Hamster> uploadAvatar(
    I2Hamster hamster,
    I2AvatarUpload upload,
  ) async {
    final contentType = MediaUploadPresignRequestContentTypeEnum.values
        .where((value) => value.value == upload.contentType)
        .firstOrNull;
    if (contentType == null || !upload.contentType.startsWith('image/')) {
      throw const I2RepositoryException('请选择 JPG、PNG 或 WebP 图片');
    }
    if (upload.bytes.isEmpty || upload.bytes.length > 20 * 1024 * 1024) {
      throw const I2RepositoryException('头像文件需小于 20 MB');
    }
    final digest = sha256.convert(upload.bytes).toString();
    final sessionResponse = await api.presignMediaUpload(
      idempotencyKey: _key(),
      mediaUploadPresignRequest: MediaUploadPresignRequest(
        fileName: upload.fileName,
        contentType: contentType,
        sizeBytes: upload.bytes.length,
        sha256: digest,
        purpose: MediaUploadPresignRequestPurposeEnum.hamsterProfile,
      ),
    );
    final session = sessionResponse.data!.data;
    final uploaded = await Dio().put<Object>(
      session.uploadUrl,
      data: Stream.fromIterable(<List<int>>[upload.bytes]),
      options: Options(
        headers: <String, Object>{
          ...session.headers,
          Headers.contentLengthHeader: upload.bytes.length,
          Headers.contentTypeHeader: upload.contentType,
        },
        responseType: ResponseType.plain,
      ),
    );
    final etag = uploaded.headers.value('etag')?.trim();
    if (etag == null || etag.isEmpty) {
      throw const I2RepositoryException('图片已上传，但对象存储未返回校验标识');
    }
    final completed = await api.completeMediaUpload(
      uploadId: session.id,
      idempotencyKey: _key(),
      ifMatch: _etag(session.version),
      mediaUploadCompleteRequest: MediaUploadCompleteRequest(
        objectEtag: etag,
        sizeBytes: upload.bytes.length,
        sha256: digest,
        timezone: DateTime.now().timeZoneName,
      ),
    );
    final media = completed.data!.data.media;
    final updated = await updateHamster(
      hamster.id,
      hamster.version,
      I2HamsterUpdate(coverMediaId: media.id),
    );
    return _resolveAvatar(updated);
  }

  @override
  Future<I2Hamster> removeAvatar(I2Hamster hamster) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '/hamsters/${hamster.id}',
      data: const <String, Object?>{'cover_media_id': null},
      options: Options(
        headers: <String, String>{
          'Idempotency-Key': _key(),
          'If-Match': _etag(hamster.version),
        },
      ),
    );
    final raw = response.data?['data'];
    if (raw is! Map) throw const I2RepositoryException('头像删除响应为空');
    return I2Hamster.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<I2Hamster> _resolveAvatar(I2Hamster hamster) async {
    final mediaId = hamster.coverMediaId;
    if (mediaId == null || mediaId.isEmpty) return hamster;
    try {
      final response = await api.getMediaAsset(mediaId: mediaId);
      final media = response.data!.data;
      String? url;
      for (final variant in media.variants) {
        if (variant.status.value == 'ready' &&
            (variant.kind.value == 'thumbnail' ||
                variant.kind.value == 'preview') &&
            variant.url != null) {
          url = variant.url;
          break;
        }
      }
      url ??= media.originalUrl;
      return I2Hamster.fromJson(<String, dynamic>{
        ...hamster.toJson(),
        'avatar_url': url,
      });
    } on Object {
      return hamster;
    }
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

class I2RepositoryException implements Exception {
  const I2RepositoryException(this.message, {this.conflict = false});

  final String message;
  final bool conflict;

  @override
  String toString() => message;
}
