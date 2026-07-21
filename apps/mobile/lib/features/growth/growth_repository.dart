import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import '../../core/media_url.dart';
import 'growth_models.dart';

abstract interface class GrowthRepository {
  Future<List<GrowthPublicHamster>> listPublicHamsters();
  Future<GrowthPublicHamster> upsertPublicHamster(
    String hamsterId,
    GrowthPublicHamsterDraft draft,
  );
  Future<List<GrowthCampaign>> listCampaigns();
  Future<GrowthCampaign> generateCampaign(GrowthGenerateDraft draft);
  Future<GrowthCampaign> publishCampaign(String campaignId);
  Future<GrowthCampaign> archiveCampaign(String campaignId);
  Future<List<GrowthLead>> listLeads();
}

class GrowthRepositoryException implements Exception {
  const GrowthRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String growthErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '获客请求失败',
  mapLocal: (e) => e is GrowthRepositoryException ? e.message : null,
);

class DefaultApiGrowthRepository implements GrowthRepository {
  DefaultApiGrowthRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  List<Map<String, dynamic>> _list(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) throw const GrowthRepositoryException('响应为空');
    return Map<String, dynamic>.from(data);
  }

  Options _idempotent(String prefix) =>
      Options(headers: {'Idempotency-Key': '$prefix-${_uuid.v4()}'});

  Map<String, dynamic> _normalizePublicMedia(Map<String, dynamic> data) {
    final media = data['media'];
    if (media is! List) return data;
    data['media'] = [
      for (final raw in media)
        if (raw is Map)
          () {
            final item = Map<String, dynamic>.from(raw);
            final resolved = resolveMediaUrl(
              item['url']?.toString(),
              apiBaseUrl: client.dio.options.baseUrl,
            );
            if (resolved != null) {
              item['url'] = resolved;
            }
            return item;
          }(),
    ];
    return data;
  }

  @override
  Future<List<GrowthPublicHamster>> listPublicHamsters() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/growth/public-hamsters',
    );
    return _list(
      response,
    ).map(_normalizePublicMedia).map(GrowthPublicHamster.fromJson).toList();
  }

  @override
  Future<GrowthPublicHamster> upsertPublicHamster(
    String hamsterId,
    GrowthPublicHamsterDraft draft,
  ) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '/growth/public-hamsters/$hamsterId',
      data: draft.toJson(),
      options: _idempotent('growth-profile'),
    );
    return GrowthPublicHamster.fromJson(_normalizePublicMedia(_data(response)));
  }

  @override
  Future<List<GrowthCampaign>> listCampaigns() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/growth/campaigns',
    );
    return _list(response).map(GrowthCampaign.fromJson).toList();
  }

  @override
  Future<GrowthCampaign> generateCampaign(GrowthGenerateDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/growth/campaigns/generate',
      data: draft.toJson(),
      options: _idempotent('growth-gen'),
    );
    return GrowthCampaign.fromJson(_data(response));
  }

  @override
  Future<GrowthCampaign> publishCampaign(String campaignId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/growth/campaigns/$campaignId/publish',
      options: _idempotent('growth-pub'),
    );
    return GrowthCampaign.fromJson(_data(response));
  }

  @override
  Future<GrowthCampaign> archiveCampaign(String campaignId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/growth/campaigns/$campaignId/archive',
      options: _idempotent('growth-arch'),
    );
    return GrowthCampaign.fromJson(_data(response));
  }

  @override
  Future<List<GrowthLead>> listLeads() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/growth/leads',
    );
    return _list(response).map(GrowthLead.fromJson).toList();
  }
}
