import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import 'health_models.dart';

abstract interface class HealthRepository {
  Future<List<HealthRecordItem>> listRecords({
    String? hamsterId,
    String? litterId,
  });

  Future<HealthRecordItem> createRecord(HealthRecordDraft draft);
}

class HealthRepositoryException implements Exception {
  const HealthRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String healthErrorMessage(Object error) {
  if (error is HealthRepositoryException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return '健康记录请求失败，请稍后重试';
  }
  return error.toString();
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
    if ((draft.hamsterId == null || draft.hamsterId!.isEmpty) &&
        (draft.litterId == null || draft.litterId!.isEmpty)) {
      throw const HealthRepositoryException('必须关联仓鼠或窝次');
    }
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

class DefaultApiHealthRepository implements HealthRepository {
  DefaultApiHealthRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  api.DefaultApi get _api => client.api;
  String _key() => 'health-${_uuid.v4()}';

  HealthRecordItem _map(api.HealthRecord record) {
    return HealthRecordItem.fromJson(
      Map<String, dynamic>.from(record.toJson() as Map),
    );
  }

  api.HealthRecordType _type(String value) => api.HealthRecordType.values
      .firstWhere((t) => t.value == value, orElse: () => api.HealthRecordType.dailyCheck);

  api.Severity? _severity(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = api.Severity.values.where((s) => s.value == value);
    return match.isEmpty ? null : match.first;
  }

  @override
  Future<List<HealthRecordItem>> listRecords({
    String? hamsterId,
    String? litterId,
  }) async {
    final response = await _api.listHealthRecords(
      hamsterId: hamsterId,
      litterId: litterId,
      limit: 100,
    );
    final data = response.data?.data ?? const <api.HealthRecord>[];
    return data.map(_map).toList()
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
  }

  @override
  Future<HealthRecordItem> createRecord(HealthRecordDraft draft) async {
    final response = await _api.createHealthRecord(
      idempotencyKey: _key(),
      healthRecordCreateRequest: api.HealthRecordCreateRequest(
        hamsterId: draft.hamsterId,
        litterId: draft.litterId,
        type: _type(draft.type),
        observedAt: draft.observedAt.toUtc(),
        structuredChecks: draft.structuredChecks.isEmpty
            ? null
            : Map<String, Object>.from(draft.structuredChecks),
        severity: _severity(draft.severity),
        medication: draft.medication.isEmpty
            ? null
            : Map<String, Object>.from(draft.medication),
        followUpAt: draft.followUpAt?.toUtc(),
        notes: draft.notes,
      ),
    );
    final data = response.data?.data;
    if (data == null) {
      throw const HealthRepositoryException('创建健康记录失败');
    }
    return _map(data);
  }
}
