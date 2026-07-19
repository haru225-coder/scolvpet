//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_consult_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthConsultRequest {
  /// Returns a new [PublicGrowthConsultRequest] instance.
  PublicGrowthConsultRequest({

    required  this.message,

     this.sessionToken,

     this.campaignCode,

     this.interestedHamsterId,

     this.landingPath,
  });

  @JsonKey(

    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(

    name: r'session_token',
    required: false,
    includeIfNull: false,
  )


  final String? sessionToken;



  @JsonKey(

    name: r'campaign_code',
    required: false,
    includeIfNull: false,
  )


  final String? campaignCode;



  @JsonKey(

    name: r'interested_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? interestedHamsterId;



  @JsonKey(

    name: r'landing_path',
    required: false,
    includeIfNull: false,
  )


  final String? landingPath;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthConsultRequest &&
      other.message == message &&
      other.sessionToken == sessionToken &&
      other.campaignCode == campaignCode &&
      other.interestedHamsterId == interestedHamsterId &&
      other.landingPath == landingPath;

    @override
    int get hashCode =>
        message.hashCode +
        sessionToken.hashCode +
        campaignCode.hashCode +
        interestedHamsterId.hashCode +
        landingPath.hashCode;

  factory PublicGrowthConsultRequest.fromJson(Map<String, dynamic> json) => _$PublicGrowthConsultRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthConsultRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
