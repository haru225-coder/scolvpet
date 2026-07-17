// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_contact_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmContactListResponseCWProxy {
  CrmContactListResponse data(List<CrmContact> data);

  CrmContactListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmContactListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmContactListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmContactListResponse call({List<CrmContact> data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmContactListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmContactListResponse.copyWith.fieldName(...)`
class _$CrmContactListResponseCWProxyImpl
    implements _$CrmContactListResponseCWProxy {
  const _$CrmContactListResponseCWProxyImpl(this._value);

  final CrmContactListResponse _value;

  @override
  CrmContactListResponse data(List<CrmContact> data) => this(data: data);

  @override
  CrmContactListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmContactListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmContactListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmContactListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CrmContactListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<CrmContact>,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CrmContactListResponseCopyWith on CrmContactListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCrmContactListResponse.copyWith(...)` or like so:`instanceOfCrmContactListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmContactListResponseCWProxy get copyWith =>
      _$CrmContactListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmContactListResponse _$CrmContactListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CrmContactListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = CrmContactListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => CrmContact.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$CrmContactListResponseToJson(
  CrmContactListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
