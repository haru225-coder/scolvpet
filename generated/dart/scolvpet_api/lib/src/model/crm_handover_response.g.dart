// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_handover_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmHandoverResponseCWProxy {
  CrmHandoverResponse data(CrmHandover data);

  CrmHandoverResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmHandoverResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmHandoverResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmHandoverResponse call({CrmHandover data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmHandoverResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmHandoverResponse.copyWith.fieldName(...)`
class _$CrmHandoverResponseCWProxyImpl implements _$CrmHandoverResponseCWProxy {
  const _$CrmHandoverResponseCWProxyImpl(this._value);

  final CrmHandoverResponse _value;

  @override
  CrmHandoverResponse data(CrmHandover data) => this(data: data);

  @override
  CrmHandoverResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmHandoverResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmHandoverResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmHandoverResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CrmHandoverResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CrmHandover,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CrmHandoverResponseCopyWith on CrmHandoverResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCrmHandoverResponse.copyWith(...)` or like so:`instanceOfCrmHandoverResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmHandoverResponseCWProxy get copyWith =>
      _$CrmHandoverResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmHandoverResponse _$CrmHandoverResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CrmHandoverResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = CrmHandoverResponse(
        data: $checkedConvert(
          'data',
          (v) => CrmHandover.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CrmHandoverResponseToJson(
  CrmHandoverResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
