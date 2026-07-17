// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentListResponseCWProxy {
  DocumentListResponse data(List<Document> data);

  DocumentListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentListResponse call({List<Document> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentListResponse.copyWith.fieldName(...)`
class _$DocumentListResponseCWProxyImpl
    implements _$DocumentListResponseCWProxy {
  const _$DocumentListResponseCWProxyImpl(this._value);

  final DocumentListResponse _value;

  @override
  DocumentListResponse data(List<Document> data) => this(data: data);

  @override
  DocumentListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DocumentListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Document>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $DocumentListResponseCopyWith on DocumentListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentListResponse.copyWith(...)` or like so:`instanceOfDocumentListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentListResponseCWProxy get copyWith =>
      _$DocumentListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentListResponse _$DocumentListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = DocumentListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DocumentListResponseToJson(
  DocumentListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
