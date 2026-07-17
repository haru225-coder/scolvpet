// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_contact_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CrmContactResponseCWProxy {
  CrmContactResponse data(CrmContact data);

  CrmContactResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmContactResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmContactResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmContactResponse call({CrmContact data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCrmContactResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCrmContactResponse.copyWith.fieldName(...)`
class _$CrmContactResponseCWProxyImpl implements _$CrmContactResponseCWProxy {
  const _$CrmContactResponseCWProxyImpl(this._value);

  final CrmContactResponse _value;

  @override
  CrmContactResponse data(CrmContact data) => this(data: data);

  @override
  CrmContactResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CrmContactResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CrmContactResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CrmContactResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CrmContactResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CrmContact,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $CrmContactResponseCopyWith on CrmContactResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCrmContactResponse.copyWith(...)` or like so:`instanceOfCrmContactResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CrmContactResponseCWProxy get copyWith =>
      _$CrmContactResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrmContactResponse _$CrmContactResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CrmContactResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = CrmContactResponse(
        data: $checkedConvert(
          'data',
          (v) => CrmContact.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CrmContactResponseToJson(CrmContactResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
