import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'miniprogram_models.dart';

abstract interface class MiniprogramRepository {
  Future<MiniprogramConfig> getConfig();
  Future<MiniprogramConfig> saveConfig(MiniprogramConfigDraft draft);
  Future<List<MiniprogramRelease>> listReleases();
  Future<MiniprogramRelease> createRelease(MiniprogramReleaseDraft draft);
  Future<MiniprogramRelease> submit(String id);
  Future<MiniprogramRelease> audit(
    String id, {
    required bool approve,
    String? note,
  });
  Future<MiniprogramRelease> publish(String id);
  Future<MiniprogramRelease> rollback(String id);
}

class MiniprogramRepositoryException implements Exception {
  const MiniprogramRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String miniprogramErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '小程序请求失败',
  mapLocal: (e) => e is MiniprogramRepositoryException ? e.message : null,
);

class MemoryMiniprogramRepository implements MiniprogramRepository {
  MiniprogramConfig _config = const MiniprogramConfig(
    displayName: '熊舍小程序',
    enabled: true,
    pipelineNote: '沙箱审核链：草稿→提交→审核→发布→回滚',
  );
  final List<MiniprogramRelease> _releases = [];
  int _seq = 0;

  @override
  Future<MiniprogramConfig> getConfig() async => _config;

  @override
  Future<MiniprogramConfig> saveConfig(MiniprogramConfigDraft draft) async {
    _config = MiniprogramConfig(
      id: _config.id ?? 'mpcfg-1',
      displayName: draft.displayName.trim().isEmpty
          ? '熊舍小程序'
          : draft.displayName.trim(),
      appId: draft.appId,
      boundPublicSlug: draft.boundPublicSlug,
      enabled: draft.enabled,
      version: _config.version + 1,
      updatedAt: DateTime.now().toUtc(),
      pipelineNote: _config.pipelineNote,
    );
    return _config;
  }

  @override
  Future<List<MiniprogramRelease>> listReleases() async =>
      List<MiniprogramRelease>.from(_releases);

  @override
  Future<MiniprogramRelease> createRelease(
    MiniprogramReleaseDraft draft,
  ) async {
    final label = draft.versionLabel.trim().isEmpty
        ? 'v${_seq + 1}'
        : draft.versionLabel.trim();
    if (_releases.any((r) => r.versionLabel == label)) {
      throw const MiniprogramRepositoryException('版本号已存在');
    }
    final item = MiniprogramRelease(
      id: 'mprel-${_seq++}',
      versionLabel: label,
      status: 'draft',
      title: draft.title.trim().isEmpty ? '熊舍展示版' : draft.title.trim(),
      summary: draft.summary,
      publicSlug: draft.publicSlug ?? _config.boundPublicSlug,
      version: 1,
      createdAt: DateTime.now().toUtc(),
    );
    _releases.insert(0, item);
    return item;
  }

  @override
  Future<MiniprogramRelease> submit(String id) async {
    return _set(id, (c) {
      if (!c.canSubmit) {
        throw const MiniprogramRepositoryException('仅草稿或已驳回可提交');
      }
      return _copy(c, status: 'submitted', submittedAt: DateTime.now().toUtc());
    });
  }

  @override
  Future<MiniprogramRelease> audit(
    String id, {
    required bool approve,
    String? note,
  }) async {
    return _set(id, (c) {
      if (!c.canAudit) {
        throw const MiniprogramRepositoryException('仅已提交可审核');
      }
      return _copy(
        c,
        status: approve ? 'approved' : 'rejected',
        auditNote: note ?? (approve ? '沙箱审核通过' : '沙箱审核驳回'),
        auditedAt: DateTime.now().toUtc(),
      );
    });
  }

  @override
  Future<MiniprogramRelease> publish(String id) async {
    final index = _releases.indexWhere((r) => r.id == id);
    if (index < 0) throw const MiniprogramRepositoryException('版本不存在');
    final current = _releases[index];
    if (!current.canPublish) {
      throw const MiniprogramRepositoryException('仅审核通过可发布');
    }
    for (var i = 0; i < _releases.length; i++) {
      if (_releases[i].status == 'published' && _releases[i].id != id) {
        _releases[i] = _copy(
          _releases[i],
          status: 'rolled_back',
          rolledBackAt: DateTime.now().toUtc(),
        );
      }
    }
    final next = _copy(
      current,
      status: 'published',
      publishedAt: DateTime.now().toUtc(),
    );
    _releases[index] = next;
    return next;
  }

  @override
  Future<MiniprogramRelease> rollback(String id) async {
    return _set(id, (c) {
      if (!c.canRollback) {
        throw const MiniprogramRepositoryException('仅线上版本可回滚');
      }
      return _copy(
        c,
        status: 'rolled_back',
        rolledBackAt: DateTime.now().toUtc(),
      );
    });
  }

  Future<MiniprogramRelease> _set(
    String id,
    MiniprogramRelease Function(MiniprogramRelease current) transform,
  ) async {
    final index = _releases.indexWhere((r) => r.id == id);
    if (index < 0) throw const MiniprogramRepositoryException('版本不存在');
    final next = transform(_releases[index]);
    _releases[index] = next;
    return next;
  }

  MiniprogramRelease _copy(
    MiniprogramRelease c, {
    String? status,
    String? auditNote,
    DateTime? submittedAt,
    DateTime? auditedAt,
    DateTime? publishedAt,
    DateTime? rolledBackAt,
  }) {
    return MiniprogramRelease(
      id: c.id,
      versionLabel: c.versionLabel,
      status: status ?? c.status,
      title: c.title,
      summary: c.summary,
      publicSlug: c.publicSlug,
      auditNote: auditNote ?? c.auditNote,
      submittedAt: submittedAt ?? c.submittedAt,
      auditedAt: auditedAt ?? c.auditedAt,
      publishedAt: publishedAt ?? c.publishedAt,
      rolledBackAt: rolledBackAt ?? c.rolledBackAt,
      version: c.version + 1,
      createdAt: c.createdAt,
    );
  }
}

class DefaultApiMiniprogramRepository implements MiniprogramRepository {
  DefaultApiMiniprogramRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'mp-${_uuid.v4()}';

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const MiniprogramRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> _listData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<MiniprogramConfig> getConfig() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/miniprogram/config',
    );
    return MiniprogramConfig.fromJson(_data(response));
  }

  @override
  Future<MiniprogramConfig> saveConfig(MiniprogramConfigDraft draft) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '/miniprogram/config',
      data: {
        'display_name': draft.displayName,
        if (draft.appId != null) 'app_id': draft.appId,
        if (draft.boundPublicSlug != null)
          'bound_public_slug': draft.boundPublicSlug,
        'enabled': draft.enabled,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return MiniprogramConfig.fromJson(_data(response));
  }

  @override
  Future<List<MiniprogramRelease>> listReleases() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/miniprogram/releases',
    );
    return _listData(response).map(MiniprogramRelease.fromJson).toList();
  }

  @override
  Future<MiniprogramRelease> createRelease(
    MiniprogramReleaseDraft draft,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/miniprogram/releases',
      data: {
        'version_label': draft.versionLabel,
        'title': draft.title,
        if (draft.summary != null) 'summary': draft.summary,
        if (draft.publicSlug != null) 'public_slug': draft.publicSlug,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return MiniprogramRelease.fromJson(_data(response));
  }

  @override
  Future<MiniprogramRelease> submit(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/miniprogram/releases/$id/submit',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return MiniprogramRelease.fromJson(_data(response));
  }

  @override
  Future<MiniprogramRelease> audit(
    String id, {
    required bool approve,
    String? note,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/miniprogram/releases/$id/audit',
      data: {
        'decision': approve ? 'approve' : 'reject',
        if (note != null) 'note': note,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return MiniprogramRelease.fromJson(_data(response));
  }

  @override
  Future<MiniprogramRelease> publish(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/miniprogram/releases/$id/publish',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return MiniprogramRelease.fromJson(_data(response));
  }

  @override
  Future<MiniprogramRelease> rollback(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/miniprogram/releases/$id/rollback',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return MiniprogramRelease.fromJson(_data(response));
  }
}
