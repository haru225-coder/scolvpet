// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_template_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentTemplateResponseCWProxy {
  DocumentTemplateResponse data(DocumentTemplate data);

  DocumentTemplateResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTemplateResponse call({DocumentTemplate data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentTemplateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentTemplateResponse.copyWith.fieldName(...)`
class _$DocumentTemplateResponseCWProxyImpl
    implements _$DocumentTemplateResponseCWProxy {
  const _$DocumentTemplateResponseCWProxyImpl(this._value);

  final DocumentTemplateResponse _value;

  @override
  DocumentTemplateResponse data(DocumentTemplate data) => this(data: data);

  @override
  DocumentTemplateResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTemplateResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DocumentTemplateResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as DocumentTemplate,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $DocumentTemplateResponseCopyWith on DocumentTemplateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentTemplateResponse.copyWith(...)` or like so:`instanceOfDocumentTemplateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentTemplateResponseCWProxy get copyWith =>
      _$DocumentTemplateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTemplateResponse _$DocumentTemplateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DocumentTemplateResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = DocumentTemplateResponse(
    data: $checkedConvert(
      'data',
      (v) => DocumentTemplate.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DocumentTemplateResponseToJson(
  DocumentTemplateResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
