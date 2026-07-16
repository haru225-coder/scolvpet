//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_stay_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureStayCreateRequest {
  /// Returns a new [EnclosureStayCreateRequest] instance.
  EnclosureStayCreateRequest({

    required  this.hamsterId,

    required  this.purpose,

     this.pairingAttemptId,

    required  this.startedAt,

     this.previousStayId,

     this.reason,
  });

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


  final EnclosureStayCreateRequestPurposeEnum purpose;



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
    
    name: r'previous_stay_id',
    required: false,
    includeIfNull: false,
  )


  final String? previousStayId;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureStayCreateRequest &&
      other.hamsterId == hamsterId &&
      other.purpose == purpose &&
      other.pairingAttemptId == pairingAttemptId &&
      other.startedAt == startedAt &&
      other.previousStayId == previousStayId &&
      other.reason == reason;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        purpose.hashCode +
        (pairingAttemptId == null ? 0 : pairingAttemptId.hashCode) +
        startedAt.hashCode +
        (previousStayId == null ? 0 : previousStayId.hashCode) +
        (reason == null ? 0 : reason.hashCode);

  factory EnclosureStayCreateRequest.fromJson(Map<String, dynamic> json) => _$EnclosureStayCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureStayCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum EnclosureStayCreateRequestPurposeEnum {
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

const EnclosureStayCreateRequestPurposeEnum(this.value);

final String value;

@override
String toString() => value;
}


