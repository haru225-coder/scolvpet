// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionResponseDataCWProxy {
  SessionResponseData tokenType(SessionResponseDataTokenTypeEnum tokenType);

  SessionResponseData accessToken(String accessToken);

  SessionResponseData expiresInSeconds(int expiresInSeconds);

  SessionResponseData refreshToken(String refreshToken);

  SessionResponseData account(Account account);

  SessionResponseData currentOrganization(Organization currentOrganization);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionResponseData call({
    SessionResponseDataTokenTypeEnum tokenType,
    String accessToken,
    int expiresInSeconds,
    String refreshToken,
    Account account,
    Organization currentOrganization,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionResponseData.copyWith.fieldName(...)`
class _$SessionResponseDataCWProxyImpl implements _$SessionResponseDataCWProxy {
  const _$SessionResponseDataCWProxyImpl(this._value);

  final SessionResponseData _value;

  @override
  SessionResponseData tokenType(SessionResponseDataTokenTypeEnum tokenType) =>
      this(tokenType: tokenType);

  @override
  SessionResponseData accessToken(String accessToken) =>
      this(accessToken: accessToken);

  @override
  SessionResponseData expiresInSeconds(int expiresInSeconds) =>
      this(expiresInSeconds: expiresInSeconds);

  @override
  SessionResponseData refreshToken(String refreshToken) =>
      this(refreshToken: refreshToken);

  @override
  SessionResponseData account(Account account) => this(account: account);

  @override
  SessionResponseData currentOrganization(Organization currentOrganization) =>
      this(currentOrganization: currentOrganization);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionResponseData call({
    Object? tokenType = const $CopyWithPlaceholder(),
    Object? accessToken = const $CopyWithPlaceholder(),
    Object? expiresInSeconds = const $CopyWithPlaceholder(),
    Object? refreshToken = const $CopyWithPlaceholder(),
    Object? account = const $CopyWithPlaceholder(),
    Object? currentOrganization = const $CopyWithPlaceholder(),
  }) {
    return SessionResponseData(
      tokenType: tokenType == const $CopyWithPlaceholder()
          ? _value.tokenType
          // ignore: cast_nullable_to_non_nullable
          : tokenType as SessionResponseDataTokenTypeEnum,
      accessToken: accessToken == const $CopyWithPlaceholder()
          ? _value.accessToken
          // ignore: cast_nullable_to_non_nullable
          : accessToken as String,
      expiresInSeconds: expiresInSeconds == const $CopyWithPlaceholder()
          ? _value.expiresInSeconds
          // ignore: cast_nullable_to_non_nullable
          : expiresInSeconds as int,
      refreshToken: refreshToken == const $CopyWithPlaceholder()
          ? _value.refreshToken
          // ignore: cast_nullable_to_non_nullable
          : refreshToken as String,
      account: account == const $CopyWithPlaceholder()
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as Account,
      currentOrganization: currentOrganization == const $CopyWithPlaceholder()
          ? _value.currentOrganization
          // ignore: cast_nullable_to_non_nullable
          : currentOrganization as Organization,
    );
  }
}

extension $SessionResponseDataCopyWith on SessionResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfSessionResponseData.copyWith(...)` or like so:`instanceOfSessionResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionResponseDataCWProxy get copyWith =>
      _$SessionResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionResponseData _$SessionResponseDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SessionResponseData',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'token_type',
            'access_token',
            'expires_in_seconds',
            'refresh_token',
            'account',
            'current_organization',
          ],
        );
        final val = SessionResponseData(
          tokenType: $checkedConvert(
            'token_type',
            (v) => $enumDecode(_$SessionResponseDataTokenTypeEnumEnumMap, v),
          ),
          accessToken: $checkedConvert('access_token', (v) => v as String),
          expiresInSeconds: $checkedConvert(
            'expires_in_seconds',
            (v) => (v as num).toInt(),
          ),
          refreshToken: $checkedConvert('refresh_token', (v) => v as String),
          account: $checkedConvert(
            'account',
            (v) => Account.fromJson(v as Map<String, dynamic>),
          ),
          currentOrganization: $checkedConvert(
            'current_organization',
            (v) => Organization.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'tokenType': 'token_type',
        'accessToken': 'access_token',
        'expiresInSeconds': 'expires_in_seconds',
        'refreshToken': 'refresh_token',
        'currentOrganization': 'current_organization',
      },
    );

Map<String, dynamic> _$SessionResponseDataToJson(
  SessionResponseData instance,
) => <String, dynamic>{
  'token_type': _$SessionResponseDataTokenTypeEnumEnumMap[instance.tokenType]!,
  'access_token': instance.accessToken,
  'expires_in_seconds': instance.expiresInSeconds,
  'refresh_token': instance.refreshToken,
  'account': instance.account.toJson(),
  'current_organization': instance.currentOrganization.toJson(),
};

const _$SessionResponseDataTokenTypeEnumEnumMap = {
  SessionResponseDataTokenTypeEnum.bearer: 'Bearer',
};
