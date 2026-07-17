// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentResponseCWProxy {
  DocumentResponse data(Document data);

  DocumentResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentResponse call({Document data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentResponse.copyWith.fieldName(...)`
class _$DocumentResponseCWProxyImpl implements _$DocumentResponseCWProxy {
  const _$DocumentResponseCWProxyImpl(this._value);

  final DocumentResponse _value;

  @override
  DocumentResponse data(Document data) => this(data: data);

  @override
  DocumentResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DocumentResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Document,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $DocumentResponseCopyWith on DocumentResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentResponse.copyWith(...)` or like so:`instanceOfDocumentResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentResponseCWProxy get copyWith => _$DocumentResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentResponse _$DocumentResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = DocumentResponse(
        data: $checkedConvert(
          'data',
          (v) => Document.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DocumentResponseToJson(DocumentResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
