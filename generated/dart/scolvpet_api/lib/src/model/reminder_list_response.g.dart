// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReminderListResponseCWProxy {
  ReminderListResponse data(List<Reminder> data);

  ReminderListResponse page(PageInfo page);

  ReminderListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderListResponse call({
    List<Reminder> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReminderListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReminderListResponse.copyWith.fieldName(...)`
class _$ReminderListResponseCWProxyImpl
    implements _$ReminderListResponseCWProxy {
  const _$ReminderListResponseCWProxyImpl(this._value);

  final ReminderListResponse _value;

  @override
  ReminderListResponse data(List<Reminder> data) => this(data: data);

  @override
  ReminderListResponse page(PageInfo page) => this(page: page);

  @override
  ReminderListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ReminderListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Reminder>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as PageInfo,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ReminderListResponseCopyWith on ReminderListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfReminderListResponse.copyWith(...)` or like so:`instanceOfReminderListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReminderListResponseCWProxy get copyWith =>
      _$ReminderListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderListResponse _$ReminderListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReminderListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = ReminderListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert(
      'page',
      (v) => PageInfo.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReminderListResponseToJson(
  ReminderListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
