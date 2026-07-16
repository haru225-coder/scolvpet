// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_session_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RefreshSessionRequestCWProxy {
  RefreshSessionRequest refreshToken(String refreshToken);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefreshSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefreshSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RefreshSessionRequest call({String refreshToken});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRefreshSessionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRefreshSessionRequest.copyWith.fieldName(...)`
class _$RefreshSessionRequestCWProxyImpl
    implements _$RefreshSessionRequestCWProxy {
  const _$RefreshSessionRequestCWProxyImpl(this._value);

  final RefreshSessionRequest _value;

  @override
  RefreshSessionRequest refreshToken(String refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefreshSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefreshSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RefreshSessionRequest call({
    Object? refreshToken = const $CopyWithPlaceholder(),
  }) {
    return RefreshSessionRequest(
      refreshToken: refreshToken == const $CopyWithPlaceholder()
          ? _value.refreshToken
          // ignore: cast_nullable_to_non_nullable
          : refreshToken as String,
    );
  }
}

extension $RefreshSessionRequestCopyWith on RefreshSessionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRefreshSessionRequest.copyWith(...)` or like so:`instanceOfRefreshSessionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RefreshSessionRequestCWProxy get copyWith =>
      _$RefreshSessionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshSessionRequest _$RefreshSessionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RefreshSessionRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['refresh_token']);
  final val = RefreshSessionRequest(
    refreshToken: $checkedConvert('refresh_token', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'refreshToken': 'refresh_token'});

Map<String, dynamic> _$RefreshSessionRequestToJson(
  RefreshSessionRequest instance,
) => <String, dynamic>{'refresh_token': instance.refreshToken};
