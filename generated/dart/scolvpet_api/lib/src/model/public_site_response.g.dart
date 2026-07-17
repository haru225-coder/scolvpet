// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_site_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicSiteResponseCWProxy {
  PublicSiteResponse data(PublicSite data);

  PublicSiteResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicSiteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicSiteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicSiteResponse call({PublicSite data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicSiteResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicSiteResponse.copyWith.fieldName(...)`
class _$PublicSiteResponseCWProxyImpl implements _$PublicSiteResponseCWProxy {
  const _$PublicSiteResponseCWProxyImpl(this._value);

  final PublicSiteResponse _value;

  @override
  PublicSiteResponse data(PublicSite data) => this(data: data);

  @override
  PublicSiteResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicSiteResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicSiteResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicSiteResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicSiteResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublicSite,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicSiteResponseCopyWith on PublicSiteResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicSiteResponse.copyWith(...)` or like so:`instanceOfPublicSiteResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicSiteResponseCWProxy get copyWith =>
      _$PublicSiteResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicSiteResponse _$PublicSiteResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicSiteResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PublicSiteResponse(
        data: $checkedConvert(
          'data',
          (v) => PublicSite.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PublicSiteResponseToJson(PublicSiteResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
