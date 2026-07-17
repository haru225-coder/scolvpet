// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sandbox_activate_plan_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SandboxActivatePlanRequestCWProxy {
  SandboxActivatePlanRequest planCode(
    SandboxActivatePlanRequestPlanCodeEnum? planCode,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SandboxActivatePlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SandboxActivatePlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SandboxActivatePlanRequest call({
    SandboxActivatePlanRequestPlanCodeEnum? planCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSandboxActivatePlanRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSandboxActivatePlanRequest.copyWith.fieldName(...)`
class _$SandboxActivatePlanRequestCWProxyImpl
    implements _$SandboxActivatePlanRequestCWProxy {
  const _$SandboxActivatePlanRequestCWProxyImpl(this._value);

  final SandboxActivatePlanRequest _value;

  @override
  SandboxActivatePlanRequest planCode(
    SandboxActivatePlanRequestPlanCodeEnum? planCode,
  ) => this(planCode: planCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SandboxActivatePlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SandboxActivatePlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SandboxActivatePlanRequest call({
    Object? planCode = const $CopyWithPlaceholder(),
  }) {
    return SandboxActivatePlanRequest(
      planCode: planCode == const $CopyWithPlaceholder()
          ? _value.planCode
          // ignore: cast_nullable_to_non_nullable
          : planCode as SandboxActivatePlanRequestPlanCodeEnum?,
    );
  }
}

extension $SandboxActivatePlanRequestCopyWith on SandboxActivatePlanRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSandboxActivatePlanRequest.copyWith(...)` or like so:`instanceOfSandboxActivatePlanRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SandboxActivatePlanRequestCWProxy get copyWith =>
      _$SandboxActivatePlanRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SandboxActivatePlanRequest _$SandboxActivatePlanRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SandboxActivatePlanRequest', json, ($checkedConvert) {
  final val = SandboxActivatePlanRequest(
    planCode: $checkedConvert(
      'plan_code',
      (v) =>
          $enumDecodeNullable(
            _$SandboxActivatePlanRequestPlanCodeEnumEnumMap,
            v,
          ) ??
          SandboxActivatePlanRequestPlanCodeEnum.pro,
    ),
  );
  return val;
}, fieldKeyMap: const {'planCode': 'plan_code'});

Map<String, dynamic> _$SandboxActivatePlanRequestToJson(
  SandboxActivatePlanRequest instance,
) => <String, dynamic>{
  'plan_code':
      ?_$SandboxActivatePlanRequestPlanCodeEnumEnumMap[instance.planCode],
};

const _$SandboxActivatePlanRequestPlanCodeEnumEnumMap = {
  SandboxActivatePlanRequestPlanCodeEnum.free: 'free',
  SandboxActivatePlanRequestPlanCodeEnum.pro: 'pro',
};
