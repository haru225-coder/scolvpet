import '../../core/app_config.dart';

class PublicSite {
  const PublicSite({
    this.id,
    required this.slug,
    required this.title,
    this.tagline,
    this.about,
    this.contactWechat,
    this.contactPhone,
    required this.themeColor,
    required this.showStats,
    required this.showContact,
    required this.published,
    this.publishedAt,
    this.version = 0,
    this.updatedAt,
    this.publicUrlPath,
  });

  final String? id;
  final String slug;
  final String title;
  final String? tagline;
  final String? about;
  final String? contactWechat;
  final String? contactPhone;
  final String themeColor;
  final bool showStats;
  final bool showContact;
  final bool published;
  final DateTime? publishedAt;
  final int version;
  final DateTime? updatedAt;
  final String? publicUrlPath;

  String get statusLabel => published ? '已发布' : '未发布';

  String get canonicalPublicPath => '/p/$slug';

  String publicUrl({String host = publicSiteHost}) {
    final normalizedHost = host.replaceFirst(RegExp(r'/$'), '');
    return '$normalizedHost$canonicalPublicPath';
  }

  factory PublicSite.fromJson(Map<String, dynamic> json) => PublicSite(
    id: json['id'] as String?,
    slug: json['slug'] as String? ?? '',
    title: json['title'] as String? ?? '',
    tagline: json['tagline'] as String?,
    about: json['about'] as String?,
    contactWechat: json['contact_wechat'] as String?,
    contactPhone: json['contact_phone'] as String?,
    themeColor: json['theme_color'] as String? ?? '#c77852',
    showStats: json['show_stats'] as bool? ?? true,
    showContact: json['show_contact'] as bool? ?? true,
    published: json['published'] as bool? ?? false,
    publishedAt: DateTime.tryParse(
      json['published_at'] as String? ?? '',
    )?.toUtc(),
    version: (json['version'] as num?)?.toInt() ?? 0,
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc(),
    publicUrlPath: json['public_url_path'] as String?,
  );
}

class PublicSiteView {
  const PublicSiteView({
    required this.slug,
    required this.title,
    this.tagline,
    this.about,
    required this.themeColor,
    this.contactWechat,
    this.contactPhone,
    this.stats = const {},
    this.organizationName,
    this.publishedAt,
  });

  final String slug;
  final String title;
  final String? tagline;
  final String? about;
  final String themeColor;
  final String? contactWechat;
  final String? contactPhone;
  final Map<String, dynamic> stats;
  final String? organizationName;
  final DateTime? publishedAt;

  factory PublicSiteView.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    return PublicSiteView(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String?,
      about: json['about'] as String?,
      themeColor: json['theme_color'] as String? ?? '#c77852',
      contactWechat: json['contact_wechat'] as String?,
      contactPhone: json['contact_phone'] as String?,
      stats: stats is Map
          ? Map<String, dynamic>.from(stats)
          : const <String, dynamic>{},
      organizationName: json['organization_name'] as String?,
      publishedAt: DateTime.tryParse(
        json['published_at'] as String? ?? '',
      )?.toUtc(),
    );
  }
}

class PublicSiteDraft {
  const PublicSiteDraft({
    required this.slug,
    required this.title,
    this.tagline,
    this.about,
    this.contactWechat,
    this.contactPhone,
    this.themeColor = '#c77852',
    this.showStats = true,
    this.showContact = true,
  });

  final String slug;
  final String title;
  final String? tagline;
  final String? about;
  final String? contactWechat;
  final String? contactPhone;
  final String themeColor;
  final bool showStats;
  final bool showContact;
}

final publicSiteSlugPattern = RegExp(r'^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$');
