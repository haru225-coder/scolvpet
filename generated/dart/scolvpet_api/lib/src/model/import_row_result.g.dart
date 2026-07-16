// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_row_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportRowResultCWProxy {
  ImportRowResult rowNumber(int rowNumber);

  ImportRowResult status(ImportRowStatus status);

  ImportRowResult mappedValues(Map<String, Object> mappedValues);

  ImportRowResult resourceId(String? resourceId);

  ImportRowResult issues(List<ImportIssue> issues);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportRowResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportRowResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportRowResult call({
    int rowNumber,
    ImportRowStatus status,
    Map<String, Object> mappedValues,
    String? resourceId,
    List<ImportIssue> issues,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportRowResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportRowResult.copyWith.fieldName(...)`
class _$ImportRowResultCWProxyImpl implements _$ImportRowResultCWProxy {
  const _$ImportRowResultCWProxyImpl(this._value);

  final ImportRowResult _value;

  @override
  ImportRowResult rowNumber(int rowNumber) => this(rowNumber: rowNumber);

  @override
  ImportRowResult status(ImportRowStatus status) => this(status: status);

  @override
  ImportRowResult mappedValues(Map<String, Object> mappedValues) =>
      this(mappedValues: mappedValues);

  @override
  ImportRowResult resourceId(String? resourceId) =>
      this(resourceId: resourceId);

  @override
  ImportRowResult issues(List<ImportIssue> issues) => this(issues: issues);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportRowResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportRowResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportRowResult call({
    Object? rowNumber = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? mappedValues = const $CopyWithPlaceholder(),
    Object? resourceId = const $CopyWithPlaceholder(),
    Object? issues = const $CopyWithPlaceholder(),
  }) {
    return ImportRowResult(
      rowNumber: rowNumber == const $CopyWithPlaceholder()
          ? _value.rowNumber
          // ignore: cast_nullable_to_non_nullable
          : rowNumber as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ImportRowStatus,
      mappedValues: mappedValues == const $CopyWithPlaceholder()
          ? _value.mappedValues
          // ignore: cast_nullable_to_non_nullable
          : mappedValues as Map<String, Object>,
      resourceId: resourceId == const $CopyWithPlaceholder()
          ? _value.resourceId
          // ignore: cast_nullable_to_non_nullable
          : resourceId as String?,
      issues: issues == const $CopyWithPlaceholder()
          ? _value.issues
          // ignore: cast_nullable_to_non_nullable
          : issues as List<ImportIssue>,
    );
  }
}

extension $ImportRowResultCopyWith on ImportRowResult {
  /// Returns a callable class that can be used as follows: `instanceOfImportRowResult.copyWith(...)` or like so:`instanceOfImportRowResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportRowResultCWProxy get copyWith => _$ImportRowResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportRowResult _$ImportRowResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportRowResult',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['row_number', 'status', 'mapped_values', 'issues'],
    );
    final val = ImportRowResult(
      rowNumber: $checkedConvert('row_number', (v) => (v as num).toInt()),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$ImportRowStatusEnumMap, v),
      ),
      mappedValues: $checkedConvert(
        'mapped_values',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
      ),
      resourceId: $checkedConvert('resource_id', (v) => v as String?),
      issues: $checkedConvert(
        'issues',
        (v) => (v as List<dynamic>)
            .map((e) => ImportIssue.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'rowNumber': 'row_number',
    'mappedValues': 'mapped_values',
    'resourceId': 'resource_id',
  },
);

Map<String, dynamic> _$ImportRowResultToJson(ImportRowResult instance) =>
    <String, dynamic>{
      'row_number': instance.rowNumber,
      'status': _$ImportRowStatusEnumMap[instance.status]!,
      'mapped_values': instance.mappedValues,
      'resource_id': ?instance.resourceId,
      'issues': instance.issues.map((e) => e.toJson()).toList(),
    };

const _$ImportRowStatusEnumMap = {
  ImportRowStatus.pending: 'pending',
  ImportRowStatus.valid: 'valid',
  ImportRowStatus.invalid: 'invalid',
  ImportRowStatus.imported: 'imported',
  ImportRowStatus.skipped: 'skipped',
  ImportRowStatus.failed: 'failed',
};
