//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'crm_reservation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CrmReservation {
  /// Returns a new [CrmReservation] instance.
  CrmReservation({

    required  this.id,

    required  this.contactId,

     this.hamsterId,

    required  this.title,

    required  this.status,

    required  this.reservedAt,

     this.notes,

    required  this.version,

     this.contactName,

     this.hamsterName,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CrmReservationStatusEnum status;



  @JsonKey(

    name: r'reserved_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime reservedAt;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'contact_name',
    required: false,
    includeIfNull: false,
  )


  final String? contactName;



  @JsonKey(

    name: r'hamster_name',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CrmReservation &&
      other.id == id &&
      other.contactId == contactId &&
      other.hamsterId == hamsterId &&
      other.title == title &&
      other.status == status &&
      other.reservedAt == reservedAt &&
      other.notes == notes &&
      other.version == version &&
      other.contactName == contactName &&
      other.hamsterName == hamsterName;

    @override
    int get hashCode =>
        id.hashCode +
        contactId.hashCode +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        title.hashCode +
        status.hashCode +
        reservedAt.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        contactName.hashCode +
        (hamsterName == null ? 0 : hamsterName.hashCode);

  factory CrmReservation.fromJson(Map<String, dynamic> json) => _$CrmReservationFromJson(json);

  Map<String, dynamic> toJson() => _$CrmReservationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CrmReservationStatusEnum {
@JsonValue(r'held')
held(r'held'),
@JsonValue(r'confirmed')
confirmed(r'confirmed'),
@JsonValue(r'handed_over')
handedOver(r'handed_over'),
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const CrmReservationStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
