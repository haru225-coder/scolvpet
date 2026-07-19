//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pairing_attempt.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_pairing_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartPairingResponseData {
  /// Returns a new [StartPairingResponseData] instance.
  StartPairingResponseData({

    required  this.breedingPlan,

    required  this.pairingAttempt,
  });

  @JsonKey(

    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(

    name: r'pairing_attempt',
    required: true,
    includeIfNull: false,
  )


  final PairingAttempt pairingAttempt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StartPairingResponseData &&
      other.breedingPlan == breedingPlan &&
      other.pairingAttempt == pairingAttempt;

    @override
    int get hashCode =>
        breedingPlan.hashCode +
        pairingAttempt.hashCode;

  factory StartPairingResponseData.fromJson(Map<String, dynamic> json) => _$StartPairingResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$StartPairingResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
