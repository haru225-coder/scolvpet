//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/enclosure_stay.dart';
import 'package:scolvpet_api/src/model/pairing_attempt.dart';
import 'package:scolvpet_api/src/model/breeding_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'separate_pairing_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeparatePairingResponseData {
  /// Returns a new [SeparatePairingResponseData] instance.
  SeparatePairingResponseData({

    required  this.pairingAttempt,

    required  this.breedingPlan,

    required  this.createdStays,

    required  this.createdTaskIds,
  });

  @JsonKey(

    name: r'pairing_attempt',
    required: true,
    includeIfNull: false,
  )


  final PairingAttempt pairingAttempt;



  @JsonKey(

    name: r'breeding_plan',
    required: true,
    includeIfNull: false,
  )


  final BreedingPlan breedingPlan;



  @JsonKey(

    name: r'created_stays',
    required: true,
    includeIfNull: false,
  )


  final List<EnclosureStay> createdStays;



  @JsonKey(

    name: r'created_task_ids',
    required: true,
    includeIfNull: false,
  )


  final List<String> createdTaskIds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SeparatePairingResponseData &&
      other.pairingAttempt == pairingAttempt &&
      other.breedingPlan == breedingPlan &&
      other.createdStays == createdStays &&
      other.createdTaskIds == createdTaskIds;

    @override
    int get hashCode =>
        pairingAttempt.hashCode +
        breedingPlan.hashCode +
        createdStays.hashCode +
        createdTaskIds.hashCode;

  factory SeparatePairingResponseData.fromJson(Map<String, dynamic> json) => _$SeparatePairingResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SeparatePairingResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
