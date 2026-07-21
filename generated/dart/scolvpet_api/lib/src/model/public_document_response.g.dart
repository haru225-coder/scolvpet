// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_document_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicDocumentResponseCWProxy {
  PublicDocumentResponse data(PublicDocumentResponseData data);

  PublicDocumentResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocumentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocumentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocumentResponse call({
    PublicDocumentResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicDocumentResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicDocumentResponse.copyWith.fieldName(...)`
class _$PublicDocumentResponseCWProxyImpl
    implements _$PublicDocumentResponseCWProxy {
  const _$PublicDocumentResponseCWProxyImpl(this._value);

  final PublicDocumentResponse _value;

  @override
  PublicDocumentResponse data(PublicDocumentResponseData data) =>
      this(data: data);

  @override
  PublicDocumentResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicDocumentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicDocumentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicDocumentResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return PublicDocumentResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as PublicDocumentResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $PublicDocumentResponseCopyWith on PublicDocumentResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPublicDocumentResponse.copyWith(...)` or like so:`instanceOfPublicDocumentResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicDocumentResponseCWProxy get copyWith =>
      _$PublicDocumentResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicDocumentResponse _$PublicDocumentResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicDocumentResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = PublicDocumentResponse(
    data: $checkedConvert(
      'data',
      (v) => PublicDocumentResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PublicDocumentResponseToJson(
  PublicDocumentResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
