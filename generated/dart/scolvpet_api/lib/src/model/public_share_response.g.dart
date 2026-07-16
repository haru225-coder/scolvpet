// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_share_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicShareResponseCWProxy {
  PublicShareResponse data(PublicShareResponseData data);

  PublicShareResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicShareResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicShareResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicShareResponse call({PublicShareResponseData data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicShareResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicShareResponse.copyWith.fieldName(...)`
class _$PublicShareResponseCWProxyImpl implements _$PublicShareResponseCWProxy {
  const _$PublicShareResponseCWProxyImpl(this._value);

  final PublicShareResponse _value;

  @override
  PublicShareResponse data(PublicShareResponseData data) => this(data: data);

  @override
  PublicShareResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicShareResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicShareResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicShareResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicShareResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublicShareResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicShareResponseCopyWith on PublicShareResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicShareResponse.copyWith(...)` or like so:`instanceOfPublicShareResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicShareResponseCWProxy get copyWith =>
      _$PublicShareResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicShareResponse _$PublicShareResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicShareResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = PublicShareResponse(
        data: $checkedConvert(
          'data',
          (v) => PublicShareResponseData.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PublicShareResponseToJson(
  PublicShareResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
