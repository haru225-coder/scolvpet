import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'public_site_models.dart';

abstract interface class PublicSiteRepository {
  Future<PublicSite> getMine();
  Future<PublicSite> save(PublicSiteDraft draft);
  Future<PublicSite> publish();
  Future<PublicSite> unpublish();
  Future<PublicSiteView> getPublicBySlug(String slug);
}

class PublicSiteRepositoryException implements Exception {
  const PublicSiteRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String publicSiteErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '公开主页请求失败',
  mapLocal: (e) => e is PublicSiteRepositoryException ? e.message : null,
);
class DefaultApiPublicSiteRepository implements PublicSiteRepository {
  DefaultApiPublicSiteRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'psite-${_uuid.v4()}';

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const PublicSiteRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<PublicSite> getMine() async {
    final response = await client.dio.get<Map<String, dynamic>>('/public-site');
    return PublicSite.fromJson(_data(response));
  }

  @override
  Future<PublicSite> save(PublicSiteDraft draft) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '/public-site',
      data: {
        'slug': draft.slug,
        'title': draft.title,
        if (draft.tagline != null) 'tagline': draft.tagline,
        if (draft.about != null) 'about': draft.about,
        if (draft.contactWechat != null) 'contact_wechat': draft.contactWechat,
        if (draft.contactPhone != null) 'contact_phone': draft.contactPhone,
        'theme_color': draft.themeColor,
        'show_stats': draft.showStats,
        'show_contact': draft.showContact,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return PublicSite.fromJson(_data(response));
  }

  @override
  Future<PublicSite> publish() async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/public-site/publish',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return PublicSite.fromJson(_data(response));
  }

  @override
  Future<PublicSite> unpublish() async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/public-site/unpublish',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return PublicSite.fromJson(_data(response));
  }

  @override
  Future<PublicSiteView> getPublicBySlug(String slug) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/public/sites/$slug',
    );
    return PublicSiteView.fromJson(_data(response));
  }
}
