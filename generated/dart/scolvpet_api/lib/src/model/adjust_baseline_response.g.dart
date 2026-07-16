// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_baseline_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdjustBaselineResponseCWProxy {
  AdjustBaselineResponse data(AdjustBaselineResponseData data);

  AdjustBaselineResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustBaselineResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustBaselineResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustBaselineResponse call({
    AdjustBaselineResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdjustBaselineResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdjustBaselineResponse.copyWith.fieldName(...)`
class _$AdjustBaselineResponseCWProxyImpl
    implements _$AdjustBaselineResponseCWProxy {
  const _$AdjustBaselineResponseCWProxyImpl(this._value);

  final AdjustBaselineResponse _value;

  @override
  AdjustBaselineResponse data(AdjustBaselineResponseData data) =>
      this(data: data);

  @override
  AdjustBaselineResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdjustBaselineResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdjustBaselineResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdjustBaselineResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AdjustBaselineResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AdjustBaselineResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AdjustBaselineResponseCopyWith on AdjustBaselineResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAdjustBaselineResponse.copyWith(...)` or like so:`instanceOfAdjustBaselineResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdjustBaselineResponseCWProxy get copyWith =>
      _$AdjustBaselineResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustBaselineResponse _$AdjustBaselineResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdjustBaselineResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AdjustBaselineResponse(
    data: $checkedConvert(
      'data',
      (v) => AdjustBaselineResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AdjustBaselineResponseToJson(
  AdjustBaselineResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
