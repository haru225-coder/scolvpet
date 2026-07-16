// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_commit_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportCommitRequestCWProxy {
  ImportCommitRequest preflightVersion(int preflightVersion);

  ImportCommitRequest batchKey(String batchKey);

  ImportCommitRequest partialFailurePolicy(
    ImportCommitRequestPartialFailurePolicyEnum partialFailurePolicy,
  );

  ImportCommitRequest approvedUpdates(
    Set<ImportCommitRequestApprovedUpdatesInner>? approvedUpdates,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportCommitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportCommitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportCommitRequest call({
    int preflightVersion,
    String batchKey,
    ImportCommitRequestPartialFailurePolicyEnum partialFailurePolicy,
    Set<ImportCommitRequestApprovedUpdatesInner>? approvedUpdates,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportCommitRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportCommitRequest.copyWith.fieldName(...)`
class _$ImportCommitRequestCWProxyImpl implements _$ImportCommitRequestCWProxy {
  const _$ImportCommitRequestCWProxyImpl(this._value);

  final ImportCommitRequest _value;

  @override
  ImportCommitRequest preflightVersion(int preflightVersion) =>
      this(preflightVersion: preflightVersion);

  @override
  ImportCommitRequest batchKey(String batchKey) => this(batchKey: batchKey);

  @override
  ImportCommitRequest partialFailurePolicy(
    ImportCommitRequestPartialFailurePolicyEnum partialFailurePolicy,
  ) => this(partialFailurePolicy: partialFailurePolicy);

  @override
  ImportCommitRequest approvedUpdates(
    Set<ImportCommitRequestApprovedUpdatesInner>? approvedUpdates,
  ) => this(approvedUpdates: approvedUpdates);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportCommitRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportCommitRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportCommitRequest call({
    Object? preflightVersion = const $CopyWithPlaceholder(),
    Object? batchKey = const $CopyWithPlaceholder(),
    Object? partialFailurePolicy = const $CopyWithPlaceholder(),
    Object? approvedUpdates = const $CopyWithPlaceholder(),
  }) {
    return ImportCommitRequest(
      preflightVersion: preflightVersion == const $CopyWithPlaceholder()
          ? _value.preflightVersion
          // ignore: cast_nullable_to_non_nullable
          : preflightVersion as int,
      batchKey: batchKey == const $CopyWithPlaceholder()
          ? _value.batchKey
          // ignore: cast_nullable_to_non_nullable
          : batchKey as String,
      partialFailurePolicy: partialFailurePolicy == const $CopyWithPlaceholder()
          ? _value.partialFailurePolicy
          // ignore: cast_nullable_to_non_nullable
          : partialFailurePolicy as ImportCommitRequestPartialFailurePolicyEnum,
      approvedUpdates: approvedUpdates == const $CopyWithPlaceholder()
          ? _value.approvedUpdates
          // ignore: cast_nullable_to_non_nullable
          : approvedUpdates as Set<ImportCommitRequestApprovedUpdatesInner>?,
    );
  }
}

extension $ImportCommitRequestCopyWith on ImportCommitRequest {
  /// Returns a callable class that can be used as follows: `instanceOfImportCommitRequest.copyWith(...)` or like so:`instanceOfImportCommitRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportCommitRequestCWProxy get copyWith =>
      _$ImportCommitRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportCommitRequest _$ImportCommitRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ImportCommitRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'preflight_version',
            'batch_key',
            'partial_failure_policy',
          ],
        );
        final val = ImportCommitRequest(
          preflightVersion: $checkedConvert(
            'preflight_version',
            (v) => (v as num).toInt(),
          ),
          batchKey: $checkedConvert('batch_key', (v) => v as String),
          partialFailurePolicy: $checkedConvert(
            'partial_failure_policy',
            (v) => $enumDecode(
              _$ImportCommitRequestPartialFailurePolicyEnumEnumMap,
              v,
            ),
          ),
          approvedUpdates: $checkedConvert(
            'approved_updates',
            (v) => (v as List<dynamic>?)
                ?.map(
                  (e) => ImportCommitRequestApprovedUpdatesInner.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toSet(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'preflightVersion': 'preflight_version',
        'batchKey': 'batch_key',
        'partialFailurePolicy': 'partial_failure_policy',
        'approvedUpdates': 'approved_updates',
      },
    );

Map<String, dynamic> _$ImportCommitRequestToJson(
  ImportCommitRequest instance,
) => <String, dynamic>{
  'preflight_version': instance.preflightVersion,
  'batch_key': instance.batchKey,
  'partial_failure_policy':
      _$ImportCommitRequestPartialFailurePolicyEnumEnumMap[instance
          .partialFailurePolicy]!,
  'approved_updates': ?instance.approvedUpdates
      ?.map((e) => e.toJson())
      .toList(),
};

const _$ImportCommitRequestPartialFailurePolicyEnumEnumMap = {
  ImportCommitRequestPartialFailurePolicyEnum.continueAndReport:
      'continue_and_report',
  ImportCommitRequestPartialFailurePolicyEnum.rollbackAll: 'rollback_all',
};
