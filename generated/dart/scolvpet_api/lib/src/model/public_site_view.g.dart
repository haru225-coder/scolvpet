// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_site_view.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicSiteViewCWProxy {
  PublicSiteView slug(String slug);

  PublicSiteView title(String title);

  PublicSiteView tagline(String? tagline);

  PublicSiteView about(String? about);

  PublicSiteView themeColor(String themeColor);

  PublicSiteView contactWechat(String? contactWechat);

  PublicSiteView contactPhone(String? contactPhone);

  PublicSiteView stats(Map<String, Object>? stats);

  PublicSiteView organizationName(String? organizationName);

  PublicSiteView publishedAt(DateTime? publishedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicSiteView(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicSiteView(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicSiteView call({
    String slug,
    String title,
    String? tagline,
    String? about,
    String themeColor,
    String? contactWechat,
    String? contactPhone,
    Map<String, Object>? stats,
    String? organizationName,
    DateTime? publishedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicSiteView.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicSiteView.copyWith.fieldName(...)`
class _$PublicSiteViewCWProxyImpl implements _$PublicSiteViewCWProxy {
  const _$PublicSiteViewCWProxyImpl(this._value);

  final PublicSiteView _value;

  @override
  PublicSiteView slug(String slug) => this(slug: slug);

  @override
  PublicSiteView title(String title) => this(title: title);

  @override
  PublicSiteView tagline(String? tagline) => this(tagline: tagline);

  @override
  PublicSiteView about(String? about) => this(about: about);

  @override
  PublicSiteView themeColor(String themeColor) => this(themeColor: themeColor);

  @override
  PublicSiteView contactWechat(String? contactWechat) =>
      this(contactWechat: contactWechat);

  @override
  PublicSiteView contactPhone(String? contactPhone) =>
      this(contactPhone: contactPhone);

  @override
  PublicSiteView stats(Map<String, Object>? stats) => this(stats: stats);

  @override
  PublicSiteView organizationName(String? organizationName) =>
      this(organizationName: organizationName);

  @override
  PublicSiteView publishedAt(DateTime? publishedAt) =>
      this(publishedAt: publishedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicSiteView(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicSiteView(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicSiteView call({
    Object? slug = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? tagline = const $CopyWithPlaceholder(),
    Object? about = const $CopyWithPlaceholder(),
    Object? themeColor = const $CopyWithPlaceholder(),
    Object? contactWechat = const $CopyWithPlaceholder(),
    Object? contactPhone = const $CopyWithPlaceholder(),
    Object? stats = const $CopyWithPlaceholder(),
    Object? organizationName = const $CopyWithPlaceholder(),
    Object? publishedAt = const $CopyWithPlaceholder(),
  }) {
    return PublicSiteView(
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      tagline: tagline == const $CopyWithPlaceholder()
          ? _value.tagline
          // ignore: cast_nullable_to_non_nullable
          : tagline as String?,
      about: about == const $CopyWithPlaceholder()
          ? _value.about
          // ignore: cast_nullable_to_non_nullable
          : about as String?,
      themeColor: themeColor == const $CopyWithPlaceholder()
          ? _value.themeColor
          // ignore: cast_nullable_to_non_nullable
          : themeColor as String,
      contactWechat: contactWechat == const $CopyWithPlaceholder()
          ? _value.contactWechat
          // ignore: cast_nullable_to_non_nullable
          : contactWechat as String?,
      contactPhone: contactPhone == const $CopyWithPlaceholder()
          ? _value.contactPhone
          // ignore: cast_nullable_to_non_nullable
          : contactPhone as String?,
      stats: stats == const $CopyWithPlaceholder()
          ? _value.stats
          // ignore: cast_nullable_to_non_nullable
          : stats as Map<String, Object>?,
      organizationName: organizationName == const $CopyWithPlaceholder()
          ? _value.organizationName
          // ignore: cast_nullable_to_non_nullable
          : organizationName as String?,
      publishedAt: publishedAt == const $CopyWithPlaceholder()
          ? _value.publishedAt
          // ignore: cast_nullable_to_non_nullable
          : publishedAt as DateTime?,
    );
  }
}

extension $PublicSiteViewCopyWith on PublicSiteView {
  /// Returns a callable class that can be used as follows: `instanceOfPublicSiteView.copyWith(...)` or like so:`instanceOfPublicSiteView.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicSiteViewCWProxy get copyWith => _$PublicSiteViewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicSiteView _$PublicSiteViewFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PublicSiteView',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['slug', 'title', 'theme_color']);
        final val = PublicSiteView(
          slug: $checkedConvert('slug', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          tagline: $checkedConvert('tagline', (v) => v as String?),
          about: $checkedConvert('about', (v) => v as String?),
          themeColor: $checkedConvert('theme_color', (v) => v as String),
          contactWechat: $checkedConvert('contact_wechat', (v) => v as String?),
          contactPhone: $checkedConvert('contact_phone', (v) => v as String?),
          stats: $checkedConvert(
            'stats',
            (v) => (v as Map<String, dynamic>?)?.map(
              (k, e) => MapEntry(k, e as Object),
            ),
          ),
          organizationName: $checkedConvert(
            'organization_name',
            (v) => v as String?,
          ),
          publishedAt: $checkedConvert(
            'published_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'themeColor': 'theme_color',
        'contactWechat': 'contact_wechat',
        'contactPhone': 'contact_phone',
        'organizationName': 'organization_name',
        'publishedAt': 'published_at',
      },
    );

Map<String, dynamic> _$PublicSiteViewToJson(PublicSiteView instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title,
      'tagline': ?instance.tagline,
      'about': ?instance.about,
      'theme_color': instance.themeColor,
      'contact_wechat': ?instance.contactWechat,
      'contact_phone': ?instance.contactPhone,
      'stats': ?instance.stats,
      'organization_name': ?instance.organizationName,
      'published_at': ?instance.publishedAt?.toIso8601String(),
    };
