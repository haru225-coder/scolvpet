//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/mating_observation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'record_observation_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecordObservationResponseData {
  /// Returns a new [RecordObservationResponseData] instance.
  RecordObservationResponseData({

    required  this.observation,

    required  this.pairingAttemptVersion,

     this.baselineCandidateAt,
  });

  @JsonKey(

    name: r'observation',
    required: true,
    includeIfNull: false,
  )


  final MatingObservation observation;



          // minimum: 1
  @JsonKey(

    name: r'pairing_attempt_version',
    required: true,
    includeIfNull: false,
  )


  final int pairingAttemptVersion;



  @JsonKey(

    name: r'baseline_candidate_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? baselineCandidateAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RecordObservationResponseData &&
      other.observation == observation &&
      other.pairingAttemptVersion == pairingAttemptVersion &&
      other.baselineCandidateAt == baselineCandidateAt;

    @override
    int get hashCode =>
        observation.hashCode +
        pairingAttemptVersion.hashCode +
        (baselineCandidateAt == null ? 0 : baselineCandidateAt.hashCode);

  factory RecordObservationResponseData.fromJson(Map<String, dynamic> json) => _$RecordObservationResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$RecordObservationResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
