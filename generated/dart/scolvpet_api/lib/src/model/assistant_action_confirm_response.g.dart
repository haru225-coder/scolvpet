// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_action_confirm_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantActionConfirmResponseCWProxy {
  AssistantActionConfirmResponse data(AssistantActionConfirmResult data);

  AssistantActionConfirmResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionConfirmResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionConfirmResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionConfirmResponse call({
    AssistantActionConfirmResult data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantActionConfirmResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantActionConfirmResponse.copyWith.fieldName(...)`
class _$AssistantActionConfirmResponseCWProxyImpl
    implements _$AssistantActionConfirmResponseCWProxy {
  const _$AssistantActionConfirmResponseCWProxyImpl(this._value);

  final AssistantActionConfirmResponse _value;

  @override
  AssistantActionConfirmResponse data(AssistantActionConfirmResult data) =>
      this(data: data);

  @override
  AssistantActionConfirmResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionConfirmResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionConfirmResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionConfirmResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantActionConfirmResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AssistantActionConfirmResult,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantActionConfirmResponseCopyWith
    on AssistantActionConfirmResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantActionConfirmResponse.copyWith(...)` or like so:`instanceOfAssistantActionConfirmResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantActionConfirmResponseCWProxy get copyWith =>
      _$AssistantActionConfirmResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantActionConfirmResponse _$AssistantActionConfirmResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantActionConfirmResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantActionConfirmResponse(
    data: $checkedConvert(
      'data',
      (v) => AssistantActionConfirmResult.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantActionConfirmResponseToJson(
  AssistantActionConfirmResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
