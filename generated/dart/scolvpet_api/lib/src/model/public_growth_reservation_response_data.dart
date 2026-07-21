//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_reservation_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthReservationResponseData {
  /// Returns a new [PublicGrowthReservationResponseData] instance.
  PublicGrowthReservationResponseData({

    required  this.reservationId,

    required  this.contactId,

     this.contactReused,

    required  this.hamsterId,

    required  this.status,

     this.title,

     this.siteId,
  });

  @JsonKey(

    name: r'reservation_id',
    required: true,
    includeIfNull: false,
  )


  final String reservationId;



  @JsonKey(

    name: r'contact_id',
    required: true,
    includeIfNull: false,
  )


  final String contactId;



  @JsonKey(

    name: r'contact_reused',
    required: false,
    includeIfNull: false,
  )


  final bool? contactReused;



  @JsonKey(

    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final PublicGrowthReservationResponseDataStatusEnum status;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(

    name: r'site_id',
    required: false,
    includeIfNull: false,
  )


  final String? siteId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthReservationResponseData &&
      other.reservationId == reservationId &&
      other.contactId == contactId &&
      other.contactReused == contactReused &&
      other.hamsterId == hamsterId &&
      other.status == status &&
      other.title == title &&
      other.siteId == siteId;

    @override
    int get hashCode =>
        reservationId.hashCode +
        contactId.hashCode +
        contactReused.hashCode +
        hamsterId.hashCode +
        status.hashCode +
        title.hashCode +
        siteId.hashCode;

  factory PublicGrowthReservationResponseData.fromJson(Map<String, dynamic> json) => _$PublicGrowthReservationResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthReservationResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PublicGrowthReservationResponseDataStatusEnum {
@JsonValue(r'held')
held(r'held');

const PublicGrowthReservationResponseDataStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
