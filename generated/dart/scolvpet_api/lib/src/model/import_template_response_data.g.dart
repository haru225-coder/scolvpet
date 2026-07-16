// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_template_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportTemplateResponseDataCWProxy {
  ImportTemplateResponseData templateType(ImportTemplateType templateType);

  ImportTemplateResponseData version(String version);

  ImportTemplateResponseData downloadUrl(String downloadUrl);

  ImportTemplateResponseData expiresAt(DateTime expiresAt);

  ImportTemplateResponseData columns(
    List<ImportTemplateResponseDataColumnsInner> columns,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportTemplateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportTemplateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportTemplateResponseData call({
    ImportTemplateType templateType,
    String version,
    String downloadUrl,
    DateTime expiresAt,
    List<ImportTemplateResponseDataColumnsInner> columns,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportTemplateResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportTemplateResponseData.copyWith.fieldName(...)`
class _$ImportTemplateResponseDataCWProxyImpl
    implements _$ImportTemplateResponseDataCWProxy {
  const _$ImportTemplateResponseDataCWProxyImpl(this._value);

  final ImportTemplateResponseData _value;

  @override
  ImportTemplateResponseData templateType(ImportTemplateType templateType) =>
      this(templateType: templateType);

  @override
  ImportTemplateResponseData version(String version) => this(version: version);

  @override
  ImportTemplateResponseData downloadUrl(String downloadUrl) =>
      this(downloadUrl: downloadUrl);

  @override
  ImportTemplateResponseData expiresAt(DateTime expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  ImportTemplateResponseData columns(
    List<ImportTemplateResponseDataColumnsInner> columns,
  ) => this(columns: columns);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportTemplateResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportTemplateResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportTemplateResponseData call({
    Object? templateType = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? downloadUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? columns = const $CopyWithPlaceholder(),
  }) {
    return ImportTemplateResponseData(
      templateType: templateType == const $CopyWithPlaceholder()
          ? _value.templateType
          // ignore: cast_nullable_to_non_nullable
          : templateType as ImportTemplateType,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
      downloadUrl: downloadUrl == const $CopyWithPlaceholder()
          ? _value.downloadUrl
          // ignore: cast_nullable_to_non_nullable
          : downloadUrl as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      columns: columns == const $CopyWithPlaceholder()
          ? _value.columns
          // ignore: cast_nullable_to_non_nullable
          : columns as List<ImportTemplateResponseDataColumnsInner>,
    );
  }
}

extension $ImportTemplateResponseDataCopyWith on ImportTemplateResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfImportTemplateResponseData.copyWith(...)` or like so:`instanceOfImportTemplateResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportTemplateResponseDataCWProxy get copyWith =>
      _$ImportTemplateResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportTemplateResponseData _$ImportTemplateResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportTemplateResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'template_type',
        'version',
        'download_url',
        'expires_at',
        'columns',
      ],
    );
    final val = ImportTemplateResponseData(
      templateType: $checkedConvert(
        'template_type',
        (v) => $enumDecode(_$ImportTemplateTypeEnumMap, v),
      ),
      version: $checkedConvert('version', (v) => v as String),
      downloadUrl: $checkedConvert('download_url', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
      columns: $checkedConvert(
        'columns',
        (v) => (v as List<dynamic>)
            .map(
              (e) => ImportTemplateResponseDataColumnsInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'templateType': 'template_type',
    'downloadUrl': 'download_url',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$ImportTemplateResponseDataToJson(
  ImportTemplateResponseData instance,
) => <String, dynamic>{
  'template_type': _$ImportTemplateTypeEnumMap[instance.templateType]!,
  'version': instance.version,
  'download_url': instance.downloadUrl,
  'expires_at': instance.expiresAt.toIso8601String(),
  'columns': instance.columns.map((e) => e.toJson()).toList(),
};

const _$ImportTemplateTypeEnumMap = {
  ImportTemplateType.hamster: 'hamster',
  ImportTemplateType.enclosure: 'enclosure',
  ImportTemplateType.weight: 'weight',
};
