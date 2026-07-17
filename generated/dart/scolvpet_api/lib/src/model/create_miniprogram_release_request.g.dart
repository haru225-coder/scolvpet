// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_miniprogram_release_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateMiniprogramReleaseRequestCWProxy {
  CreateMiniprogramReleaseRequest versionLabel(String? versionLabel);

  CreateMiniprogramReleaseRequest title(String? title);

  CreateMiniprogramReleaseRequest summary(String? summary);

  CreateMiniprogramReleaseRequest publicSlug(String? publicSlug);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMiniprogramReleaseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMiniprogramReleaseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMiniprogramReleaseRequest call({
    String? versionLabel,
    String? title,
    String? summary,
    String? publicSlug,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateMiniprogramReleaseRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateMiniprogramReleaseRequest.copyWith.fieldName(...)`
class _$CreateMiniprogramReleaseRequestCWProxyImpl
    implements _$CreateMiniprogramReleaseRequestCWProxy {
  const _$CreateMiniprogramReleaseRequestCWProxyImpl(this._value);

  final CreateMiniprogramReleaseRequest _value;

  @override
  CreateMiniprogramReleaseRequest versionLabel(String? versionLabel) =>
      this(versionLabel: versionLabel);

  @override
  CreateMiniprogramReleaseRequest title(String? title) => this(title: title);

  @override
  CreateMiniprogramReleaseRequest summary(String? summary) =>
      this(summary: summary);

  @override
  CreateMiniprogramReleaseRequest publicSlug(String? publicSlug) =>
      this(publicSlug: publicSlug);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMiniprogramReleaseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMiniprogramReleaseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMiniprogramReleaseRequest call({
    Object? versionLabel = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? publicSlug = const $CopyWithPlaceholder(),
  }) {
    return CreateMiniprogramReleaseRequest(
      versionLabel: versionLabel == const $CopyWithPlaceholder()
          ? _value.versionLabel
          // ignore: cast_nullable_to_non_nullable
          : versionLabel as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      publicSlug: publicSlug == const $CopyWithPlaceholder()
          ? _value.publicSlug
          // ignore: cast_nullable_to_non_nullable
          : publicSlug as String?,
    );
  }
}

extension $CreateMiniprogramReleaseRequestCopyWith
    on CreateMiniprogramReleaseRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateMiniprogramReleaseRequest.copyWith(...)` or like so:`instanceOfCreateMiniprogramReleaseRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateMiniprogramReleaseRequestCWProxy get copyWith =>
      _$CreateMiniprogramReleaseRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMiniprogramReleaseRequest _$CreateMiniprogramReleaseRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CreateMiniprogramReleaseRequest',
  json,
  ($checkedConvert) {
    final val = CreateMiniprogramReleaseRequest(
      versionLabel: $checkedConvert('version_label', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      summary: $checkedConvert('summary', (v) => v as String?),
      publicSlug: $checkedConvert('public_slug', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'versionLabel': 'version_label',
    'publicSlug': 'public_slug',
  },
);

Map<String, dynamic> _$CreateMiniprogramReleaseRequestToJson(
  CreateMiniprogramReleaseRequest instance,
) => <String, dynamic>{
  'version_label': ?instance.versionLabel,
  'title': ?instance.title,
  'summary': ?instance.summary,
  'public_slug': ?instance.publicSlug,
};
