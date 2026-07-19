//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_campaign_generate_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthCampaignGenerateRequest {
  /// Returns a new [GrowthCampaignGenerateRequest] instance.
  GrowthCampaignGenerateRequest({

    required  this.campaignType,

    required  this.platform,

    required  this.goal,

     this.durationSeconds,

    required  this.tone,

     this.cta,

    required  this.hamsterId,
  });

  @JsonKey(

    name: r'campaign_type',
    required: true,
    includeIfNull: false,
  )


  final GrowthCampaignGenerateRequestCampaignTypeEnum campaignType;



  @JsonKey(

    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final String platform;



  @JsonKey(

    name: r'goal',
    required: true,
    includeIfNull: false,
  )


  final String goal;



          // minimum: 1
          // maximum: 7200
  @JsonKey(

    name: r'duration_seconds',
    required: false,
    includeIfNull: false,
  )


  final int? durationSeconds;



  @JsonKey(

    name: r'tone',
    required: true,
    includeIfNull: false,
  )


  final String tone;



  @JsonKey(

    name: r'cta',
    required: false,
    includeIfNull: false,
  )


  final String? cta;



  @JsonKey(

    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthCampaignGenerateRequest &&
      other.campaignType == campaignType &&
      other.platform == platform &&
      other.goal == goal &&
      other.durationSeconds == durationSeconds &&
      other.tone == tone &&
      other.cta == cta &&
      other.hamsterId == hamsterId;

    @override
    int get hashCode =>
        campaignType.hashCode +
        platform.hashCode +
        goal.hashCode +
        durationSeconds.hashCode +
        tone.hashCode +
        cta.hashCode +
        hamsterId.hashCode;

  factory GrowthCampaignGenerateRequest.fromJson(Map<String, dynamic> json) => _$GrowthCampaignGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthCampaignGenerateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GrowthCampaignGenerateRequestCampaignTypeEnum {
@JsonValue(r'video')
video(r'video'),
@JsonValue(r'live')
live(r'live');

const GrowthCampaignGenerateRequestCampaignTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
