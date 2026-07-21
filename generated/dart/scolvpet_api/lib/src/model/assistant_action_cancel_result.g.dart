// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_action_cancel_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantActionCancelResultCWProxy {
  AssistantActionCancelResult actionId(String actionId);

  AssistantActionCancelResult status(
    AssistantActionCancelResultStatusEnum status,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionCancelResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionCancelResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionCancelResult call({
    String actionId,
    AssistantActionCancelResultStatusEnum status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantActionCancelResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantActionCancelResult.copyWith.fieldName(...)`
class _$AssistantActionCancelResultCWProxyImpl
    implements _$AssistantActionCancelResultCWProxy {
  const _$AssistantActionCancelResultCWProxyImpl(this._value);

  final AssistantActionCancelResult _value;

  @override
  AssistantActionCancelResult actionId(String actionId) =>
      this(actionId: actionId);

  @override
  AssistantActionCancelResult status(
    AssistantActionCancelResultStatusEnum status,
  ) => this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantActionCancelResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantActionCancelResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantActionCancelResult call({
    Object? actionId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return AssistantActionCancelResult(
      actionId: actionId == const $CopyWithPlaceholder()
          ? _value.actionId
          // ignore: cast_nullable_to_non_nullable
          : actionId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AssistantActionCancelResultStatusEnum,
    );
  }
}

extension $AssistantActionCancelResultCopyWith on AssistantActionCancelResult {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantActionCancelResult.copyWith(...)` or like so:`instanceOfAssistantActionCancelResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantActionCancelResultCWProxy get copyWith =>
      _$AssistantActionCancelResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantActionCancelResult _$AssistantActionCancelResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantActionCancelResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['action_id', 'status']);
  final val = AssistantActionCancelResult(
    actionId: $checkedConvert('action_id', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$AssistantActionCancelResultStatusEnumEnumMap, v),
    ),
  );
  return val;
}, fieldKeyMap: const {'actionId': 'action_id'});

Map<String, dynamic> _$AssistantActionCancelResultToJson(
  AssistantActionCancelResult instance,
) => <String, dynamic>{
  'action_id': instance.actionId,
  'status': _$AssistantActionCancelResultStatusEnumEnumMap[instance.status]!,
};

const _$AssistantActionCancelResultStatusEnumEnumMap = {
  AssistantActionCancelResultStatusEnum.cancelled: 'cancelled',
};
