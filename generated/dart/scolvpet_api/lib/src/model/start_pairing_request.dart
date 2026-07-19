//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'start_pairing_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StartPairingRequest {
  /// Returns a new [StartPairingRequest] instance.
  StartPairingRequest({

    required  this.enclosureId,

    required  this.startedAt,

    required  this.timezone,

     this.notes,
  });

  @JsonKey(

    name: r'enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String enclosureId;



  @JsonKey(

    name: r'started_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



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
    bool operator ==(Object other) => identical(this, other) || other is StartPairingRequest &&
      other.enclosureId == enclosureId &&
      other.startedAt == startedAt &&
      other.timezone == timezone &&
      other.notes == notes;

    @override
    int get hashCode =>
        enclosureId.hashCode +
        startedAt.hashCode +
        timezone.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory StartPairingRequest.fromJson(Map<String, dynamic> json) => _$StartPairingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StartPairingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
