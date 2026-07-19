//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pairing_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'separate_pairing_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeparatePairingRequest {
  /// Returns a new [SeparatePairingRequest] instance.
  SeparatePairingRequest({

    required  this.endedAt,

    required  this.separatedAt,

    required  this.result,

    required  this.sireDestinationEnclosureId,

    required  this.damDestinationEnclosureId,

    required  this.safetyStop,

    required  this.timezone,

     this.notes,
  });

  @JsonKey(

    name: r'ended_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime endedAt;



  @JsonKey(

    name: r'separated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime separatedAt;



  @JsonKey(

    name: r'result',
    required: true,
    includeIfNull: false,
  )


  final PairingResult result;



  @JsonKey(

    name: r'sire_destination_enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String sireDestinationEnclosureId;



  @JsonKey(

    name: r'dam_destination_enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String damDestinationEnclosureId;



  @JsonKey(

    name: r'safety_stop',
    required: true,
    includeIfNull: false,
  )


  final bool safetyStop;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SeparatePairingRequest &&
      other.endedAt == endedAt &&
      other.separatedAt == separatedAt &&
      other.result == result &&
      other.sireDestinationEnclosureId == sireDestinationEnclosureId &&
      other.damDestinationEnclosureId == damDestinationEnclosureId &&
      other.safetyStop == safetyStop &&
      other.timezone == timezone &&
      other.notes == notes;

    @override
    int get hashCode =>
        endedAt.hashCode +
        separatedAt.hashCode +
        result.hashCode +
        sireDestinationEnclosureId.hashCode +
        damDestinationEnclosureId.hashCode +
        safetyStop.hashCode +
        timezone.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory SeparatePairingRequest.fromJson(Map<String, dynamic> json) => _$SeparatePairingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SeparatePairingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
