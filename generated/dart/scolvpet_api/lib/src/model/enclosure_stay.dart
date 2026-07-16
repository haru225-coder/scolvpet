//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_stay.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureStay {
  /// Returns a new [EnclosureStay] instance.
  EnclosureStay({

    required  this.id,

    required  this.enclosureId,

    required  this.hamsterId,

    required  this.purpose,

     this.pairingAttemptId,

    required  this.startedAt,

     this.endedAt,

     this.reason,

    required  this.version,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String enclosureId;



  @JsonKey(
    
    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



  @JsonKey(
    
    name: r'purpose',
    required: true,
    includeIfNull: false,
  )


  final EnclosureStayPurposeEnum purpose;



  @JsonKey(
    
    name: r'pairing_attempt_id',
    required: false,
    includeIfNull: false,
  )


  final String? pairingAttemptId;



  @JsonKey(
    
    name: r'started_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'ended_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endedAt;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureStay &&
      other.id == id &&
      other.enclosureId == enclosureId &&
      other.hamsterId == hamsterId &&
      other.purpose == purpose &&
      other.pairingAttemptId == pairingAttemptId &&
      other.startedAt == startedAt &&
      other.endedAt == endedAt &&
      other.reason == reason &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        enclosureId.hashCode +
        hamsterId.hashCode +
        purpose.hashCode +
        (pairingAttemptId == null ? 0 : pairingAttemptId.hashCode) +
        startedAt.hashCode +
        (endedAt == null ? 0 : endedAt.hashCode) +
        (reason == null ? 0 : reason.hashCode) +
        version.hashCode;

  factory EnclosureStay.fromJson(Map<String, dynamic> json) => _$EnclosureStayFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureStayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum EnclosureStayPurposeEnum {
@JsonValue(r'single')
single(r'single'),
@JsonValue(r'pairing_temp')
pairingTemp(r'pairing_temp'),
@JsonValue(r'gestation')
gestation(r'gestation'),
@JsonValue(r'isolation')
isolation(r'isolation'),
@JsonValue(r'dam_with_litter')
damWithLitter(r'dam_with_litter');

const EnclosureStayPurposeEnum(this.value);

final String value;

@override
String toString() => value;
}


