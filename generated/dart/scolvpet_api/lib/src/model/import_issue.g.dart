// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_issue.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportIssueCWProxy {
  ImportIssue rowNumber(int rowNumber);

  ImportIssue columnName(String? columnName);

  ImportIssue code(String code);

  ImportIssue message(String message);

  ImportIssue severity(ImportIssueSeverityEnum severity);

  ImportIssue originalValue(
    ImportTemplateResponseDataColumnsInnerExample? originalValue,
  );

  ImportIssue suggestion(String? suggestion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportIssue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportIssue(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportIssue call({
    int rowNumber,
    String? columnName,
    String code,
    String message,
    ImportIssueSeverityEnum severity,
    ImportTemplateResponseDataColumnsInnerExample? originalValue,
    String? suggestion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportIssue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportIssue.copyWith.fieldName(...)`
class _$ImportIssueCWProxyImpl implements _$ImportIssueCWProxy {
  const _$ImportIssueCWProxyImpl(this._value);

  final ImportIssue _value;

  @override
  ImportIssue rowNumber(int rowNumber) => this(rowNumber: rowNumber);

  @override
  ImportIssue columnName(String? columnName) => this(columnName: columnName);

  @override
  ImportIssue code(String code) => this(code: code);

  @override
  ImportIssue message(String message) => this(message: message);

  @override
  ImportIssue severity(ImportIssueSeverityEnum severity) =>
      this(severity: severity);

  @override
  ImportIssue originalValue(
    ImportTemplateResponseDataColumnsInnerExample? originalValue,
  ) => this(originalValue: originalValue);

  @override
  ImportIssue suggestion(String? suggestion) => this(suggestion: suggestion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportIssue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportIssue(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportIssue call({
    Object? rowNumber = const $CopyWithPlaceholder(),
    Object? columnName = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? severity = const $CopyWithPlaceholder(),
    Object? originalValue = const $CopyWithPlaceholder(),
    Object? suggestion = const $CopyWithPlaceholder(),
  }) {
    return ImportIssue(
      rowNumber: rowNumber == const $CopyWithPlaceholder()
          ? _value.rowNumber
          // ignore: cast_nullable_to_non_nullable
          : rowNumber as int,
      columnName: columnName == const $CopyWithPlaceholder()
          ? _value.columnName
          // ignore: cast_nullable_to_non_nullable
          : columnName as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      severity: severity == const $CopyWithPlaceholder()
          ? _value.severity
          // ignore: cast_nullable_to_non_nullable
          : severity as ImportIssueSeverityEnum,
      originalValue: originalValue == const $CopyWithPlaceholder()
          ? _value.originalValue
          // ignore: cast_nullable_to_non_nullable
          : originalValue as ImportTemplateResponseDataColumnsInnerExample?,
      suggestion: suggestion == const $CopyWithPlaceholder()
          ? _value.suggestion
          // ignore: cast_nullable_to_non_nullable
          : suggestion as String?,
    );
  }
}

extension $ImportIssueCopyWith on ImportIssue {
  /// Returns a callable class that can be used as follows: `instanceOfImportIssue.copyWith(...)` or like so:`instanceOfImportIssue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportIssueCWProxy get copyWith => _$ImportIssueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportIssue _$ImportIssueFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ImportIssue',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['row_number', 'code', 'message', 'severity'],
    );
    final val = ImportIssue(
      rowNumber: $checkedConvert('row_number', (v) => (v as num).toInt()),
      columnName: $checkedConvert('column_name', (v) => v as String?),
      code: $checkedConvert('code', (v) => v as String),
      message: $checkedConvert('message', (v) => v as String),
      severity: $checkedConvert(
        'severity',
        (v) => $enumDecode(_$ImportIssueSeverityEnumEnumMap, v),
      ),
      originalValue: $checkedConvert(
        'original_value',
        (v) => v == null
            ? null
            : ImportTemplateResponseDataColumnsInnerExample.fromJson(
                v as Map<String, dynamic>,
              ),
      ),
      suggestion: $checkedConvert('suggestion', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'rowNumber': 'row_number',
    'columnName': 'column_name',
    'originalValue': 'original_value',
  },
);

Map<String, dynamic> _$ImportIssueToJson(ImportIssue instance) =>
    <String, dynamic>{
      'row_number': instance.rowNumber,
      'column_name': ?instance.columnName,
      'code': instance.code,
      'message': instance.message,
      'severity': _$ImportIssueSeverityEnumEnumMap[instance.severity]!,
      'original_value': ?instance.originalValue?.toJson(),
      'suggestion': ?instance.suggestion,
    };

const _$ImportIssueSeverityEnumEnumMap = {
  ImportIssueSeverityEnum.warning: 'warning',
  ImportIssueSeverityEnum.blocking: 'blocking',
};
