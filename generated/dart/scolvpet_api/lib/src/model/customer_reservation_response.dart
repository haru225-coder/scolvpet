//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/customer_reservation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_reservation_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerReservationResponse {
  /// Returns a new [CustomerReservationResponse] instance.
  CustomerReservationResponse({

     this.data,

     this.meta,
  });

  @JsonKey(

    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final CustomerReservation? data;



  @JsonKey(

    name: r'meta',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerReservationResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory CustomerReservationResponse.fromJson(Map<String, dynamic> json) => _$CustomerReservationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerReservationResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
