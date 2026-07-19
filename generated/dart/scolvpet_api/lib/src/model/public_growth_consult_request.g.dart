// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_consult_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthConsultRequestCWProxy {
  PublicGrowthConsultRequest message(String message);

  PublicGrowthConsultRequest sessionToken(String? sessionToken);

  PublicGrowthConsultRequest campaignCode(String? campaignCode);

  PublicGrowthConsultRequest interestedHamsterId(String? interestedHamsterId);

  PublicGrowthConsultRequest landingPath(String? landingPath);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthConsultRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthConsultRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthConsultRequest call({
    String message,
    String? sessionToken,
    String? campaignCode,
    String? interestedHamsterId,
    String? landingPath,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthConsultRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthConsultRequest.copyWith.fieldName(...)`
class _$PublicGrowthConsultRequestCWProxyImpl
    implements _$PublicGrowthConsultRequestCWProxy {
  const _$PublicGrowthConsultRequestCWProxyImpl(this._value);

  final PublicGrowthConsultRequest _value;

  @override
  PublicGrowthConsultRequest message(String message) => this(message: message);

  @override
  PublicGrowthConsultRequest sessionToken(String? sessionToken) =>
      this(sessionToken: sessionToken);

  @override
  PublicGrowthConsultRequest campaignCode(String? campaignCode) =>
      this(campaignCode: campaignCode);

  @override
  PublicGrowthConsultRequest interestedHamsterId(String? interestedHamsterId) =>
      this(interestedHamsterId: interestedHamsterId);

  @override
  PublicGrowthConsultRequest landingPath(String? landingPath) =>
      this(landingPath: landingPath);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthConsultRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthConsultRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthConsultRequest call({
    Object? message = const $CopyWithPlaceholder(),
    Object? sessionToken = const $CopyWithPlaceholder(),
    Object? campaignCode = const $CopyWithPlaceholder(),
    Object? interestedHamsterId = const $CopyWithPlaceholder(),
    Object? landingPath = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthConsultRequest(
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      sessionToken: sessionToken == const $CopyWithPlaceholder()
          ? _value.sessionToken
          // ignore: cast_nullable_to_non_nullable
          : sessionToken as String?,
      campaignCode: campaignCode == const $CopyWithPlaceholder()
          ? _value.campaignCode
          // ignore: cast_nullable_to_non_nullable
          : campaignCode as String?,
      interestedHamsterId: interestedHamsterId == const $CopyWithPlaceholder()
          ? _value.interestedHamsterId
          // ignore: cast_nullable_to_non_nullable
          : interestedHamsterId as String?,
      landingPath: landingPath == const $CopyWithPlaceholder()
          ? _value.landingPath
          // ignore: cast_nullable_to_non_nullable
          : landingPath as String?,
    );
  }
}

extension $PublicGrowthConsultRequestCopyWith on PublicGrowthConsultRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthConsultRequest.copyWith(...)` or like so:`instanceOfPublicGrowthConsultRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthConsultRequestCWProxy get copyWith =>
      _$PublicGrowthConsultRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthConsultRequest _$PublicGrowthConsultRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublicGrowthConsultRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['message']);
    final val = PublicGrowthConsultRequest(
      message: $checkedConvert('message', (v) => v as String),
      sessionToken: $checkedConvert('session_token', (v) => v as String?),
      campaignCode: $checkedConvert('campaign_code', (v) => v as String?),
      interestedHamsterId: $checkedConvert(
        'interested_hamster_id',
        (v) => v as String?,
      ),
      landingPath: $checkedConvert('landing_path', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'sessionToken': 'session_token',
    'campaignCode': 'campaign_code',
    'interestedHamsterId': 'interested_hamster_id',
    'landingPath': 'landing_path',
  },
);

Map<String, dynamic> _$PublicGrowthConsultRequestToJson(
  PublicGrowthConsultRequest instance,
) => <String, dynamic>{
  'message': instance.message,
  'session_token': ?instance.sessionToken,
  'campaign_code': ?instance.campaignCode,
  'interested_hamster_id': ?instance.interestedHamsterId,
  'landing_path': ?instance.landingPath,
};
