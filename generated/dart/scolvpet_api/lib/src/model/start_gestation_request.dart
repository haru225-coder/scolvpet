//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_gestation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartGestationRequest {
  /// Returns a new [StartGestationRequest] instance.
  StartGestationRequest({

    required  this.pairingAttemptId,

    required  this.result,

    required  this.baselineAt,

    required  this.timezone,

     this.notes,
  });

  @JsonKey(

    name: r'pairing_attempt_id',
    required: true,
    includeIfNull: false,
  )


  final String pairingAttemptId;



  @JsonKey(

    name: r'result',
    required: true,
    includeIfNull: false,
  )


  final StartGestationRequestResultEnum result;



  @JsonKey(

    name: r'baseline_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime baselineAt;



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
    bool operator ==(Object other) => identical(this, other) || other is StartGestationRequest &&
      other.pairingAttemptId == pairingAttemptId &&
      other.result == result &&
      other.baselineAt == baselineAt &&
      other.timezone == timezone &&
      other.notes == notes;

    @override
    int get hashCode =>
        pairingAttemptId.hashCode +
        result.hashCode +
        baselineAt.hashCode +
        timezone.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory StartGestationRequest.fromJson(Map<String, dynamic> json) => _$StartGestationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StartGestationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum StartGestationRequestResultEnum {
@JsonValue(r'effective')
effective(r'effective'),
@JsonValue(r'uncertain')
uncertain(r'uncertain');

const StartGestationRequestResultEnum(this.value);

final String value;

@override
String toString() => value;
}
