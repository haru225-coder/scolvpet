// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_commit_request_approved_updates_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportCommitRequestApprovedUpdatesInnerCWProxy {
  ImportCommitRequestApprovedUpdatesInner rowNumber(int rowNumber);

  ImportCommitRequestApprovedUpdatesInner resourceId(String resourceId);

  ImportCommitRequestApprovedUpdatesInner expectedVersion(int expectedVersion);

  ImportCommitRequestApprovedUpdatesInner fields(Set<String> fields);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportCommitRequestApprovedUpdatesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportCommitRequestApprovedUpdatesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportCommitRequestApprovedUpdatesInner call({
    int rowNumber,
    String resourceId,
    int expectedVersion,
    Set<String> fields,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportCommitRequestApprovedUpdatesInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportCommitRequestApprovedUpdatesInner.copyWith.fieldName(...)`
class _$ImportCommitRequestApprovedUpdatesInnerCWProxyImpl
    implements _$ImportCommitRequestApprovedUpdatesInnerCWProxy {
  const _$ImportCommitRequestApprovedUpdatesInnerCWProxyImpl(this._value);

  final ImportCommitRequestApprovedUpdatesInner _value;

  @override
  ImportCommitRequestApprovedUpdatesInner rowNumber(int rowNumber) =>
      this(rowNumber: rowNumber);

  @override
  ImportCommitRequestApprovedUpdatesInner resourceId(String resourceId) =>
      this(resourceId: resourceId);

  @override
  ImportCommitRequestApprovedUpdatesInner expectedVersion(
    int expectedVersion,
  ) => this(expectedVersion: expectedVersion);

  @override
  ImportCommitRequestApprovedUpdatesInner fields(Set<String> fields) =>
      this(fields: fields);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportCommitRequestApprovedUpdatesInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportCommitRequestApprovedUpdatesInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportCommitRequestApprovedUpdatesInner call({
    Object? rowNumber = const $CopyWithPlaceholder(),
    Object? resourceId = const $CopyWithPlaceholder(),
    Object? expectedVersion = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
  }) {
    return ImportCommitRequestApprovedUpdatesInner(
      rowNumber: rowNumber == const $CopyWithPlaceholder()
          ? _value.rowNumber
          // ignore: cast_nullable_to_non_nullable
          : rowNumber as int,
      resourceId: resourceId == const $CopyWithPlaceholder()
          ? _value.resourceId
          // ignore: cast_nullable_to_non_nullable
          : resourceId as String,
      expectedVersion: expectedVersion == const $CopyWithPlaceholder()
          ? _value.expectedVersion
          // ignore: cast_nullable_to_non_nullable
          : expectedVersion as int,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as Set<String>,
    );
  }
}

extension $ImportCommitRequestApprovedUpdatesInnerCopyWith
    on ImportCommitRequestApprovedUpdatesInner {
  /// Returns a callable class that can be used as follows: `instanceOfImportCommitRequestApprovedUpdatesInner.copyWith(...)` or like so:`instanceOfImportCommitRequestApprovedUpdatesInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportCommitRequestApprovedUpdatesInnerCWProxy get copyWith =>
      _$ImportCommitRequestApprovedUpdatesInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportCommitRequestApprovedUpdatesInner
_$ImportCommitRequestApprovedUpdatesInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ImportCommitRequestApprovedUpdatesInner',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'row_number',
            'resource_id',
            'expected_version',
            'fields',
          ],
        );
        final val = ImportCommitRequestApprovedUpdatesInner(
          rowNumber: $checkedConvert('row_number', (v) => (v as num).toInt()),
          resourceId: $checkedConvert('resource_id', (v) => v as String),
          expectedVersion: $checkedConvert(
            'expected_version',
            (v) => (v as num).toInt(),
          ),
          fields: $checkedConvert(
            'fields',
            (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'rowNumber': 'row_number',
        'resourceId': 'resource_id',
        'expectedVersion': 'expected_version',
      },
    );

Map<String, dynamic> _$ImportCommitRequestApprovedUpdatesInnerToJson(
  ImportCommitRequestApprovedUpdatesInner instance,
) => <String, dynamic>{
  'row_number': instance.rowNumber,
  'resource_id': instance.resourceId,
  'expected_version': instance.expectedVersion,
  'fields': instance.fields.toList(),
};
