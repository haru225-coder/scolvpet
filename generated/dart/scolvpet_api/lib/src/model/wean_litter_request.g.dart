// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wean_litter_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeanLitterRequestCWProxy {
  WeanLitterRequest weanedAt(DateTime weanedAt);

  WeanLitterRequest timezone(String timezone);

  WeanLitterRequest items(List<WeanLitterRequestItemsInner> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterRequest call({
    DateTime weanedAt,
    String timezone,
    List<WeanLitterRequestItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeanLitterRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeanLitterRequest.copyWith.fieldName(...)`
class _$WeanLitterRequestCWProxyImpl implements _$WeanLitterRequestCWProxy {
  const _$WeanLitterRequestCWProxyImpl(this._value);

  final WeanLitterRequest _value;

  @override
  WeanLitterRequest weanedAt(DateTime weanedAt) => this(weanedAt: weanedAt);

  @override
  WeanLitterRequest timezone(String timezone) => this(timezone: timezone);

  @override
  WeanLitterRequest items(List<WeanLitterRequestItemsInner> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeanLitterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeanLitterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WeanLitterRequest call({
    Object? weanedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return WeanLitterRequest(
      weanedAt: weanedAt == const $CopyWithPlaceholder()
          ? _value.weanedAt
          // ignore: cast_nullable_to_non_nullable
          : weanedAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<WeanLitterRequestItemsInner>,
    );
  }
}

extension $WeanLitterRequestCopyWith on WeanLitterRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWeanLitterRequest.copyWith(...)` or like so:`instanceOfWeanLitterRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeanLitterRequestCWProxy get copyWith =>
      _$WeanLitterRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeanLitterRequest _$WeanLitterRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WeanLitterRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['weaned_at', 'timezone', 'items']);
  final val = WeanLitterRequest(
    weanedAt: $checkedConvert('weaned_at', (v) => DateTime.parse(v as String)),
    timezone: $checkedConvert('timezone', (v) => v as String),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                WeanLitterRequestItemsInner.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'weanedAt': 'weaned_at'});

Map<String, dynamic> _$WeanLitterRequestToJson(WeanLitterRequest instance) =>
    <String, dynamic>{
      'weaned_at': instance.weanedAt.toIso8601String(),
      'timezone': instance.timezone,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
