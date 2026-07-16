// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_batch_create_response_data_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterBatchCreateResponseDataItemsInnerCWProxy {
  HamsterBatchCreateResponseDataItemsInner clientItemId(String clientItemId);

  HamsterBatchCreateResponseDataItemsInner status(BatchItemStatus status);

  HamsterBatchCreateResponseDataItemsInner resource(Hamster? resource);

  HamsterBatchCreateResponseDataItemsInner error(ErrorObject? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateResponseDataItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateResponseDataItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateResponseDataItemsInner call({
    String clientItemId,
    BatchItemStatus status,
    Hamster? resource,
    ErrorObject? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterBatchCreateResponseDataItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterBatchCreateResponseDataItemsInner.copyWith.fieldName(...)`
class _$HamsterBatchCreateResponseDataItemsInnerCWProxyImpl
    implements _$HamsterBatchCreateResponseDataItemsInnerCWProxy {
  const _$HamsterBatchCreateResponseDataItemsInnerCWProxyImpl(this._value);

  final HamsterBatchCreateResponseDataItemsInner _value;

  @override
  HamsterBatchCreateResponseDataItemsInner clientItemId(String clientItemId) =>
      this(clientItemId: clientItemId);

  @override
  HamsterBatchCreateResponseDataItemsInner status(BatchItemStatus status) =>
      this(status: status);

  @override
  HamsterBatchCreateResponseDataItemsInner resource(Hamster? resource) =>
      this(resource: resource);

  @override
  HamsterBatchCreateResponseDataItemsInner error(ErrorObject? error) =>
      this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateResponseDataItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateResponseDataItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateResponseDataItemsInner call({
    Object? clientItemId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? resource = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return HamsterBatchCreateResponseDataItemsInner(
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
          : resource as Hamster?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as ErrorObject?,
    );
  }
}

extension $HamsterBatchCreateResponseDataItemsInnerCopyWith
    on HamsterBatchCreateResponseDataItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterBatchCreateResponseDataItemsInner.copyWith(...)` or like so:`instanceOfHamsterBatchCreateResponseDataItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterBatchCreateResponseDataItemsInnerCWProxy get copyWith =>
      _$HamsterBatchCreateResponseDataItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterBatchCreateResponseDataItemsInner
_$HamsterBatchCreateResponseDataItemsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'HamsterBatchCreateResponseDataItemsInner',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['client_item_id', 'status']);
        final val = HamsterBatchCreateResponseDataItemsInner(
          clientItemId: $checkedConvert('client_item_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$BatchItemStatusEnumMap, v),
          ),
          resource: $checkedConvert(
            'resource',
            (v) =>
                v == null ? null : Hamster.fromJson(v as Map<String, dynamic>),
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
      fieldKeyMap: const {'clientItemId': 'client_item_id'},
    );

Map<String, dynamic> _$HamsterBatchCreateResponseDataItemsInnerToJson(
  HamsterBatchCreateResponseDataItemsInner instance,
) => <String, dynamic>{
  'client_item_id': instance.clientItemId,
  'status': _$BatchItemStatusEnumMap[instance.status]!,
  'resource': ?instance.resource?.toJson(),
  'error': ?instance.error?.toJson(),
};

const _$BatchItemStatusEnumMap = {
  BatchItemStatus.succeeded: 'succeeded',
  BatchItemStatus.failed: 'failed',
  BatchItemStatus.skipped: 'skipped',
  BatchItemStatus.succeededWithWarning: 'succeeded_with_warning',
  BatchItemStatus.succeededWithException: 'succeeded_with_exception',
};
