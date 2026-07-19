//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/growth_script.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_campaign.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthCampaign {
  /// Returns a new [GrowthCampaign] instance.
  GrowthCampaign({

    required  this.id,

    required  this.campaignCode,

    required  this.campaignType,

    required  this.platform,

    required  this.status,

    required  this.subjectType,

    required  this.subjectId,

    required  this.title,

    required  this.goal,

     this.durationSeconds,

    required  this.tone,

    required  this.cta,

     this.factsSnapshot,

    required  this.script,

    required  this.modelName,

    required  this.promptVersion,

     this.publishedAt,

    required  this.version,

     this.publicUrlPath,

     this.createdAt,

     this.updatedAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'campaign_code',
    required: true,
    includeIfNull: false,
  )


  final String campaignCode;



  @JsonKey(

    name: r'campaign_type',
    required: true,
    includeIfNull: false,
  )


  final GrowthCampaignCampaignTypeEnum campaignType;



  @JsonKey(

    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final String platform;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final GrowthCampaignStatusEnum status;



  @JsonKey(

    name: r'subject_type',
    required: true,
    includeIfNull: false,
  )


  final String subjectType;



  @JsonKey(

    name: r'subject_id',
    required: true,
    includeIfNull: false,
  )


  final String subjectId;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'goal',
    required: true,
    includeIfNull: false,
  )


  final String goal;



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
    required: true,
    includeIfNull: false,
  )


  final String cta;



  @JsonKey(

    name: r'facts_snapshot',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? factsSnapshot;



  @JsonKey(

    name: r'script',
    required: true,
    includeIfNull: false,
  )


  final GrowthScript script;



  @JsonKey(

    name: r'model_name',
    required: true,
    includeIfNull: false,
  )


  final String modelName;



  @JsonKey(

    name: r'prompt_version',
    required: true,
    includeIfNull: false,
  )


  final String promptVersion;



  @JsonKey(

    name: r'published_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? publishedAt;



  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'public_url_path',
    required: false,
    includeIfNull: false,
  )


  final String? publicUrlPath;



  @JsonKey(

    name: r'created_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(

    name: r'updated_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthCampaign &&
      other.id == id &&
      other.campaignCode == campaignCode &&
      other.campaignType == campaignType &&
      other.platform == platform &&
      other.status == status &&
      other.subjectType == subjectType &&
      other.subjectId == subjectId &&
      other.title == title &&
      other.goal == goal &&
      other.durationSeconds == durationSeconds &&
      other.tone == tone &&
      other.cta == cta &&
      other.factsSnapshot == factsSnapshot &&
      other.script == script &&
      other.modelName == modelName &&
      other.promptVersion == promptVersion &&
      other.publishedAt == publishedAt &&
      other.version == version &&
      other.publicUrlPath == publicUrlPath &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        campaignCode.hashCode +
        campaignType.hashCode +
        platform.hashCode +
        status.hashCode +
        subjectType.hashCode +
        subjectId.hashCode +
        title.hashCode +
        goal.hashCode +
        (durationSeconds == null ? 0 : durationSeconds.hashCode) +
        tone.hashCode +
        cta.hashCode +
        factsSnapshot.hashCode +
        script.hashCode +
        modelName.hashCode +
        promptVersion.hashCode +
        (publishedAt == null ? 0 : publishedAt.hashCode) +
        version.hashCode +
        (publicUrlPath == null ? 0 : publicUrlPath.hashCode) +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory GrowthCampaign.fromJson(Map<String, dynamic> json) => _$GrowthCampaignFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthCampaignToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GrowthCampaignCampaignTypeEnum {
@JsonValue(r'video')
video(r'video'),
@JsonValue(r'live')
live(r'live');

const GrowthCampaignCampaignTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum GrowthCampaignStatusEnum {
@JsonValue(r'draft')
draft(r'draft'),
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'published')
published(r'published'),
@JsonValue(r'archived')
archived(r'archived');

const GrowthCampaignStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
