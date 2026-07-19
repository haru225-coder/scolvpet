//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_crm_reservation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCrmReservationRequest {
  /// Returns a new [CreateCrmReservationRequest] instance.
  CreateCrmReservationRequest({

    required  this.contactId,

     this.hamsterId,

     this.title,

     this.notes,
  });

  @JsonKey(

    name: r'contact_id',
    required: true,
    includeIfNull: false,
  )


  final String contactId;



  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCrmReservationRequest &&
      other.contactId == contactId &&
      other.hamsterId == hamsterId &&
      other.title == title &&
      other.notes == notes;

    @override
    int get hashCode =>
        contactId.hashCode +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        title.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CreateCrmReservationRequest.fromJson(Map<String, dynamic> json) => _$CreateCrmReservationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCrmReservationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
