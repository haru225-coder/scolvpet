//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'publish_breeding_plan_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublishBreedingPlanRequest {
  /// Returns a new [PublishBreedingPlanRequest] instance.
  PublishBreedingPlanRequest({

    required  this.plannedPairingAt,

    required  this.pairingEnclosureId,

    required  this.timezone,

     this.kinshipOverrideReason,
  });

  @JsonKey(

    name: r'planned_pairing_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime plannedPairingAt;



  @JsonKey(

    name: r'pairing_enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String pairingEnclosureId;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'kinship_override_reason',
    required: false,
    includeIfNull: false,
  )


  final String? kinshipOverrideReason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublishBreedingPlanRequest &&
      other.plannedPairingAt == plannedPairingAt &&
      other.pairingEnclosureId == pairingEnclosureId &&
      other.timezone == timezone &&
      other.kinshipOverrideReason == kinshipOverrideReason;

    @override
    int get hashCode =>
        plannedPairingAt.hashCode +
        pairingEnclosureId.hashCode +
        timezone.hashCode +
        (kinshipOverrideReason == null ? 0 : kinshipOverrideReason.hashCode);

  factory PublishBreedingPlanRequest.fromJson(Map<String, dynamic> json) => _$PublishBreedingPlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PublishBreedingPlanRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
