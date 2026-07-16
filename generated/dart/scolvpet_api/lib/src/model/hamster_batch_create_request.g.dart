// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hamster_batch_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HamsterBatchCreateRequestCWProxy {
  HamsterBatchCreateRequest atomic(bool atomic);

  HamsterBatchCreateRequest items(
    List<HamsterBatchCreateRequestItemsInner> items,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateRequest call({
    bool atomic,
    List<HamsterBatchCreateRequestItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHamsterBatchCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHamsterBatchCreateRequest.copyWith.fieldName(...)`
class _$HamsterBatchCreateRequestCWProxyImpl
    implements _$HamsterBatchCreateRequestCWProxy {
  const _$HamsterBatchCreateRequestCWProxyImpl(this._value);

  final HamsterBatchCreateRequest _value;

  @override
  HamsterBatchCreateRequest atomic(bool atomic) => this(atomic: atomic);

  @override
  HamsterBatchCreateRequest items(
    List<HamsterBatchCreateRequestItemsInner> items,
  ) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HamsterBatchCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HamsterBatchCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  HamsterBatchCreateRequest call({
    Object? atomic = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return HamsterBatchCreateRequest(
      atomic: atomic == const $CopyWithPlaceholder()
          ? _value.atomic
          // ignore: cast_nullable_to_non_nullable
          : atomic as bool,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<HamsterBatchCreateRequestItemsInner>,
    );
  }
}

extension $HamsterBatchCreateRequestCopyWith on HamsterBatchCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfHamsterBatchCreateRequest.copyWith(...)` or like so:`instanceOfHamsterBatchCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HamsterBatchCreateRequestCWProxy get copyWith =>
      _$HamsterBatchCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HamsterBatchCreateRequest _$HamsterBatchCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HamsterBatchCreateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['atomic', 'items']);
  final val = HamsterBatchCreateRequest(
    atomic: $checkedConvert('atomic', (v) => v as bool),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => HamsterBatchCreateRequestItemsInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$HamsterBatchCreateRequestToJson(
  HamsterBatchCreateRequest instance,
) => <String, dynamic>{
  'atomic': instance.atomic,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
