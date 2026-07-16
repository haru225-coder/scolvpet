// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_batch_create_request_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterBatchCreateRequestItemsInnerCWProxy {
  HamsterBatchCreateRequestItemsInner clientItemId(String clientItemId);

  HamsterBatchCreateRequestItemsInner hamster(HamsterCreateRequest hamster);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateRequestItemsInner call({
    String clientItemId,
    HamsterCreateRequest hamster,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterBatchCreateRequestItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterBatchCreateRequestItemsInner.copyWith.fieldName(...)`
class _$HamsterBatchCreateRequestItemsInnerCWProxyImpl
    implements _$HamsterBatchCreateRequestItemsInnerCWProxy {
  const _$HamsterBatchCreateRequestItemsInnerCWProxyImpl(this._value);

  final HamsterBatchCreateRequestItemsInner _value;

  @override
  HamsterBatchCreateRequestItemsInner clientItemId(String clientItemId) =>
      this(clientItemId: clientItemId);

  @override
  HamsterBatchCreateRequestItemsInner hamster(HamsterCreateRequest hamster) =>
      this(hamster: hamster);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateRequestItemsInner call({
    Object? clientItemId = const $CopyWithPlaceholder(),
    Object? hamster = const $CopyWithPlaceholder(),
  }) {
    return HamsterBatchCreateRequestItemsInner(
      clientItemId: clientItemId == const $CopyWithPlaceholder()
          ? _value.clientItemId
          // ignore: cast_nullable_to_non_nullable
          : clientItemId as String,
      hamster: hamster == const $CopyWithPlaceholder()
          ? _value.hamster
          // ignore: cast_nullable_to_non_nullable
          : hamster as HamsterCreateRequest,
    );
  }
}

extension $HamsterBatchCreateRequestItemsInnerCopyWith
    on HamsterBatchCreateRequestItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterBatchCreateRequestItemsInner.copyWith(...)` or like so:`instanceOfHamsterBatchCreateRequestItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterBatchCreateRequestItemsInnerCWProxy get copyWith =>
      _$HamsterBatchCreateRequestItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterBatchCreateRequestItemsInner
_$HamsterBatchCreateRequestItemsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'HamsterBatchCreateRequestItemsInner',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['client_item_id', 'hamster']);
        final val = HamsterBatchCreateRequestItemsInner(
          clientItemId: $checkedConvert('client_item_id', (v) => v as String),
          hamster: $checkedConvert(
            'hamster',
            (v) => HamsterCreateRequest.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'clientItemId': 'client_item_id'},
    );

Map<String, dynamic> _$HamsterBatchCreateRequestItemsInnerToJson(
  HamsterBatchCreateRequestItemsInner instance,
) => <String, dynamic>{
  'client_item_id': instance.clientItemId,
  'hamster': instance.hamster.toJson(),
};
