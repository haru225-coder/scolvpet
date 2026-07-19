//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'crm_handover.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CrmHandover {
  /// Returns a new [CrmHandover] instance.
  CrmHandover({

    required  this.id,

    required  this.contactId,

     this.reservationId,

     this.hamsterId,

    required  this.status,

    required  this.scheduledAt,

     this.completedAt,

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

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CrmHandoverStatusEnum status;



  @JsonKey(

    name: r'scheduled_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime scheduledAt;



  @JsonKey(

    name: r'completed_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? completedAt;



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
    bool operator ==(Object other) => identical(this, other) || other is CrmHandover &&
      other.id == id &&
      other.contactId == contactId &&
      other.reservationId == reservationId &&
      other.hamsterId == hamsterId &&
      other.status == status &&
      other.scheduledAt == scheduledAt &&
      other.completedAt == completedAt &&
      other.notes == notes &&
      other.version == version &&
      other.contactName == contactName &&
      other.hamsterName == hamsterName;

    @override
    int get hashCode =>
        id.hashCode +
        contactId.hashCode +
        (reservationId == null ? 0 : reservationId.hashCode) +
        (hamsterId == null ? 0 : hamsterId.hashCode) +
        status.hashCode +
        scheduledAt.hashCode +
        (completedAt == null ? 0 : completedAt.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        contactName.hashCode +
        (hamsterName == null ? 0 : hamsterName.hashCode);

  factory CrmHandover.fromJson(Map<String, dynamic> json) => _$CrmHandoverFromJson(json);

  Map<String, dynamic> toJson() => _$CrmHandoverToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CrmHandoverStatusEnum {
@JsonValue(r'scheduled')
scheduled(r'scheduled'),
@JsonValue(r'completed')
completed(r'completed'),
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const CrmHandoverStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
