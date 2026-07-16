// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_template_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportTemplateResponseCWProxy {
  ImportTemplateResponse data(ImportTemplateResponseData data);

  ImportTemplateResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportTemplateResponse call({
    ImportTemplateResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportTemplateResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportTemplateResponse.copyWith.fieldName(...)`
class _$ImportTemplateResponseCWProxyImpl
    implements _$ImportTemplateResponseCWProxy {
  const _$ImportTemplateResponseCWProxyImpl(this._value);

  final ImportTemplateResponse _value;

  @override
  ImportTemplateResponse data(ImportTemplateResponseData data) =>
      this(data: data);

  @override
  ImportTemplateResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportTemplateResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportTemplateResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportTemplateResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ImportTemplateResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ImportTemplateResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ImportTemplateResponseCopyWith on ImportTemplateResponse {
  /// Returns a callable class that can be used as follows: `instanceOfImportTemplateResponse.copyWith(...)` or like so:`instanceOfImportTemplateResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportTemplateResponseCWProxy get copyWith =>
      _$ImportTemplateResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportTemplateResponse _$ImportTemplateResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportTemplateResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ImportTemplateResponse(
    data: $checkedConvert(
      'data',
      (v) => ImportTemplateResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ImportTemplateResponseToJson(
  ImportTemplateResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
