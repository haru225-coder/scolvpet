// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_template_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentTemplateListResponseCWProxy {
  DocumentTemplateListResponse data(List<DocumentTemplate> data);

  DocumentTemplateListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTemplateListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTemplateListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTemplateListResponse call({
    List<DocumentTemplate> data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentTemplateListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentTemplateListResponse.copyWith.fieldName(...)`
class _$DocumentTemplateListResponseCWProxyImpl
    implements _$DocumentTemplateListResponseCWProxy {
  const _$DocumentTemplateListResponseCWProxyImpl(this._value);

  final DocumentTemplateListResponse _value;

  @override
  DocumentTemplateListResponse data(List<DocumentTemplate> data) =>
      this(data: data);

  @override
  DocumentTemplateListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTemplateListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTemplateListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTemplateListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DocumentTemplateListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<DocumentTemplate>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $DocumentTemplateListResponseCopyWith
    on DocumentTemplateListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentTemplateListResponse.copyWith(...)` or like so:`instanceOfDocumentTemplateListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentTemplateListResponseCWProxy get copyWith =>
      _$DocumentTemplateListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTemplateListResponse _$DocumentTemplateListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentTemplateListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = DocumentTemplateListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => DocumentTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DocumentTemplateListResponseToJson(
  DocumentTemplateListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
