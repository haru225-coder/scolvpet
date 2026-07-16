// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_batch_create_response_data_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordBatchCreateResponseDataItemsInnerCWProxy {
  WeightRecordBatchCreateResponseDataItemsInner clientItemId(
    String clientItemId,
  );

  WeightRecordBatchCreateResponseDataItemsInner status(BatchItemStatus status);

  WeightRecordBatchCreateResponseDataItemsInner resource(
    WeightRecord? resource,
  );

  WeightRecordBatchCreateResponseDataItemsInner generatedTaskId(
    String? generatedTaskId,
  );

  WeightRecordBatchCreateResponseDataItemsInner error(ErrorObject? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateResponseDataItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateResponseDataItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateResponseDataItemsInner call({
    String clientItemId,
    BatchItemStatus status,
    WeightRecord? resource,
    String? generatedTaskId,
    ErrorObject? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordBatchCreateResponseDataItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordBatchCreateResponseDataItemsInner.copyWith.fieldName(...)`
class _$WeightRecordBatchCreateResponseDataItemsInnerCWProxyImpl
    implements _$WeightRecordBatchCreateResponseDataItemsInnerCWProxy {
  const _$WeightRecordBatchCreateResponseDataItemsInnerCWProxyImpl(this._value);

  final WeightRecordBatchCreateResponseDataItemsInner _value;

  @override
  WeightRecordBatchCreateResponseDataItemsInner clientItemId(
    String clientItemId,
  ) => this(clientItemId: clientItemId);

  @override
  WeightRecordBatchCreateResponseDataItemsInner status(
    BatchItemStatus status,
  ) => this(status: status);

  @override
  WeightRecordBatchCreateResponseDataItemsInner resource(
    WeightRecord? resource,
  ) => this(resource: resource);

  @override
  WeightRecordBatchCreateResponseDataItemsInner generatedTaskId(
    String? generatedTaskId,
  ) => this(generatedTaskId: generatedTaskId);

  @override
  WeightRecordBatchCreateResponseDataItemsInner error(ErrorObject? error) =>
      this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateResponseDataItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateResponseDataItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateResponseDataItemsInner call({
    Object? clientItemId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? resource = const $CopyWithPlaceholder(),
    Object? generatedTaskId = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordBatchCreateResponseDataItemsInner(
      clientItemId: clientItemId == const $CopyWithPlaceholder()
          ? _value.clientItemId
          // ignore: cast_nullable_to_non_nullable
          : clientItemId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as BatchItemStatus,
      resource: resource == const $CopyWithPlaceholder()
          ? _value.resource
          // ignore: cast_nullable_to_non_nullable
          : resource as WeightRecord?,
      generatedTaskId: generatedTaskId == const $CopyWithPlaceholder()
          ? _value.generatedTaskId
          // ignore: cast_nullable_to_non_nullable
          : generatedTaskId as String?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as ErrorObject?,
    );
  }
}

extension $WeightRecordBatchCreateResponseDataItemsInnerCopyWith
    on WeightRecordBatchCreateResponseDataItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordBatchCreateResponseDataItemsInner.copyWith(...)` or like so:`instanceOfWeightRecordBatchCreateResponseDataItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordBatchCreateResponseDataItemsInnerCWProxy get copyWith =>
      _$WeightRecordBatchCreateResponseDataItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordBatchCreateResponseDataItemsInner
_$WeightRecordBatchCreateResponseDataItemsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WeightRecordBatchCreateResponseDataItemsInner',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['client_item_id', 'status']);
    final val = WeightRecordBatchCreateResponseDataItemsInner(
      clientItemId: $checkedConvert('client_item_id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$BatchItemStatusEnumMap, v),
      ),
      resource: $checkedConvert(
        'resource',
        (v) =>
            v == null ? null : WeightRecord.fromJson(v as Map<String, dynamic>),
      ),
      generatedTaskId: $checkedConvert(
        'generated_task_id',
        (v) => v as String?,
      ),
      error: $checkedConvert(
        'error',
        (v) =>
            v == null ? null : ErrorObject.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'clientItemId': 'client_item_id',
    'generatedTaskId': 'generated_task_id',
  },
);

Map<String, dynamic> _$WeightRecordBatchCreateResponseDataItemsInnerToJson(
  WeightRecordBatchCreateResponseDataItemsInner instance,
) => <String, dynamic>{
  'client_item_id': instance.clientItemId,
  'status': _$BatchItemStatusEnumMap[instance.status]!,
  'resource': ?instance.resource?.toJson(),
  'generated_task_id': ?instance.generatedTaskId,
  'error': ?instance.error?.toJson(),
};

const _$BatchItemStatusEnumMap = {
  BatchItemStatus.succeeded: 'succeeded',
  BatchItemStatus.failed: 'failed',
  BatchItemStatus.skipped: 'skipped',
  BatchItemStatus.succeededWithWarning: 'succeeded_with_warning',
  BatchItemStatus.succeededWithException: 'succeeded_with_exception',
};
