//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_lead_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthLeadRequest {
  /// Returns a new [PublicGrowthLeadRequest] instance.
  PublicGrowthLeadRequest({

    required  this.name,

     this.phone,

     this.wechat,

     this.campaignCode,

     this.consultationToken,

     this.interestedHamsterId,

     this.intentSummary,

     this.landingPath,
  });

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

    name: r'campaign_code',
    required: false,
    includeIfNull: false,
  )


  final String? campaignCode;



  @JsonKey(

    name: r'consultation_token',
    required: false,
    includeIfNull: false,
  )


  final String? consultationToken;



  @JsonKey(

    name: r'interested_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? interestedHamsterId;



  @JsonKey(

    name: r'intent_summary',
    required: false,
    includeIfNull: false,
  )


  final String? intentSummary;



  @JsonKey(

    name: r'landing_path',
    required: false,
    includeIfNull: false,
  )


  final String? landingPath;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthLeadRequest &&
      other.name == name &&
      other.phone == phone &&
      other.wechat == wechat &&
      other.campaignCode == campaignCode &&
      other.consultationToken == consultationToken &&
      other.interestedHamsterId == interestedHamsterId &&
      other.intentSummary == intentSummary &&
      other.landingPath == landingPath;

    @override
    int get hashCode =>
        name.hashCode +
        phone.hashCode +
        wechat.hashCode +
        campaignCode.hashCode +
        consultationToken.hashCode +
        interestedHamsterId.hashCode +
        intentSummary.hashCode +
        landingPath.hashCode;

  factory PublicGrowthLeadRequest.fromJson(Map<String, dynamic> json) => _$PublicGrowthLeadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthLeadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
