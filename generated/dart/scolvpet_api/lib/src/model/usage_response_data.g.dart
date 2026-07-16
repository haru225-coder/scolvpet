// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UsageResponseDataCWProxy {
  UsageResponseData metrics(List<UsageMetric> metrics);

  UsageResponseData meteringStatus(
    UsageResponseDataMeteringStatusEnum meteringStatus,
  );

  UsageResponseData entitlement(UsageResponseDataEntitlement entitlement);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageResponseData call({
    List<UsageMetric> metrics,
    UsageResponseDataMeteringStatusEnum meteringStatus,
    UsageResponseDataEntitlement entitlement,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUsageResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUsageResponseData.copyWith.fieldName(...)`
class _$UsageResponseDataCWProxyImpl implements _$UsageResponseDataCWProxy {
  const _$UsageResponseDataCWProxyImpl(this._value);

  final UsageResponseData _value;

  @override
  UsageResponseData metrics(List<UsageMetric> metrics) =>
      this(metrics: metrics);

  @override
  UsageResponseData meteringStatus(
    UsageResponseDataMeteringStatusEnum meteringStatus,
  ) => this(meteringStatus: meteringStatus);

  @override
  UsageResponseData entitlement(UsageResponseDataEntitlement entitlement) =>
      this(entitlement: entitlement);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UsageResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UsageResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  UsageResponseData call({
    Object? metrics = const $CopyWithPlaceholder(),
    Object? meteringStatus = const $CopyWithPlaceholder(),
    Object? entitlement = const $CopyWithPlaceholder(),
  }) {
    return UsageResponseData(
      metrics: metrics == const $CopyWithPlaceholder()
          ? _value.metrics
          // ignore: cast_nullable_to_non_nullable
          : metrics as List<UsageMetric>,
      meteringStatus: meteringStatus == const $CopyWithPlaceholder()
          ? _value.meteringStatus
          // ignore: cast_nullable_to_non_nullable
          : meteringStatus as UsageResponseDataMeteringStatusEnum,
      entitlement: entitlement == const $CopyWithPlaceholder()
          ? _value.entitlement
          // ignore: cast_nullable_to_non_nullable
          : entitlement as UsageResponseDataEntitlement,
    );
  }
}

extension $UsageResponseDataCopyWith on UsageResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfUsageResponseData.copyWith(...)` or like so:`instanceOfUsageResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UsageResponseDataCWProxy get copyWith =>
      _$UsageResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageResponseData _$UsageResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UsageResponseData', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['metrics', 'metering_status', 'entitlement'],
      );
      final val = UsageResponseData(
        metrics: $checkedConvert(
          'metrics',
          (v) => (v as List<dynamic>)
              .map((e) => UsageMetric.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        meteringStatus: $checkedConvert(
          'metering_status',
          (v) => $enumDecode(_$UsageResponseDataMeteringStatusEnumEnumMap, v),
        ),
        entitlement: $checkedConvert(
          'entitlement',
          (v) =>
              UsageResponseDataEntitlement.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'meteringStatus': 'metering_status'});

Map<String, dynamic> _$UsageResponseDataToJson(
  UsageResponseData instance,
) => <String, dynamic>{
  'metrics': instance.metrics.map((e) => e.toJson()).toList(),
  'metering_status':
      _$UsageResponseDataMeteringStatusEnumEnumMap[instance.meteringStatus]!,
  'entitlement': instance.entitlement.toJson(),
};

const _$UsageResponseDataMeteringStatusEnumEnumMap = {
  UsageResponseDataMeteringStatusEnum.current: 'current',
  UsageResponseDataMeteringStatusEnum.updating: 'updating',
  UsageResponseDataMeteringStatusEnum.delayed: 'delayed',
};
