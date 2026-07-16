// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReminderResponseCWProxy {
  ReminderResponse data(Reminder data);

  ReminderResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderResponse call({Reminder data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReminderResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReminderResponse.copyWith.fieldName(...)`
class _$ReminderResponseCWProxyImpl implements _$ReminderResponseCWProxy {
  const _$ReminderResponseCWProxyImpl(this._value);

  final ReminderResponse _value;

  @override
  ReminderResponse data(Reminder data) => this(data: data);

  @override
  ReminderResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ReminderResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Reminder,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $ReminderResponseCopyWith on ReminderResponse {
  /// Returns a callable class that can be used as follows: `instanceOfReminderResponse.copyWith(...)` or like so:`instanceOfReminderResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReminderResponseCWProxy get copyWith => _$ReminderResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderResponse _$ReminderResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReminderResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = ReminderResponse(
        data: $checkedConvert(
          'data',
          (v) => Reminder.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReminderResponseToJson(ReminderResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
