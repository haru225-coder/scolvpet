// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_lead_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthLeadRequestCWProxy {
  PublicGrowthLeadRequest name(String name);

  PublicGrowthLeadRequest phone(String? phone);

  PublicGrowthLeadRequest wechat(String? wechat);

  PublicGrowthLeadRequest campaignCode(String? campaignCode);

  PublicGrowthLeadRequest consultationToken(String? consultationToken);

  PublicGrowthLeadRequest interestedHamsterId(String? interestedHamsterId);

  PublicGrowthLeadRequest intentSummary(String? intentSummary);

  PublicGrowthLeadRequest landingPath(String? landingPath);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthLeadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthLeadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthLeadRequest call({
    String name,
    String? phone,
    String? wechat,
    String? campaignCode,
    String? consultationToken,
    String? interestedHamsterId,
    String? intentSummary,
    String? landingPath,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthLeadRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthLeadRequest.copyWith.fieldName(...)`
class _$PublicGrowthLeadRequestCWProxyImpl
    implements _$PublicGrowthLeadRequestCWProxy {
  const _$PublicGrowthLeadRequestCWProxyImpl(this._value);

  final PublicGrowthLeadRequest _value;

  @override
  PublicGrowthLeadRequest name(String name) => this(name: name);

  @override
  PublicGrowthLeadRequest phone(String? phone) => this(phone: phone);

  @override
  PublicGrowthLeadRequest wechat(String? wechat) => this(wechat: wechat);

  @override
  PublicGrowthLeadRequest campaignCode(String? campaignCode) =>
      this(campaignCode: campaignCode);

  @override
  PublicGrowthLeadRequest consultationToken(String? consultationToken) =>
      this(consultationToken: consultationToken);

  @override
  PublicGrowthLeadRequest interestedHamsterId(String? interestedHamsterId) =>
      this(interestedHamsterId: interestedHamsterId);

  @override
  PublicGrowthLeadRequest intentSummary(String? intentSummary) =>
      this(intentSummary: intentSummary);

  @override
  PublicGrowthLeadRequest landingPath(String? landingPath) =>
      this(landingPath: landingPath);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthLeadRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthLeadRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthLeadRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? wechat = const $CopyWithPlaceholder(),
    Object? campaignCode = const $CopyWithPlaceholder(),
    Object? consultationToken = const $CopyWithPlaceholder(),
    Object? interestedHamsterId = const $CopyWithPlaceholder(),
    Object? intentSummary = const $CopyWithPlaceholder(),
    Object? landingPath = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthLeadRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      wechat: wechat == const $CopyWithPlaceholder()
          ? _value.wechat
          // ignore: cast_nullable_to_non_nullable
          : wechat as String?,
      campaignCode: campaignCode == const $CopyWithPlaceholder()
          ? _value.campaignCode
          // ignore: cast_nullable_to_non_nullable
          : campaignCode as String?,
      consultationToken: consultationToken == const $CopyWithPlaceholder()
          ? _value.consultationToken
          // ignore: cast_nullable_to_non_nullable
          : consultationToken as String?,
      interestedHamsterId: interestedHamsterId == const $CopyWithPlaceholder()
          ? _value.interestedHamsterId
          // ignore: cast_nullable_to_non_nullable
          : interestedHamsterId as String?,
      intentSummary: intentSummary == const $CopyWithPlaceholder()
          ? _value.intentSummary
          // ignore: cast_nullable_to_non_nullable
          : intentSummary as String?,
      landingPath: landingPath == const $CopyWithPlaceholder()
          ? _value.landingPath
          // ignore: cast_nullable_to_non_nullable
          : landingPath as String?,
    );
  }
}

extension $PublicGrowthLeadRequestCopyWith on PublicGrowthLeadRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthLeadRequest.copyWith(...)` or like so:`instanceOfPublicGrowthLeadRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthLeadRequestCWProxy get copyWith =>
      _$PublicGrowthLeadRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthLeadRequest _$PublicGrowthLeadRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublicGrowthLeadRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['name']);
    final val = PublicGrowthLeadRequest(
      name: $checkedConvert('name', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String?),
      wechat: $checkedConvert('wechat', (v) => v as String?),
      campaignCode: $checkedConvert('campaign_code', (v) => v as String?),
      consultationToken: $checkedConvert(
        'consultation_token',
        (v) => v as String?,
      ),
      interestedHamsterId: $checkedConvert(
        'interested_hamster_id',
        (v) => v as String?,
      ),
      intentSummary: $checkedConvert('intent_summary', (v) => v as String?),
      landingPath: $checkedConvert('landing_path', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'campaignCode': 'campaign_code',
    'consultationToken': 'consultation_token',
    'interestedHamsterId': 'interested_hamster_id',
    'intentSummary': 'intent_summary',
    'landingPath': 'landing_path',
  },
);

Map<String, dynamic> _$PublicGrowthLeadRequestToJson(
  PublicGrowthLeadRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'phone': ?instance.phone,
  'wechat': ?instance.wechat,
  'campaign_code': ?instance.campaignCode,
  'consultation_token': ?instance.consultationToken,
  'interested_hamster_id': ?instance.interestedHamsterId,
  'intent_summary': ?instance.intentSummary,
  'landing_path': ?instance.landingPath,
};
