//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_reservation_hamster.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerReservationHamster {
  /// Returns a new [CustomerReservationHamster] instance.
  CustomerReservationHamster({

     this.hamsterId,

     this.publicName,

     this.summary,

     this.priceLabel,
  });

  @JsonKey(

    name: r'hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? hamsterId;



  @JsonKey(

    name: r'public_name',
    required: false,
    includeIfNull: false,
  )


  final String? publicName;



  @JsonKey(

    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(

    name: r'price_label',
    required: false,
    includeIfNull: false,
  )


  final String? priceLabel;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerReservationHamster &&
      other.hamsterId == hamsterId &&
      other.publicName == publicName &&
      other.summary == summary &&
      other.priceLabel == priceLabel;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        publicName.hashCode +
        summary.hashCode +
        priceLabel.hashCode;

  factory CustomerReservationHamster.fromJson(Map<String, dynamic> json) => _$CustomerReservationHamsterFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerReservationHamsterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
