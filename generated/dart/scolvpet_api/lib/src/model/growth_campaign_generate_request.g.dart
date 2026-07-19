// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_campaign_generate_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthCampaignGenerateRequestCWProxy {
  GrowthCampaignGenerateRequest campaignType(
    GrowthCampaignGenerateRequestCampaignTypeEnum campaignType,
  );

  GrowthCampaignGenerateRequest platform(String platform);

  GrowthCampaignGenerateRequest goal(String goal);

  GrowthCampaignGenerateRequest durationSeconds(int? durationSeconds);

  GrowthCampaignGenerateRequest tone(String tone);

  GrowthCampaignGenerateRequest cta(String? cta);

  GrowthCampaignGenerateRequest hamsterId(String hamsterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthCampaignGenerateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthCampaignGenerateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthCampaignGenerateRequest call({
    GrowthCampaignGenerateRequestCampaignTypeEnum campaignType,
    String platform,
    String goal,
    int? durationSeconds,
    String tone,
    String? cta,
    String hamsterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthCampaignGenerateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthCampaignGenerateRequest.copyWith.fieldName(...)`
class _$GrowthCampaignGenerateRequestCWProxyImpl
    implements _$GrowthCampaignGenerateRequestCWProxy {
  const _$GrowthCampaignGenerateRequestCWProxyImpl(this._value);

  final GrowthCampaignGenerateRequest _value;

  @override
  GrowthCampaignGenerateRequest campaignType(
    GrowthCampaignGenerateRequestCampaignTypeEnum campaignType,
  ) => this(campaignType: campaignType);

  @override
  GrowthCampaignGenerateRequest platform(String platform) =>
      this(platform: platform);

  @override
  GrowthCampaignGenerateRequest goal(String goal) => this(goal: goal);

  @override
  GrowthCampaignGenerateRequest durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  GrowthCampaignGenerateRequest tone(String tone) => this(tone: tone);

  @override
  GrowthCampaignGenerateRequest cta(String? cta) => this(cta: cta);

  @override
  GrowthCampaignGenerateRequest hamsterId(String hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthCampaignGenerateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthCampaignGenerateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthCampaignGenerateRequest call({
    Object? campaignType = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? goal = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? tone = const $CopyWithPlaceholder(),
    Object? cta = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
  }) {
    return GrowthCampaignGenerateRequest(
      campaignType: campaignType == const $CopyWithPlaceholder()
          ? _value.campaignType
          // ignore: cast_nullable_to_non_nullable
          : campaignType as GrowthCampaignGenerateRequestCampaignTypeEnum,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as String,
      goal: goal == const $CopyWithPlaceholder()
          ? _value.goal
          // ignore: cast_nullable_to_non_nullable
          : goal as String,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      tone: tone == const $CopyWithPlaceholder()
          ? _value.tone
          // ignore: cast_nullable_to_non_nullable
          : tone as String,
      cta: cta == const $CopyWithPlaceholder()
          ? _value.cta
          // ignore: cast_nullable_to_non_nullable
          : cta as String?,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
    );
  }
}

extension $GrowthCampaignGenerateRequestCopyWith
    on GrowthCampaignGenerateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthCampaignGenerateRequest.copyWith(...)` or like so:`instanceOfGrowthCampaignGenerateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthCampaignGenerateRequestCWProxy get copyWith =>
      _$GrowthCampaignGenerateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthCampaignGenerateRequest _$GrowthCampaignGenerateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GrowthCampaignGenerateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'campaign_type',
        'platform',
        'goal',
        'tone',
        'hamster_id',
      ],
    );
    final val = GrowthCampaignGenerateRequest(
      campaignType: $checkedConvert(
        'campaign_type',
        (v) => $enumDecode(
          _$GrowthCampaignGenerateRequestCampaignTypeEnumEnumMap,
          v,
        ),
      ),
      platform: $checkedConvert('platform', (v) => v as String),
      goal: $checkedConvert('goal', (v) => v as String),
      durationSeconds: $checkedConvert(
        'duration_seconds',
        (v) => (v as num?)?.toInt(),
      ),
      tone: $checkedConvert('tone', (v) => v as String),
      cta: $checkedConvert('cta', (v) => v as String?),
      hamsterId: $checkedConvert('hamster_id', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'campaignType': 'campaign_type',
    'durationSeconds': 'duration_seconds',
    'hamsterId': 'hamster_id',
  },
);

Map<String, dynamic> _$GrowthCampaignGenerateRequestToJson(
  GrowthCampaignGenerateRequest instance,
) => <String, dynamic>{
  'campaign_type':
      _$GrowthCampaignGenerateRequestCampaignTypeEnumEnumMap[instance
          .campaignType]!,
  'platform': instance.platform,
  'goal': instance.goal,
  'duration_seconds': ?instance.durationSeconds,
  'tone': instance.tone,
  'cta': ?instance.cta,
  'hamster_id': instance.hamsterId,
};

const _$GrowthCampaignGenerateRequestCampaignTypeEnumEnumMap = {
  GrowthCampaignGenerateRequestCampaignTypeEnum.video: 'video',
  GrowthCampaignGenerateRequestCampaignTypeEnum.live: 'live',
};
