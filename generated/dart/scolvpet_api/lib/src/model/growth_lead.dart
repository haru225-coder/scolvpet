//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_lead.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthLead {
  /// Returns a new [GrowthLead] instance.
  GrowthLead({

    required  this.id,

    required  this.contactId,

    required  this.name,

     this.phone,

     this.wechat,

     this.campaignId,

     this.campaignCode,

     this.campaignTitle,

     this.consultationId,

    required  this.sourceChannel,

     this.landingPath,

     this.interestHamsterId,

     this.interestHamsterName,

     this.intentSummary,

    required  this.createdAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'contact_id',
    required: true,
    includeIfNull: false,
  )


  final String contactId;



  @JsonKey(

    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(

    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(

    name: r'wechat',
    required: false,
    includeIfNull: false,
  )


  final String? wechat;



  @JsonKey(

    name: r'campaign_id',
    required: false,
    includeIfNull: false,
  )


  final String? campaignId;



  @JsonKey(

    name: r'campaign_code',
    required: false,
    includeIfNull: false,
  )


  final String? campaignCode;



  @JsonKey(

    name: r'campaign_title',
    required: false,
    includeIfNull: false,
  )


  final String? campaignTitle;



  @JsonKey(

    name: r'consultation_id',
    required: false,
    includeIfNull: false,
  )


  final String? consultationId;



  @JsonKey(

    name: r'source_channel',
    required: true,
    includeIfNull: false,
  )


  final String sourceChannel;



  @JsonKey(

    name: r'landing_path',
    required: false,
    includeIfNull: false,
  )


  final String? landingPath;



  @JsonKey(

    name: r'interest_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? interestHamsterId;



  @JsonKey(

    name: r'interest_hamster_name',
    required: false,
    includeIfNull: false,
  )


  final String? interestHamsterName;



  @JsonKey(

    name: r'intent_summary',
    required: false,
    includeIfNull: false,
  )


  final String? intentSummary;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthLead &&
      other.id == id &&
      other.contactId == contactId &&
      other.name == name &&
      other.phone == phone &&
      other.wechat == wechat &&
      other.campaignId == campaignId &&
      other.campaignCode == campaignCode &&
      other.campaignTitle == campaignTitle &&
      other.consultationId == consultationId &&
      other.sourceChannel == sourceChannel &&
      other.landingPath == landingPath &&
      other.interestHamsterId == interestHamsterId &&
      other.interestHamsterName == interestHamsterName &&
      other.intentSummary == intentSummary &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        contactId.hashCode +
        name.hashCode +
        phone.hashCode +
        wechat.hashCode +
        (campaignId == null ? 0 : campaignId.hashCode) +
        (campaignCode == null ? 0 : campaignCode.hashCode) +
        (campaignTitle == null ? 0 : campaignTitle.hashCode) +
        (consultationId == null ? 0 : consultationId.hashCode) +
        sourceChannel.hashCode +
        (landingPath == null ? 0 : landingPath.hashCode) +
        (interestHamsterId == null ? 0 : interestHamsterId.hashCode) +
        (interestHamsterName == null ? 0 : interestHamsterName.hashCode) +
        (intentSummary == null ? 0 : intentSummary.hashCode) +
        createdAt.hashCode;

  factory GrowthLead.fromJson(Map<String, dynamic> json) => _$GrowthLeadFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthLeadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
