// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportJobCreateRequestCWProxy {
  ImportJobCreateRequest uploadId(String uploadId);

  ImportJobCreateRequest templateType(ImportTemplateType templateType);

  ImportJobCreateRequest templateVersion(String templateVersion);

  ImportJobCreateRequest sourceEncoding(
    ImportJobCreateRequestSourceEncodingEnum? sourceEncoding,
  );

  ImportJobCreateRequest timezone(String? timezone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobCreateRequest call({
    String uploadId,
    ImportTemplateType templateType,
    String templateVersion,
    ImportJobCreateRequestSourceEncodingEnum? sourceEncoding,
    String? timezone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportJobCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportJobCreateRequest.copyWith.fieldName(...)`
class _$ImportJobCreateRequestCWProxyImpl
    implements _$ImportJobCreateRequestCWProxy {
  const _$ImportJobCreateRequestCWProxyImpl(this._value);

  final ImportJobCreateRequest _value;

  @override
  ImportJobCreateRequest uploadId(String uploadId) => this(uploadId: uploadId);

  @override
  ImportJobCreateRequest templateType(ImportTemplateType templateType) =>
      this(templateType: templateType);

  @override
  ImportJobCreateRequest templateVersion(String templateVersion) =>
      this(templateVersion: templateVersion);

  @override
  ImportJobCreateRequest sourceEncoding(
    ImportJobCreateRequestSourceEncodingEnum? sourceEncoding,
  ) => this(sourceEncoding: sourceEncoding);

  @override
  ImportJobCreateRequest timezone(String? timezone) => this(timezone: timezone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJobCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJobCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJobCreateRequest call({
    Object? uploadId = const $CopyWithPlaceholder(),
    Object? templateType = const $CopyWithPlaceholder(),
    Object? templateVersion = const $CopyWithPlaceholder(),
    Object? sourceEncoding = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
  }) {
    return ImportJobCreateRequest(
      uploadId: uploadId == const $CopyWithPlaceholder()
          ? _value.uploadId
          // ignore: cast_nullable_to_non_nullable
          : uploadId as String,
      templateType: templateType == const $CopyWithPlaceholder()
          ? _value.templateType
          // ignore: cast_nullable_to_non_nullable
          : templateType as ImportTemplateType,
      templateVersion: templateVersion == const $CopyWithPlaceholder()
          ? _value.templateVersion
          // ignore: cast_nullable_to_non_nullable
          : templateVersion as String,
      sourceEncoding: sourceEncoding == const $CopyWithPlaceholder()
          ? _value.sourceEncoding
          // ignore: cast_nullable_to_non_nullable
          : sourceEncoding as ImportJobCreateRequestSourceEncodingEnum?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
    );
  }
}

extension $ImportJobCreateRequestCopyWith on ImportJobCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfImportJobCreateRequest.copyWith(...)` or like so:`instanceOfImportJobCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportJobCreateRequestCWProxy get copyWith =>
      _$ImportJobCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJobCreateRequest _$ImportJobCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportJobCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['upload_id', 'template_type', 'template_version'],
    );
    final val = ImportJobCreateRequest(
      uploadId: $checkedConvert('upload_id', (v) => v as String),
      templateType: $checkedConvert(
        'template_type',
        (v) => $enumDecode(_$ImportTemplateTypeEnumMap, v),
      ),
      templateVersion: $checkedConvert('template_version', (v) => v as String),
      sourceEncoding: $checkedConvert(
        'source_encoding',
        (v) => $enumDecodeNullable(
          _$ImportJobCreateRequestSourceEncodingEnumEnumMap,
          v,
        ),
      ),
      timezone: $checkedConvert(
        'timezone',
        (v) => v as String? ?? 'Asia/Shanghai',
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'uploadId': 'upload_id',
    'templateType': 'template_type',
    'templateVersion': 'template_version',
    'sourceEncoding': 'source_encoding',
  },
);

Map<String, dynamic> _$ImportJobCreateRequestToJson(
  ImportJobCreateRequest instance,
) => <String, dynamic>{
  'upload_id': instance.uploadId,
  'template_type': _$ImportTemplateTypeEnumMap[instance.templateType]!,
  'template_version': instance.templateVersion,
  'source_encoding':
      ?_$ImportJobCreateRequestSourceEncodingEnumEnumMap[instance
          .sourceEncoding],
  'timezone': ?instance.timezone,
};

const _$ImportTemplateTypeEnumMap = {
  ImportTemplateType.hamster: 'hamster',
  ImportTemplateType.enclosure: 'enclosure',
  ImportTemplateType.weight: 'weight',
};

const _$ImportJobCreateRequestSourceEncodingEnumEnumMap = {
  ImportJobCreateRequestSourceEncodingEnum.utf8: 'utf-8',
  ImportJobCreateRequestSourceEncodingEnum.utf8Bom: 'utf-8-bom',
  ImportJobCreateRequestSourceEncodingEnum.gb18030: 'gb18030',
};
