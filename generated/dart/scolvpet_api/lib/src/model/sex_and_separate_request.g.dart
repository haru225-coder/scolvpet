// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sex_and_separate_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SexAndSeparateRequestCWProxy {
  SexAndSeparateRequest separatedAt(DateTime separatedAt);

  SexAndSeparateRequest timezone(String timezone);

  SexAndSeparateRequest items(List<SexAndSeparateRequestItemsInner> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateRequest call({
    DateTime separatedAt,
    String timezone,
    List<SexAndSeparateRequestItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSexAndSeparateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSexAndSeparateRequest.copyWith.fieldName(...)`
class _$SexAndSeparateRequestCWProxyImpl
    implements _$SexAndSeparateRequestCWProxy {
  const _$SexAndSeparateRequestCWProxyImpl(this._value);

  final SexAndSeparateRequest _value;

  @override
  SexAndSeparateRequest separatedAt(DateTime separatedAt) =>
      this(separatedAt: separatedAt);

  @override
  SexAndSeparateRequest timezone(String timezone) => this(timezone: timezone);

  @override
  SexAndSeparateRequest items(List<SexAndSeparateRequestItemsInner> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateRequest call({
    Object? separatedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return SexAndSeparateRequest(
      separatedAt: separatedAt == const $CopyWithPlaceholder()
          ? _value.separatedAt
          // ignore: cast_nullable_to_non_nullable
          : separatedAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<SexAndSeparateRequestItemsInner>,
    );
  }
}

extension $SexAndSeparateRequestCopyWith on SexAndSeparateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSexAndSeparateRequest.copyWith(...)` or like so:`instanceOfSexAndSeparateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SexAndSeparateRequestCWProxy get copyWith =>
      _$SexAndSeparateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SexAndSeparateRequest _$SexAndSeparateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SexAndSeparateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['separated_at', 'timezone', 'items']);
  final val = SexAndSeparateRequest(
    separatedAt: $checkedConvert(
      'separated_at',
      (v) => DateTime.parse(v as String),
    ),
    timezone: $checkedConvert('timezone', (v) => v as String),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => SexAndSeparateRequestItemsInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'separatedAt': 'separated_at'});

Map<String, dynamic> _$SexAndSeparateRequestToJson(
  SexAndSeparateRequest instance,
) => <String, dynamic>{
  'separated_at': instance.separatedAt.toIso8601String(),
  'timezone': instance.timezone,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
