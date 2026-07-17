// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_handover_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmHandoverListResponseCWProxy {
  CrmHandoverListResponse data(List<CrmHandover> data);

  CrmHandoverListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmHandoverListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmHandoverListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmHandoverListResponse call({List<CrmHandover> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmHandoverListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmHandoverListResponse.copyWith.fieldName(...)`
class _$CrmHandoverListResponseCWProxyImpl
    implements _$CrmHandoverListResponseCWProxy {
  const _$CrmHandoverListResponseCWProxyImpl(this._value);

  final CrmHandoverListResponse _value;

  @override
  CrmHandoverListResponse data(List<CrmHandover> data) => this(data: data);

  @override
  CrmHandoverListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmHandoverListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmHandoverListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmHandoverListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CrmHandoverListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<CrmHandover>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CrmHandoverListResponseCopyWith on CrmHandoverListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCrmHandoverListResponse.copyWith(...)` or like so:`instanceOfCrmHandoverListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmHandoverListResponseCWProxy get copyWith =>
      _$CrmHandoverListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmHandoverListResponse _$CrmHandoverListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CrmHandoverListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CrmHandoverListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => CrmHandover.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CrmHandoverListResponseToJson(
  CrmHandoverListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
