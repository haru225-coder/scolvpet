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
