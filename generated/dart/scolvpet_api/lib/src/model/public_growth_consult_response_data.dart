//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/growth_public_fact.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_consult_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthConsultResponseData {
  /// Returns a new [PublicGrowthConsultResponseData] instance.
  PublicGrowthConsultResponseData({

    required  this.sessionToken,

    required  this.consultationId,

    required  this.answer,

    required  this.recommendations,

    required  this.facts,

    required  this.handoffSuggested,
  });

  @JsonKey(

    name: r'session_token',
    required: true,
    includeIfNull: false,
  )


  final String sessionToken;



  @JsonKey(

    name: r'consultation_id',
    required: true,
    includeIfNull: false,
  )


  final String consultationId;



  @JsonKey(

    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;



  @JsonKey(

    name: r'recommendations',
    required: true,
    includeIfNull: false,
  )


  final List<Map<String, Object>> recommendations;



  @JsonKey(

    name: r'facts',
    required: true,
    includeIfNull: false,
  )


  final List<GrowthPublicFact> facts;



  @JsonKey(

    name: r'handoff_suggested',
    required: true,
    includeIfNull: false,
  )


  final bool handoffSuggested;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthConsultResponseData &&
      other.sessionToken == sessionToken &&
      other.consultationId == consultationId &&
      other.answer == answer &&
      other.recommendations == recommendations &&
      other.facts == facts &&
      other.handoffSuggested == handoffSuggested;

    @override
    int get hashCode =>
        sessionToken.hashCode +
        consultationId.hashCode +
        answer.hashCode +
        recommendations.hashCode +
        facts.hashCode +
        handoffSuggested.hashCode;

  factory PublicGrowthConsultResponseData.fromJson(Map<String, dynamic> json) => _$PublicGrowthConsultResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthConsultResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
