//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_crm_handover_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCrmHandoverRequest {
  /// Returns a new [CreateCrmHandoverRequest] instance.
  CreateCrmHandoverRequest({

    required  this.contactId,

     this.reservationId,

     this.hamsterId,

     this.notes,

     this.scheduledAt,
  });

  @JsonKey(

    name: r'contact_id',
    required: true,
    includeIfNull: false,
  )


  final String contactId;



  @JsonKey(

    name: r'reservation_id',
    required: false,
    includeIfNull: false,
  )


  final String? reservationId;



  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(

    name: r'scheduled_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? scheduledAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCrmHandoverRequest &&
      other.contactId == contactId &&
      other.reservationId == reservationId &&
      other.hamsterId == hamsterId &&
      other.notes == notes &&
      other.scheduledAt == scheduledAt;

    @override
    int get hashCode =>
        contactId.hashCode +
        (reservationId == null ? 0 : reservationId.hashCode) +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (scheduledAt == null ? 0 : scheduledAt.hashCode);

  factory CreateCrmHandoverRequest.fromJson(Map<String, dynamic> json) => _$CreateCrmHandoverRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCrmHandoverRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
