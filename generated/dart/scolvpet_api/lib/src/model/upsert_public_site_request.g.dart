// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_public_site_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpsertPublicSiteRequestCWProxy {
  UpsertPublicSiteRequest slug(String slug);

  UpsertPublicSiteRequest title(String title);

  UpsertPublicSiteRequest tagline(String? tagline);

  UpsertPublicSiteRequest about(String? about);

  UpsertPublicSiteRequest contactWechat(String? contactWechat);

  UpsertPublicSiteRequest contactPhone(String? contactPhone);

  UpsertPublicSiteRequest themeColor(String? themeColor);

  UpsertPublicSiteRequest showStats(bool? showStats);

  UpsertPublicSiteRequest showContact(bool? showContact);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertPublicSiteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertPublicSiteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertPublicSiteRequest call({
    String slug,
    String title,
    String? tagline,
    String? about,
    String? contactWechat,
    String? contactPhone,
    String? themeColor,
    bool? showStats,
    bool? showContact,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpsertPublicSiteRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpsertPublicSiteRequest.copyWith.fieldName(...)`
class _$UpsertPublicSiteRequestCWProxyImpl
    implements _$UpsertPublicSiteRequestCWProxy {
  const _$UpsertPublicSiteRequestCWProxyImpl(this._value);

  final UpsertPublicSiteRequest _value;

  @override
  UpsertPublicSiteRequest slug(String slug) => this(slug: slug);

  @override
  UpsertPublicSiteRequest title(String title) => this(title: title);

  @override
  UpsertPublicSiteRequest tagline(String? tagline) => this(tagline: tagline);

  @override
  UpsertPublicSiteRequest about(String? about) => this(about: about);

  @override
  UpsertPublicSiteRequest contactWechat(String? contactWechat) =>
      this(contactWechat: contactWechat);

  @override
  UpsertPublicSiteRequest contactPhone(String? contactPhone) =>
      this(contactPhone: contactPhone);

  @override
  UpsertPublicSiteRequest themeColor(String? themeColor) =>
      this(themeColor: themeColor);

  @override
  UpsertPublicSiteRequest showStats(bool? showStats) =>
      this(showStats: showStats);

  @override
  UpsertPublicSiteRequest showContact(bool? showContact) =>
      this(showContact: showContact);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertPublicSiteRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertPublicSiteRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertPublicSiteRequest call({
    Object? slug = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? tagline = const $CopyWithPlaceholder(),
    Object? about = const $CopyWithPlaceholder(),
    Object? contactWechat = const $CopyWithPlaceholder(),
    Object? contactPhone = const $CopyWithPlaceholder(),
    Object? themeColor = const $CopyWithPlaceholder(),
    Object? showStats = const $CopyWithPlaceholder(),
    Object? showContact = const $CopyWithPlaceholder(),
  }) {
    return UpsertPublicSiteRequest(
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
      contactWechat: contactWechat == const $CopyWithPlaceholder()
          ? _value.contactWechat
          // ignore: cast_nullable_to_non_nullable
          : contactWechat as String?,
      contactPhone: contactPhone == const $CopyWithPlaceholder()
          ? _value.contactPhone
          // ignore: cast_nullable_to_non_nullable
          : contactPhone as String?,
      themeColor: themeColor == const $CopyWithPlaceholder()
          ? _value.themeColor
          // ignore: cast_nullable_to_non_nullable
          : themeColor as String?,
      showStats: showStats == const $CopyWithPlaceholder()
          ? _value.showStats
          // ignore: cast_nullable_to_non_nullable
          : showStats as bool?,
      showContact: showContact == const $CopyWithPlaceholder()
          ? _value.showContact
          // ignore: cast_nullable_to_non_nullable
          : showContact as bool?,
    );
  }
}

extension $UpsertPublicSiteRequestCopyWith on UpsertPublicSiteRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpsertPublicSiteRequest.copyWith(...)` or like so:`instanceOfUpsertPublicSiteRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpsertPublicSiteRequestCWProxy get copyWith =>
      _$UpsertPublicSiteRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpsertPublicSiteRequest _$UpsertPublicSiteRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'UpsertPublicSiteRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['slug', 'title']);
    final val = UpsertPublicSiteRequest(
      slug: $checkedConvert('slug', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      tagline: $checkedConvert('tagline', (v) => v as String?),
      about: $checkedConvert('about', (v) => v as String?),
      contactWechat: $checkedConvert('contact_wechat', (v) => v as String?),
      contactPhone: $checkedConvert('contact_phone', (v) => v as String?),
      themeColor: $checkedConvert(
        'theme_color',
        (v) => v as String? ?? '#c77852',
      ),
      showStats: $checkedConvert('show_stats', (v) => v as bool? ?? true),
      showContact: $checkedConvert('show_contact', (v) => v as bool? ?? true),
    );
    return val;
  },
  fieldKeyMap: const {
    'contactWechat': 'contact_wechat',
    'contactPhone': 'contact_phone',
    'themeColor': 'theme_color',
    'showStats': 'show_stats',
    'showContact': 'show_contact',
  },
);

Map<String, dynamic> _$UpsertPublicSiteRequestToJson(
  UpsertPublicSiteRequest instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'title': instance.title,
  'tagline': ?instance.tagline,
  'about': ?instance.about,
  'contact_wechat': ?instance.contactWechat,
  'contact_phone': ?instance.contactPhone,
  'theme_color': ?instance.themeColor,
  'show_stats': ?instance.showStats,
  'show_contact': ?instance.showContact,
};
