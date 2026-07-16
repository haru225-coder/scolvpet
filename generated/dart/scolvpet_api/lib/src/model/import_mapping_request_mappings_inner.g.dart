// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_mapping_request_mappings_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportMappingRequestMappingsInnerCWProxy {
  ImportMappingRequestMappingsInner sourceColumn(String sourceColumn);

  ImportMappingRequestMappingsInner targetField(String targetField);

  ImportMappingRequestMappingsInner emptyValuePolicy(
    ImportMappingRequestMappingsInnerEmptyValuePolicyEnum emptyValuePolicy,
  );

  ImportMappingRequestMappingsInner defaultValue(
    ImportTemplateResponseDataColumnsInnerExample? defaultValue,
  );

  ImportMappingRequestMappingsInner formatHint(String? formatHint);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportMappingRequestMappingsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportMappingRequestMappingsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportMappingRequestMappingsInner call({
    String sourceColumn,
    String targetField,
    ImportMappingRequestMappingsInnerEmptyValuePolicyEnum emptyValuePolicy,
    ImportTemplateResponseDataColumnsInnerExample? defaultValue,
    String? formatHint,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportMappingRequestMappingsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportMappingRequestMappingsInner.copyWith.fieldName(...)`
class _$ImportMappingRequestMappingsInnerCWProxyImpl
    implements _$ImportMappingRequestMappingsInnerCWProxy {
  const _$ImportMappingRequestMappingsInnerCWProxyImpl(this._value);

  final ImportMappingRequestMappingsInner _value;

  @override
  ImportMappingRequestMappingsInner sourceColumn(String sourceColumn) =>
      this(sourceColumn: sourceColumn);

  @override
  ImportMappingRequestMappingsInner targetField(String targetField) =>
      this(targetField: targetField);

  @override
  ImportMappingRequestMappingsInner emptyValuePolicy(
    ImportMappingRequestMappingsInnerEmptyValuePolicyEnum emptyValuePolicy,
  ) => this(emptyValuePolicy: emptyValuePolicy);

  @override
  ImportMappingRequestMappingsInner defaultValue(
    ImportTemplateResponseDataColumnsInnerExample? defaultValue,
  ) => this(defaultValue: defaultValue);

  @override
  ImportMappingRequestMappingsInner formatHint(String? formatHint) =>
      this(formatHint: formatHint);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportMappingRequestMappingsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportMappingRequestMappingsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportMappingRequestMappingsInner call({
    Object? sourceColumn = const $CopyWithPlaceholder(),
    Object? targetField = const $CopyWithPlaceholder(),
    Object? emptyValuePolicy = const $CopyWithPlaceholder(),
    Object? defaultValue = const $CopyWithPlaceholder(),
    Object? formatHint = const $CopyWithPlaceholder(),
  }) {
    return ImportMappingRequestMappingsInner(
      sourceColumn: sourceColumn == const $CopyWithPlaceholder()
          ? _value.sourceColumn
          // ignore: cast_nullable_to_non_nullable
          : sourceColumn as String,
      targetField: targetField == const $CopyWithPlaceholder()
          ? _value.targetField
          // ignore: cast_nullable_to_non_nullable
          : targetField as String,
      emptyValuePolicy: emptyValuePolicy == const $CopyWithPlaceholder()
          ? _value.emptyValuePolicy
          // ignore: cast_nullable_to_non_nullable
          : emptyValuePolicy
                as ImportMappingRequestMappingsInnerEmptyValuePolicyEnum,
      defaultValue: defaultValue == const $CopyWithPlaceholder()
          ? _value.defaultValue
          // ignore: cast_nullable_to_non_nullable
          : defaultValue as ImportTemplateResponseDataColumnsInnerExample?,
      formatHint: formatHint == const $CopyWithPlaceholder()
          ? _value.formatHint
          // ignore: cast_nullable_to_non_nullable
          : formatHint as String?,
    );
  }
}

extension $ImportMappingRequestMappingsInnerCopyWith
    on ImportMappingRequestMappingsInner {
  /// Returns a callable class that can be used as follows: `instanceOfImportMappingRequestMappingsInner.copyWith(...)` or like so:`instanceOfImportMappingRequestMappingsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportMappingRequestMappingsInnerCWProxy get copyWith =>
      _$ImportMappingRequestMappingsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportMappingRequestMappingsInner _$ImportMappingRequestMappingsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportMappingRequestMappingsInner',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'source_column',
        'target_field',
        'empty_value_policy',
      ],
    );
    final val = ImportMappingRequestMappingsInner(
      sourceColumn: $checkedConvert('source_column', (v) => v as String),
      targetField: $checkedConvert('target_field', (v) => v as String),
      emptyValuePolicy: $checkedConvert(
        'empty_value_policy',
        (v) => $enumDecode(
          _$ImportMappingRequestMappingsInnerEmptyValuePolicyEnumEnumMap,
          v,
        ),
      ),
      defaultValue: $checkedConvert(
        'default_value',
        (v) => v == null
            ? null
            : ImportTemplateResponseDataColumnsInnerExample.fromJson(
                v as Map<String, dynamic>,
              ),
      ),
      formatHint: $checkedConvert('format_hint', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'sourceColumn': 'source_column',
    'targetField': 'target_field',
    'emptyValuePolicy': 'empty_value_policy',
    'defaultValue': 'default_value',
    'formatHint': 'format_hint',
  },
);

Map<String, dynamic> _$ImportMappingRequestMappingsInnerToJson(
  ImportMappingRequestMappingsInner instance,
) => <String, dynamic>{
  'source_column': instance.sourceColumn,
  'target_field': instance.targetField,
  'empty_value_policy':
      _$ImportMappingRequestMappingsInnerEmptyValuePolicyEnumEnumMap[instance
          .emptyValuePolicy]!,
  'default_value': ?instance.defaultValue?.toJson(),
  'format_hint': ?instance.formatHint,
};

const _$ImportMappingRequestMappingsInnerEmptyValuePolicyEnumEnumMap = {
  ImportMappingRequestMappingsInnerEmptyValuePolicyEnum.keepNull: 'keep_null',
  ImportMappingRequestMappingsInnerEmptyValuePolicyEnum.useDefault:
      'use_default',
  ImportMappingRequestMappingsInnerEmptyValuePolicyEnum.rejectRow: 'reject_row',
};
