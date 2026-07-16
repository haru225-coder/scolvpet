// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteTaskRequestCWProxy {
  CompleteTaskRequest completedAt(DateTime completedAt);

  CompleteTaskRequest subjectResults(
    List<CompleteTaskRequestSubjectResultsInner> subjectResults,
  );

  CompleteTaskRequest notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskRequest call({
    DateTime completedAt,
    List<CompleteTaskRequestSubjectResultsInner> subjectResults,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteTaskRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteTaskRequest.copyWith.fieldName(...)`
class _$CompleteTaskRequestCWProxyImpl implements _$CompleteTaskRequestCWProxy {
  const _$CompleteTaskRequestCWProxyImpl(this._value);

  final CompleteTaskRequest _value;

  @override
  CompleteTaskRequest completedAt(DateTime completedAt) =>
      this(completedAt: completedAt);

  @override
  CompleteTaskRequest subjectResults(
    List<CompleteTaskRequestSubjectResultsInner> subjectResults,
  ) => this(subjectResults: subjectResults);

  @override
  CompleteTaskRequest notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskRequest call({
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? subjectResults = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return CompleteTaskRequest(
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime,
      subjectResults: subjectResults == const $CopyWithPlaceholder()
          ? _value.subjectResults
          // ignore: cast_nullable_to_non_nullable
          : subjectResults as List<CompleteTaskRequestSubjectResultsInner>,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $CompleteTaskRequestCopyWith on CompleteTaskRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteTaskRequest.copyWith(...)` or like so:`instanceOfCompleteTaskRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteTaskRequestCWProxy get copyWith =>
      _$CompleteTaskRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTaskRequest _$CompleteTaskRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CompleteTaskRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['completed_at', 'subject_results'],
        );
        final val = CompleteTaskRequest(
          completedAt: $checkedConvert(
            'completed_at',
            (v) => DateTime.parse(v as String),
          ),
          subjectResults: $checkedConvert(
            'subject_results',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => CompleteTaskRequestSubjectResultsInner.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
          notes: $checkedConvert('notes', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'completedAt': 'completed_at',
        'subjectResults': 'subject_results',
      },
    );

Map<String, dynamic> _$CompleteTaskRequestToJson(
  CompleteTaskRequest instance,
) => <String, dynamic>{
  'completed_at': instance.completedAt.toIso8601String(),
  'subject_results': instance.subjectResults.map((e) => e.toJson()).toList(),
  'notes': ?instance.notes,
};
