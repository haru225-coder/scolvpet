// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_action_cancel_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantActionCancelResponseCWProxy {
  AssistantActionCancelResponse data(AssistantActionCancelResult data);

  AssistantActionCancelResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionCancelResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionCancelResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionCancelResponse call({
    AssistantActionCancelResult data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantActionCancelResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantActionCancelResponse.copyWith.fieldName(...)`
class _$AssistantActionCancelResponseCWProxyImpl
    implements _$AssistantActionCancelResponseCWProxy {
  const _$AssistantActionCancelResponseCWProxyImpl(this._value);

  final AssistantActionCancelResponse _value;

  @override
  AssistantActionCancelResponse data(AssistantActionCancelResult data) =>
      this(data: data);

  @override
  AssistantActionCancelResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionCancelResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionCancelResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionCancelResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantActionCancelResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AssistantActionCancelResult,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantActionCancelResponseCopyWith
    on AssistantActionCancelResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantActionCancelResponse.copyWith(...)` or like so:`instanceOfAssistantActionCancelResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantActionCancelResponseCWProxy get copyWith =>
      _$AssistantActionCancelResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantActionCancelResponse _$AssistantActionCancelResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantActionCancelResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantActionCancelResponse(
    data: $checkedConvert(
      'data',
      (v) => AssistantActionCancelResult.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantActionCancelResponseToJson(
  AssistantActionCancelResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
