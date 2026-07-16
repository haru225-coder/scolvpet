// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task_request_subject_results_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteTaskRequestSubjectResultsInnerCWProxy {
  CompleteTaskRequestSubjectResultsInner subjectId(String subjectId);

  CompleteTaskRequestSubjectResultsInner status(
    CompleteTaskRequestSubjectResultsInnerStatusEnum status,
  );

  CompleteTaskRequestSubjectResultsInner completionRecordId(
    String? completionRecordId,
  );

  CompleteTaskRequestSubjectResultsInner exceptionReason(
    String? exceptionReason,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskRequestSubjectResultsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskRequestSubjectResultsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskRequestSubjectResultsInner call({
    String subjectId,
    CompleteTaskRequestSubjectResultsInnerStatusEnum status,
    String? completionRecordId,
    String? exceptionReason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteTaskRequestSubjectResultsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteTaskRequestSubjectResultsInner.copyWith.fieldName(...)`
class _$CompleteTaskRequestSubjectResultsInnerCWProxyImpl
    implements _$CompleteTaskRequestSubjectResultsInnerCWProxy {
  const _$CompleteTaskRequestSubjectResultsInnerCWProxyImpl(this._value);

  final CompleteTaskRequestSubjectResultsInner _value;

  @override
  CompleteTaskRequestSubjectResultsInner subjectId(String subjectId) =>
      this(subjectId: subjectId);

  @override
  CompleteTaskRequestSubjectResultsInner status(
    CompleteTaskRequestSubjectResultsInnerStatusEnum status,
  ) => this(status: status);

  @override
  CompleteTaskRequestSubjectResultsInner completionRecordId(
    String? completionRecordId,
  ) => this(completionRecordId: completionRecordId);

  @override
  CompleteTaskRequestSubjectResultsInner exceptionReason(
    String? exceptionReason,
  ) => this(exceptionReason: exceptionReason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskRequestSubjectResultsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskRequestSubjectResultsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskRequestSubjectResultsInner call({
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? completionRecordId = const $CopyWithPlaceholder(),
    Object? exceptionReason = const $CopyWithPlaceholder(),
  }) {
    return CompleteTaskRequestSubjectResultsInner(
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CompleteTaskRequestSubjectResultsInnerStatusEnum,
      completionRecordId: completionRecordId == const $CopyWithPlaceholder()
          ? _value.completionRecordId
          // ignore: cast_nullable_to_non_nullable
          : completionRecordId as String?,
      exceptionReason: exceptionReason == const $CopyWithPlaceholder()
          ? _value.exceptionReason
          // ignore: cast_nullable_to_non_nullable
          : exceptionReason as String?,
    );
  }
}

extension $CompleteTaskRequestSubjectResultsInnerCopyWith
    on CompleteTaskRequestSubjectResultsInner {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteTaskRequestSubjectResultsInner.copyWith(...)` or like so:`instanceOfCompleteTaskRequestSubjectResultsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteTaskRequestSubjectResultsInnerCWProxy get copyWith =>
      _$CompleteTaskRequestSubjectResultsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTaskRequestSubjectResultsInner
_$CompleteTaskRequestSubjectResultsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CompleteTaskRequestSubjectResultsInner',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['subject_id', 'status']);
        final val = CompleteTaskRequestSubjectResultsInner(
          subjectId: $checkedConvert('subject_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(
              _$CompleteTaskRequestSubjectResultsInnerStatusEnumEnumMap,
              v,
            ),
          ),
          completionRecordId: $checkedConvert(
            'completion_record_id',
            (v) => v as String?,
          ),
          exceptionReason: $checkedConvert(
            'exception_reason',
            (v) => v as String?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'subjectId': 'subject_id',
        'completionRecordId': 'completion_record_id',
        'exceptionReason': 'exception_reason',
      },
    );

Map<String, dynamic> _$CompleteTaskRequestSubjectResultsInnerToJson(
  CompleteTaskRequestSubjectResultsInner instance,
) => <String, dynamic>{
  'subject_id': instance.subjectId,
  'status':
      _$CompleteTaskRequestSubjectResultsInnerStatusEnumEnumMap[instance
          .status]!,
  'completion_record_id': ?instance.completionRecordId,
  'exception_reason': ?instance.exceptionReason,
};

const _$CompleteTaskRequestSubjectResultsInnerStatusEnumEnumMap = {
  CompleteTaskRequestSubjectResultsInnerStatusEnum.completed: 'completed',
  CompleteTaskRequestSubjectResultsInnerStatusEnum.excepted: 'excepted',
};
