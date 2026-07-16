// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualization_eligibility_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizationEligibilityResponseCWProxy {
  IndividualizationEligibilityResponse data(IndividualizationEligibility data);

  IndividualizationEligibilityResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizationEligibilityResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizationEligibilityResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizationEligibilityResponse call({
    IndividualizationEligibility data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizationEligibilityResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizationEligibilityResponse.copyWith.fieldName(...)`
class _$IndividualizationEligibilityResponseCWProxyImpl
    implements _$IndividualizationEligibilityResponseCWProxy {
  const _$IndividualizationEligibilityResponseCWProxyImpl(this._value);

  final IndividualizationEligibilityResponse _value;

  @override
  IndividualizationEligibilityResponse data(
    IndividualizationEligibility data,
  ) => this(data: data);

  @override
  IndividualizationEligibilityResponse meta(ResponseMeta meta) =>
      this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizationEligibilityResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizationEligibilityResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizationEligibilityResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return IndividualizationEligibilityResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as IndividualizationEligibility,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $IndividualizationEligibilityResponseCopyWith
    on IndividualizationEligibilityResponse {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizationEligibilityResponse.copyWith(...)` or like so:`instanceOfIndividualizationEligibilityResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizationEligibilityResponseCWProxy get copyWith =>
      _$IndividualizationEligibilityResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizationEligibilityResponse
_$IndividualizationEligibilityResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IndividualizationEligibilityResponse', json, (
      $checkedConvert,
    ) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = IndividualizationEligibilityResponse(
        data: $checkedConvert(
          'data',
          (v) =>
              IndividualizationEligibility.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$IndividualizationEligibilityResponseToJson(
  IndividualizationEligibilityResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
