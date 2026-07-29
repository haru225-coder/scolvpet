// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_breeder_wechat_session_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateBreederWechatSessionRequestCWProxy {
  CreateBreederWechatSessionRequest jsCode(String jsCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBreederWechatSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBreederWechatSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBreederWechatSessionRequest call({String jsCode});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateBreederWechatSessionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateBreederWechatSessionRequest.copyWith.fieldName(...)`
class _$CreateBreederWechatSessionRequestCWProxyImpl
    implements _$CreateBreederWechatSessionRequestCWProxy {
  const _$CreateBreederWechatSessionRequestCWProxyImpl(this._value);

  final CreateBreederWechatSessionRequest _value;

  @override
  CreateBreederWechatSessionRequest jsCode(String jsCode) =>
      this(jsCode: jsCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateBreederWechatSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateBreederWechatSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateBreederWechatSessionRequest call({
    Object? jsCode = const $CopyWithPlaceholder(),
  }) {
    return CreateBreederWechatSessionRequest(
      jsCode: jsCode == const $CopyWithPlaceholder()
          ? _value.jsCode
          // ignore: cast_nullable_to_non_nullable
          : jsCode as String,
    );
  }
}

extension $CreateBreederWechatSessionRequestCopyWith
    on CreateBreederWechatSessionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateBreederWechatSessionRequest.copyWith(...)` or like so:`instanceOfCreateBreederWechatSessionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateBreederWechatSessionRequestCWProxy get copyWith =>
      _$CreateBreederWechatSessionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBreederWechatSessionRequest _$CreateBreederWechatSessionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateBreederWechatSessionRequest', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['js_code']);
  final val = CreateBreederWechatSessionRequest(
    jsCode: $checkedConvert('js_code', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'jsCode': 'js_code'});

Map<String, dynamic> _$CreateBreederWechatSessionRequestToJson(
  CreateBreederWechatSessionRequest instance,
) => <String, dynamic>{'js_code': instance.jsCode};
