import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
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

String healthErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '健康记录请求失败，请稍后重试',
  mapLocal: (e) => e is HealthRepositoryException ? e.message : null,
);

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

  api.HealthRecordType _type(String value) =>
      api.HealthRecordType.values.firstWhere(
        (t) => t.value == value,
        orElse: () => api.HealthRecordType.dailyCheck,
      );

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
    _validateHealthDraft(draft);
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
