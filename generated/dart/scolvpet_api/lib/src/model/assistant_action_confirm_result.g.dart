// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_action_confirm_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantActionConfirmResultCWProxy {
  AssistantActionConfirmResult actionId(String actionId);

  AssistantActionConfirmResult type(String type);

  AssistantActionConfirmResult status(
    AssistantActionConfirmResultStatusEnum status,
  );

  AssistantActionConfirmResult result(Map<String, Object> result);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionConfirmResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionConfirmResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionConfirmResult call({
    String actionId,
    String type,
    AssistantActionConfirmResultStatusEnum status,
    Map<String, Object> result,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantActionConfirmResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantActionConfirmResult.copyWith.fieldName(...)`
class _$AssistantActionConfirmResultCWProxyImpl
    implements _$AssistantActionConfirmResultCWProxy {
  const _$AssistantActionConfirmResultCWProxyImpl(this._value);

  final AssistantActionConfirmResult _value;

  @override
  AssistantActionConfirmResult actionId(String actionId) =>
      this(actionId: actionId);

  @override
  AssistantActionConfirmResult type(String type) => this(type: type);

  @override
  AssistantActionConfirmResult status(
    AssistantActionConfirmResultStatusEnum status,
  ) => this(status: status);

  @override
  AssistantActionConfirmResult result(Map<String, Object> result) =>
      this(result: result);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionConfirmResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionConfirmResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionConfirmResult call({
    Object? actionId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
  }) {
    return AssistantActionConfirmResult(
      actionId: actionId == const $CopyWithPlaceholder()
          ? _value.actionId
          // ignore: cast_nullable_to_non_nullable
          : actionId as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AssistantActionConfirmResultStatusEnum,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as Map<String, Object>,
    );
  }
}

extension $AssistantActionConfirmResultCopyWith
    on AssistantActionConfirmResult {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantActionConfirmResult.copyWith(...)` or like so:`instanceOfAssistantActionConfirmResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantActionConfirmResultCWProxy get copyWith =>
      _$AssistantActionConfirmResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantActionConfirmResult _$AssistantActionConfirmResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantActionConfirmResult', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['action_id', 'type', 'status', 'result'],
  );
  final val = AssistantActionConfirmResult(
    actionId: $checkedConvert('action_id', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$AssistantActionConfirmResultStatusEnumEnumMap, v),
    ),
    result: $checkedConvert(
      'result',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
}, fieldKeyMap: const {'actionId': 'action_id'});

Map<String, dynamic> _$AssistantActionConfirmResultToJson(
  AssistantActionConfirmResult instance,
) => <String, dynamic>{
  'action_id': instance.actionId,
  'type': instance.type,
  'status': _$AssistantActionConfirmResultStatusEnumEnumMap[instance.status]!,
  'result': instance.result,
};

const _$AssistantActionConfirmResultStatusEnumEnumMap = {
  AssistantActionConfirmResultStatusEnum.executed: 'executed',
};
