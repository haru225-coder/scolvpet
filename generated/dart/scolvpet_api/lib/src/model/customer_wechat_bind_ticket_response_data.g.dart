// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_wechat_bind_ticket_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerWechatBindTicketResponseDataCWProxy {
  CustomerWechatBindTicketResponseData bindRequired(bool bindRequired);

  CustomerWechatBindTicketResponseData wechatTicket(String wechatTicket);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerWechatBindTicketResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerWechatBindTicketResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerWechatBindTicketResponseData call({
    bool bindRequired,
    String wechatTicket,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerWechatBindTicketResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerWechatBindTicketResponseData.copyWith.fieldName(...)`
class _$CustomerWechatBindTicketResponseDataCWProxyImpl
    implements _$CustomerWechatBindTicketResponseDataCWProxy {
  const _$CustomerWechatBindTicketResponseDataCWProxyImpl(this._value);

  final CustomerWechatBindTicketResponseData _value;

  @override
  CustomerWechatBindTicketResponseData bindRequired(bool bindRequired) =>
      this(bindRequired: bindRequired);

  @override
  CustomerWechatBindTicketResponseData wechatTicket(String wechatTicket) =>
      this(wechatTicket: wechatTicket);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerWechatBindTicketResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerWechatBindTicketResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerWechatBindTicketResponseData call({
    Object? bindRequired = const $CopyWithPlaceholder(),
    Object? wechatTicket = const $CopyWithPlaceholder(),
  }) {
    return CustomerWechatBindTicketResponseData(
      bindRequired: bindRequired == const $CopyWithPlaceholder()
          ? _value.bindRequired
          // ignore: cast_nullable_to_non_nullable
          : bindRequired as bool,
      wechatTicket: wechatTicket == const $CopyWithPlaceholder()
          ? _value.wechatTicket
          // ignore: cast_nullable_to_non_nullable
          : wechatTicket as String,
    );
  }
}

extension $CustomerWechatBindTicketResponseDataCopyWith
    on CustomerWechatBindTicketResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerWechatBindTicketResponseData.copyWith(...)` or like so:`instanceOfCustomerWechatBindTicketResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerWechatBindTicketResponseDataCWProxy get copyWith =>
      _$CustomerWechatBindTicketResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerWechatBindTicketResponseData
_$CustomerWechatBindTicketResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CustomerWechatBindTicketResponseData',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['bind_required', 'wechat_ticket'],
        );
        final val = CustomerWechatBindTicketResponseData(
          bindRequired: $checkedConvert('bind_required', (v) => v as bool),
          wechatTicket: $checkedConvert('wechat_ticket', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'bindRequired': 'bind_required',
        'wechatTicket': 'wechat_ticket',
      },
    );

Map<String, dynamic> _$CustomerWechatBindTicketResponseDataToJson(
  CustomerWechatBindTicketResponseData instance,
) => <String, dynamic>{
  'bind_required': instance.bindRequired,
  'wechat_ticket': instance.wechatTicket,
};
