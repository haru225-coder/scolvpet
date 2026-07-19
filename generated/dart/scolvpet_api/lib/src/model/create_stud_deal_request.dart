//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_stud_deal_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateStudDealRequest {
  /// Returns a new [CreateStudDealRequest] instance.
  CreateStudDealRequest({

     this.listingId,

    required  this.side,

     this.myHamsterLabel,

    required  this.partnerCatteryName,

     this.partnerContact,

     this.partnerAnimalLabel,

     this.feeCents,

     this.currency = 'CNY',

     this.notes,
  });

  @JsonKey(

    name: r'listing_id',
    required: false,
    includeIfNull: false,
  )


  final String? listingId;



  @JsonKey(

    name: r'side',
    required: true,
    includeIfNull: false,
  )


  final CreateStudDealRequestSideEnum side;



  @JsonKey(

    name: r'my_hamster_label',
    required: false,
    includeIfNull: false,
  )


  final String? myHamsterLabel;



  @JsonKey(

    name: r'partner_cattery_name',
    required: true,
    includeIfNull: false,
  )


  final String partnerCatteryName;



  @JsonKey(

    name: r'partner_contact',
    required: false,
    includeIfNull: false,
  )


  final String? partnerContact;



  @JsonKey(

    name: r'partner_animal_label',
    required: false,
    includeIfNull: false,
  )


  final String? partnerAnimalLabel;



          // minimum: 0
  @JsonKey(

    name: r'fee_cents',
    required: false,
    includeIfNull: false,
  )


  final int? feeCents;



  @JsonKey(
    defaultValue: 'CNY',
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateStudDealRequest &&
      other.listingId == listingId &&
      other.side == side &&
      other.myHamsterLabel == myHamsterLabel &&
      other.partnerCatteryName == partnerCatteryName &&
      other.partnerContact == partnerContact &&
      other.partnerAnimalLabel == partnerAnimalLabel &&
      other.feeCents == feeCents &&
      other.currency == currency &&
      other.notes == notes;

    @override
    int get hashCode =>
        (listingId == null ? 0 : listingId.hashCode) +
        side.hashCode +
        (myHamsterLabel == null ? 0 : myHamsterLabel.hashCode) +
        partnerCatteryName.hashCode +
        (partnerContact == null ? 0 : partnerContact.hashCode) +
        (partnerAnimalLabel == null ? 0 : partnerAnimalLabel.hashCode) +
        (feeCents == null ? 0 : feeCents.hashCode) +
        currency.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CreateStudDealRequest.fromJson(Map<String, dynamic> json) => _$CreateStudDealRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStudDealRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateStudDealRequestSideEnum {
@JsonValue(r'provider')
provider(r'provider'),
@JsonValue(r'requester')
requester(r'requester');

const CreateStudDealRequestSideEnum(this.value);

final String value;

@override
String toString() => value;
}
