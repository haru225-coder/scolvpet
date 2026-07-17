// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_site_view_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicSiteViewResponseCWProxy {
  PublicSiteViewResponse data(PublicSiteView data);

  PublicSiteViewResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicSiteViewResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicSiteViewResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicSiteViewResponse call({PublicSiteView data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicSiteViewResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicSiteViewResponse.copyWith.fieldName(...)`
class _$PublicSiteViewResponseCWProxyImpl
    implements _$PublicSiteViewResponseCWProxy {
  const _$PublicSiteViewResponseCWProxyImpl(this._value);

  final PublicSiteViewResponse _value;

  @override
  PublicSiteViewResponse data(PublicSiteView data) => this(data: data);

  @override
  PublicSiteViewResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicSiteViewResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicSiteViewResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicSiteViewResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicSiteViewResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublicSiteView,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicSiteViewResponseCopyWith on PublicSiteViewResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicSiteViewResponse.copyWith(...)` or like so:`instanceOfPublicSiteViewResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicSiteViewResponseCWProxy get copyWith =>
      _$PublicSiteViewResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicSiteViewResponse _$PublicSiteViewResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicSiteViewResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PublicSiteViewResponse(
    data: $checkedConvert(
      'data',
      (v) => PublicSiteView.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PublicSiteViewResponseToJson(
  PublicSiteViewResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
