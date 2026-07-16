// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_batch_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordBatchCreateRequestCWProxy {
  WeightRecordBatchCreateRequest taskId(String? taskId);

  WeightRecordBatchCreateRequest items(
    List<WeightRecordBatchCreateRequestItemsInner> items,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateRequest call({
    String? taskId,
    List<WeightRecordBatchCreateRequestItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordBatchCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordBatchCreateRequest.copyWith.fieldName(...)`
class _$WeightRecordBatchCreateRequestCWProxyImpl
    implements _$WeightRecordBatchCreateRequestCWProxy {
  const _$WeightRecordBatchCreateRequestCWProxyImpl(this._value);

  final WeightRecordBatchCreateRequest _value;

  @override
  WeightRecordBatchCreateRequest taskId(String? taskId) => this(taskId: taskId);

  @override
  WeightRecordBatchCreateRequest items(
    List<WeightRecordBatchCreateRequestItemsInner> items,
  ) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateRequest call({
    Object? taskId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordBatchCreateRequest(
      taskId: taskId == const $CopyWithPlaceholder()
          ? _value.taskId
          // ignore: cast_nullable_to_non_nullable
          : taskId as String?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<WeightRecordBatchCreateRequestItemsInner>,
    );
  }
}

extension $WeightRecordBatchCreateRequestCopyWith
    on WeightRecordBatchCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordBatchCreateRequest.copyWith(...)` or like so:`instanceOfWeightRecordBatchCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordBatchCreateRequestCWProxy get copyWith =>
      _$WeightRecordBatchCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordBatchCreateRequest _$WeightRecordBatchCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WeightRecordBatchCreateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['task_id', 'items']);
  final val = WeightRecordBatchCreateRequest(
    taskId: $checkedConvert('task_id', (v) => v as String?),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => WeightRecordBatchCreateRequestItemsInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'taskId': 'task_id'});

Map<String, dynamic> _$WeightRecordBatchCreateRequestToJson(
  WeightRecordBatchCreateRequest instance,
) => <String, dynamic>{
  'task_id': instance.taskId,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
