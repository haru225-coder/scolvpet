// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_page_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SharePageResponseCWProxy {
  SharePageResponse data(SharePage data);

  SharePageResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharePageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharePageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SharePageResponse call({SharePage data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSharePageResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSharePageResponse.copyWith.fieldName(...)`
class _$SharePageResponseCWProxyImpl implements _$SharePageResponseCWProxy {
  const _$SharePageResponseCWProxyImpl(this._value);

  final SharePageResponse _value;

  @override
  SharePageResponse data(SharePage data) => this(data: data);

  @override
  SharePageResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharePageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharePageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SharePageResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SharePageResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as SharePage,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $SharePageResponseCopyWith on SharePageResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSharePageResponse.copyWith(...)` or like so:`instanceOfSharePageResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SharePageResponseCWProxy get copyWith =>
      _$SharePageResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharePageResponse _$SharePageResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SharePageResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = SharePageResponse(
        data: $checkedConvert(
          'data',
          (v) => SharePage.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SharePageResponseToJson(SharePageResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
