// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_batch_create_request_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordBatchCreateRequestItemsInnerCWProxy {
  WeightRecordBatchCreateRequestItemsInner clientItemId(String clientItemId);

  WeightRecordBatchCreateRequestItemsInner record(
    WeightRecordCreateRequest record,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateRequestItemsInner call({
    String clientItemId,
    WeightRecordCreateRequest record,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordBatchCreateRequestItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordBatchCreateRequestItemsInner.copyWith.fieldName(...)`
class _$WeightRecordBatchCreateRequestItemsInnerCWProxyImpl
    implements _$WeightRecordBatchCreateRequestItemsInnerCWProxy {
  const _$WeightRecordBatchCreateRequestItemsInnerCWProxyImpl(this._value);

  final WeightRecordBatchCreateRequestItemsInner _value;

  @override
  WeightRecordBatchCreateRequestItemsInner clientItemId(String clientItemId) =>
      this(clientItemId: clientItemId);

  @override
  WeightRecordBatchCreateRequestItemsInner record(
    WeightRecordCreateRequest record,
  ) => this(record: record);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordBatchCreateRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordBatchCreateRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordBatchCreateRequestItemsInner call({
    Object? clientItemId = const $CopyWithPlaceholder(),
    Object? record = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordBatchCreateRequestItemsInner(
      clientItemId: clientItemId == const $CopyWithPlaceholder()
          ? _value.clientItemId
          // ignore: cast_nullable_to_non_nullable
          : clientItemId as String,
      record: record == const $CopyWithPlaceholder()
          ? _value.record
          // ignore: cast_nullable_to_non_nullable
          : record as WeightRecordCreateRequest,
    );
  }
}

extension $WeightRecordBatchCreateRequestItemsInnerCopyWith
    on WeightRecordBatchCreateRequestItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordBatchCreateRequestItemsInner.copyWith(...)` or like so:`instanceOfWeightRecordBatchCreateRequestItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordBatchCreateRequestItemsInnerCWProxy get copyWith =>
      _$WeightRecordBatchCreateRequestItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordBatchCreateRequestItemsInner
_$WeightRecordBatchCreateRequestItemsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeightRecordBatchCreateRequestItemsInner',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['client_item_id', 'record']);
        final val = WeightRecordBatchCreateRequestItemsInner(
          clientItemId: $checkedConvert('client_item_id', (v) => v as String),
          record: $checkedConvert(
            'record',
            (v) =>
                WeightRecordCreateRequest.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'clientItemId': 'client_item_id'},
    );

Map<String, dynamic> _$WeightRecordBatchCreateRequestItemsInnerToJson(
  WeightRecordBatchCreateRequestItemsInner instance,
) => <String, dynamic>{
  'client_item_id': instance.clientItemId,
  'record': instance.record.toJson(),
};
