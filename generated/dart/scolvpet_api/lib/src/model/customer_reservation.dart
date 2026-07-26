//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/customer_reservation_hamster.dart';
import 'package:scolvpet_api/src/model/customer_reservation_documents_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_reservation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerReservation {
  /// Returns a new [CustomerReservation] instance.
  CustomerReservation({

     this.id,

     this.title,

     this.status,

     this.reservedAt,

     this.holdExpiresAt,

     this.updatedAt,

     this.version,

     this.hamster,

     this.documents,
  });

  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(

    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(

    name: r'reserved_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? reservedAt;



  @JsonKey(

    name: r'hold_expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? holdExpiresAt;



  @JsonKey(

    name: r'updated_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



  @JsonKey(

    name: r'version',
    required: false,
    includeIfNull: false,
  )


  final int? version;



  @JsonKey(

    name: r'hamster',
    required: false,
    includeIfNull: false,
  )


  final CustomerReservationHamster? hamster;



  @JsonKey(

    name: r'documents',
    required: false,
    includeIfNull: false,
  )


  final List<CustomerReservationDocumentsInner>? documents;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerReservation &&
      other.id == id &&
      other.title == title &&
      other.status == status &&
      other.reservedAt == reservedAt &&
      other.holdExpiresAt == holdExpiresAt &&
      other.updatedAt == updatedAt &&
      other.version == version &&
      other.hamster == hamster &&
      other.documents == documents;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        status.hashCode +
        reservedAt.hashCode +
        holdExpiresAt.hashCode +
        updatedAt.hashCode +
        version.hashCode +
        hamster.hashCode +
        documents.hashCode;

  factory CustomerReservation.fromJson(Map<String, dynamic> json) => _$CustomerReservationFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerReservationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
