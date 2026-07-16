// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CompleteTaskResponseDataCWProxy {
  CompleteTaskResponseData task(CareTask task);

  CompleteTaskResponseData itemResults(
    List<CompleteTaskResponseDataItemResultsInner> itemResults,
  );

  CompleteTaskResponseData autoClosed(bool autoClosed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskResponseData call({
    CareTask task,
    List<CompleteTaskResponseDataItemResultsInner> itemResults,
    bool autoClosed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCompleteTaskResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCompleteTaskResponseData.copyWith.fieldName(...)`
class _$CompleteTaskResponseDataCWProxyImpl
    implements _$CompleteTaskResponseDataCWProxy {
  const _$CompleteTaskResponseDataCWProxyImpl(this._value);

  final CompleteTaskResponseData _value;

  @override
  CompleteTaskResponseData task(CareTask task) => this(task: task);

  @override
  CompleteTaskResponseData itemResults(
    List<CompleteTaskResponseDataItemResultsInner> itemResults,
  ) => this(itemResults: itemResults);

  @override
  CompleteTaskResponseData autoClosed(bool autoClosed) =>
      this(autoClosed: autoClosed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CompleteTaskResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CompleteTaskResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CompleteTaskResponseData call({
    Object? task = const $CopyWithPlaceholder(),
    Object? itemResults = const $CopyWithPlaceholder(),
    Object? autoClosed = const $CopyWithPlaceholder(),
  }) {
    return CompleteTaskResponseData(
      task: task == const $CopyWithPlaceholder()
          ? _value.task
          // ignore: cast_nullable_to_non_nullable
          : task as CareTask,
      itemResults: itemResults == const $CopyWithPlaceholder()
          ? _value.itemResults
          // ignore: cast_nullable_to_non_nullable
          : itemResults as List<CompleteTaskResponseDataItemResultsInner>,
      autoClosed: autoClosed == const $CopyWithPlaceholder()
          ? _value.autoClosed
          // ignore: cast_nullable_to_non_nullable
          : autoClosed as bool,
    );
  }
}

extension $CompleteTaskResponseDataCopyWith on CompleteTaskResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfCompleteTaskResponseData.copyWith(...)` or like so:`instanceOfCompleteTaskResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CompleteTaskResponseDataCWProxy get copyWith =>
      _$CompleteTaskResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTaskResponseData _$CompleteTaskResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CompleteTaskResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['task', 'item_results', 'auto_closed'],
    );
    final val = CompleteTaskResponseData(
      task: $checkedConvert(
        'task',
        (v) => CareTask.fromJson(v as Map<String, dynamic>),
      ),
      itemResults: $checkedConvert(
        'item_results',
        (v) => (v as List<dynamic>)
            .map(
              (e) => CompleteTaskResponseDataItemResultsInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      autoClosed: $checkedConvert('auto_closed', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {
    'itemResults': 'item_results',
    'autoClosed': 'auto_closed',
  },
);

Map<String, dynamic> _$CompleteTaskResponseDataToJson(
  CompleteTaskResponseData instance,
) => <String, dynamic>{
  'task': instance.task.toJson(),
  'item_results': instance.itemResults.map((e) => e.toJson()).toList(),
  'auto_closed': instance.autoClosed,
};
