import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
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

String publicSiteErrorMessage(Object error) {
  if (error is PublicSiteRepositoryException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return '公开主页请求失败';
  }
  return error.toString();
}

class MemoryPublicSiteRepository implements PublicSiteRepository {
  PublicSite? _site;
  final Set<String> _takenSlugs = {};

  @override
  Future<PublicSite> getMine() async {
    return _site ??
        const PublicSite(
          slug: 'my-cattery',
          title: '我的熊舍',
          themeColor: '#c77852',
          showStats: true,
          showContact: true,
          published: false,
          publicUrlPath: '/v1/public/sites/my-cattery',
        );
  }

  @override
  Future<PublicSite> save(PublicSiteDraft draft) async {
    final slug = draft.slug.trim().toLowerCase();
    final title = draft.title.trim();
    if (slug.isEmpty) throw const PublicSiteRepositoryException('访问路径必填');
    if (!publicSiteSlugPattern.hasMatch(slug)) {
      throw const PublicSiteRepositoryException('路径格式无效');
    }
    if (title.isEmpty) throw const PublicSiteRepositoryException('标题必填');
    if (_takenSlugs.contains(slug) && _site?.slug != slug) {
      throw const PublicSiteRepositoryException('该访问路径已被占用');
    }
    _takenSlugs.remove(_site?.slug);
    _takenSlugs.add(slug);
    final previous = _site;
    _site = PublicSite(
      id: previous?.id ?? 'psite-1',
      slug: slug,
      title: title,
      tagline: draft.tagline,
      about: draft.about,
      contactWechat: draft.contactWechat,
      contactPhone: draft.contactPhone,
      themeColor: draft.themeColor,
      showStats: draft.showStats,
      showContact: draft.showContact,
      published: previous?.published ?? false,
      publishedAt: previous?.publishedAt,
      version: (previous?.version ?? 0) + 1,
      updatedAt: DateTime.now().toUtc(),
      publicUrlPath: '/v1/public/sites/$slug',
    );
    return _site!;
  }

  @override
  Future<PublicSite> publish() async {
    final current = await getMine();
    if (current.id == null && _site == null) {
      throw const PublicSiteRepositoryException('请先保存公开主页再发布');
    }
    _site = PublicSite(
      id: current.id ?? 'psite-1',
      slug: current.slug,
      title: current.title,
      tagline: current.tagline,
      about: current.about,
      contactWechat: current.contactWechat,
      contactPhone: current.contactPhone,
      themeColor: current.themeColor,
      showStats: current.showStats,
      showContact: current.showContact,
      published: true,
      publishedAt: DateTime.now().toUtc(),
      version: current.version + 1,
      updatedAt: DateTime.now().toUtc(),
      publicUrlPath: current.publicUrlPath,
    );
    return _site!;
  }

  @override
  Future<PublicSite> unpublish() async {
    final current = await getMine();
    _site = PublicSite(
      id: current.id,
      slug: current.slug,
      title: current.title,
      tagline: current.tagline,
      about: current.about,
      contactWechat: current.contactWechat,
      contactPhone: current.contactPhone,
      themeColor: current.themeColor,
      showStats: current.showStats,
      showContact: current.showContact,
      published: false,
      version: current.version + 1,
      updatedAt: DateTime.now().toUtc(),
      publicUrlPath: current.publicUrlPath,
    );
    return _site!;
  }

  @override
  Future<PublicSiteView> getPublicBySlug(String slug) async {
    final site = _site;
    if (site == null || !site.published || site.slug != slug) {
      throw const PublicSiteRepositoryException('公开主页不存在或未发布');
    }
    return PublicSiteView(
      slug: site.slug,
      title: site.title,
      tagline: site.tagline,
      about: site.about,
      themeColor: site.themeColor,
      contactWechat: site.showContact ? site.contactWechat : null,
      contactPhone: site.showContact ? site.contactPhone : null,
      stats: site.showStats
          ? const {
              'active_hamsters': 12,
              'active_litters': 2,
              'enclosures': 8,
            }
          : const {},
      organizationName: site.title,
      publishedAt: site.publishedAt,
    );
  }
}

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
    final response = await client.dio.get<Map<String, dynamic>>(
      '/public-site',
    );
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
