// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_wechat_bind_ticket_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerWechatBindTicketResponseCWProxy {
  CustomerWechatBindTicketResponse data(
    CustomerWechatBindTicketResponseData? data,
  );

  CustomerWechatBindTicketResponse meta(Map<String, Object>? meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerWechatBindTicketResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerWechatBindTicketResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerWechatBindTicketResponse call({
    CustomerWechatBindTicketResponseData? data,
    Map<String, Object>? meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerWechatBindTicketResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerWechatBindTicketResponse.copyWith.fieldName(...)`
class _$CustomerWechatBindTicketResponseCWProxyImpl
    implements _$CustomerWechatBindTicketResponseCWProxy {
  const _$CustomerWechatBindTicketResponseCWProxyImpl(this._value);

  final CustomerWechatBindTicketResponse _value;

  @override
  CustomerWechatBindTicketResponse data(
    CustomerWechatBindTicketResponseData? data,
  ) => this(data: data);

  @override
  CustomerWechatBindTicketResponse meta(Map<String, Object>? meta) =>
      this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerWechatBindTicketResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerWechatBindTicketResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerWechatBindTicketResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return CustomerWechatBindTicketResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as CustomerWechatBindTicketResponseData?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Map<String, Object>?,
    );
  }
}

extension $CustomerWechatBindTicketResponseCopyWith
    on CustomerWechatBindTicketResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerWechatBindTicketResponse.copyWith(...)` or like so:`instanceOfCustomerWechatBindTicketResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerWechatBindTicketResponseCWProxy get copyWith =>
      _$CustomerWechatBindTicketResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerWechatBindTicketResponse _$CustomerWechatBindTicketResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CustomerWechatBindTicketResponse', json, (
  $checkedConvert,
) {
  final val = CustomerWechatBindTicketResponse(
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : CustomerWechatBindTicketResponseData.fromJson(
              v as Map<String, dynamic>,
            ),
    ),
    meta: $checkedConvert(
      'meta',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$CustomerWechatBindTicketResponseToJson(
  CustomerWechatBindTicketResponse instance,
) => <String, dynamic>{
  'data': ?instance.data?.toJson(),
  'meta': ?instance.meta,
};
