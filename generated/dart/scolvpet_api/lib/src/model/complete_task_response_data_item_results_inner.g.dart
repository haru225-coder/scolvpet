// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task_response_data_item_results_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteTaskResponseDataItemResultsInnerCWProxy {
  CompleteTaskResponseDataItemResultsInner subjectId(String subjectId);

  CompleteTaskResponseDataItemResultsInner status(BatchItemStatus status);

  CompleteTaskResponseDataItemResultsInner completionRecordId(
    String? completionRecordId,
  );

  CompleteTaskResponseDataItemResultsInner error(ErrorObject? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskResponseDataItemResultsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskResponseDataItemResultsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskResponseDataItemResultsInner call({
    String subjectId,
    BatchItemStatus status,
    String? completionRecordId,
    ErrorObject? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteTaskResponseDataItemResultsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteTaskResponseDataItemResultsInner.copyWith.fieldName(...)`
class _$CompleteTaskResponseDataItemResultsInnerCWProxyImpl
    implements _$CompleteTaskResponseDataItemResultsInnerCWProxy {
  const _$CompleteTaskResponseDataItemResultsInnerCWProxyImpl(this._value);

  final CompleteTaskResponseDataItemResultsInner _value;

  @override
  CompleteTaskResponseDataItemResultsInner subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  CompleteTaskResponseDataItemResultsInner status(BatchItemStatus status) =>
      this(status: status);

  @override
  CompleteTaskResponseDataItemResultsInner completionRecordId(
    String? completionRecordId,
  ) => this(completionRecordId: completionRecordId);

  @override
  CompleteTaskResponseDataItemResultsInner error(ErrorObject? error) =>
      this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskResponseDataItemResultsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskResponseDataItemResultsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskResponseDataItemResultsInner call({
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? completionRecordId = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return CompleteTaskResponseDataItemResultsInner(
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as BatchItemStatus,
      completionRecordId: completionRecordId == const $CopyWithPlaceholder()
          ? _value.completionRecordId
          // ignore: cast_nullable_to_non_nullable
          : completionRecordId as String?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as ErrorObject?,
    );
  }
}

extension $CompleteTaskResponseDataItemResultsInnerCopyWith
    on CompleteTaskResponseDataItemResultsInner {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteTaskResponseDataItemResultsInner.copyWith(...)` or like so:`instanceOfCompleteTaskResponseDataItemResultsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteTaskResponseDataItemResultsInnerCWProxy get copyWith =>
      _$CompleteTaskResponseDataItemResultsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTaskResponseDataItemResultsInner
_$CompleteTaskResponseDataItemResultsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CompleteTaskResponseDataItemResultsInner',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['subject_id', 'status']);
        final val = CompleteTaskResponseDataItemResultsInner(
          subjectId: $checkedConvert('subject_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$BatchItemStatusEnumMap, v),
          ),
          completionRecordId: $checkedConvert(
            'completion_record_id',
            (v) => v as String?,
          ),
          error: $checkedConvert(
            'error',
            (v) => v == null
                ? null
                : ErrorObject.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'subjectId': 'subject_id',
        'completionRecordId': 'completion_record_id',
      },
    );

Map<String, dynamic> _$CompleteTaskResponseDataItemResultsInnerToJson(
  CompleteTaskResponseDataItemResultsInner instance,
) => <String, dynamic>{
  'subject_id': instance.subjectId,
  'status': _$BatchItemStatusEnumMap[instance.status]!,
  'completion_record_id': ?instance.completionRecordId,
  'error': ?instance.error?.toJson(),
};

const _$BatchItemStatusEnumMap = {
  BatchItemStatus.succeeded: 'succeeded',
  BatchItemStatus.failed: 'failed',
  BatchItemStatus.skipped: 'skipped',
  BatchItemStatus.succeededWithWarning: 'succeeded_with_warning',
  BatchItemStatus.succeededWithException: 'succeeded_with_exception',
};
