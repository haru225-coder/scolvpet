//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stud_deal.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StudDeal {
  /// Returns a new [StudDeal] instance.
  StudDeal({

    required  this.id,

     this.listingId,

    required  this.side,

    required  this.status,

     this.myHamsterLabel,

    required  this.partnerCatteryName,

     this.partnerContact,

     this.partnerAnimalLabel,

    required  this.feeCents,

    required  this.currency,

     this.notes,

     this.confirmedAt,

     this.startedAt,

     this.completedAt,

     this.cancelledAt,

    required  this.version,

    required  this.updatedAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



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


  final StudDealSideEnum side;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final StudDealStatusEnum status;



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
    required: true,
    includeIfNull: false,
  )


  final int feeCents;



  @JsonKey(

    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(

    name: r'confirmed_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? confirmedAt;



  @JsonKey(

    name: r'started_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startedAt;



  @JsonKey(

    name: r'completed_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? completedAt;



  @JsonKey(

    name: r'cancelled_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? cancelledAt;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StudDeal &&
      other.id == id &&
      other.listingId == listingId &&
      other.side == side &&
      other.status == status &&
      other.myHamsterLabel == myHamsterLabel &&
      other.partnerCatteryName == partnerCatteryName &&
      other.partnerContact == partnerContact &&
      other.partnerAnimalLabel == partnerAnimalLabel &&
      other.feeCents == feeCents &&
      other.currency == currency &&
      other.notes == notes &&
      other.confirmedAt == confirmedAt &&
      other.startedAt == startedAt &&
      other.completedAt == completedAt &&
      other.cancelledAt == cancelledAt &&
      other.version == version &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        (listingId == null ? 0 : listingId.hashCode) +
        side.hashCode +
        status.hashCode +
        (myHamsterLabel == null ? 0 : myHamsterLabel.hashCode) +
        partnerCatteryName.hashCode +
        (partnerContact == null ? 0 : partnerContact.hashCode) +
        (partnerAnimalLabel == null ? 0 : partnerAnimalLabel.hashCode) +
        feeCents.hashCode +
        currency.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (confirmedAt == null ? 0 : confirmedAt.hashCode) +
        (startedAt == null ? 0 : startedAt.hashCode) +
        (completedAt == null ? 0 : completedAt.hashCode) +
        (cancelledAt == null ? 0 : cancelledAt.hashCode) +
        version.hashCode +
        updatedAt.hashCode;

  factory StudDeal.fromJson(Map<String, dynamic> json) => _$StudDealFromJson(json);

  Map<String, dynamic> toJson() => _$StudDealToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum StudDealSideEnum {
@JsonValue(r'provider')
provider(r'provider'),
@JsonValue(r'requester')
requester(r'requester');

const StudDealSideEnum(this.value);

final String value;

@override
String toString() => value;
}



enum StudDealStatusEnum {
@JsonValue(r'draft')
draft(r'draft'),
@JsonValue(r'requested')
requested(r'requested'),
@JsonValue(r'confirmed')
confirmed(r'confirmed'),
@JsonValue(r'in_progress')
inProgress(r'in_progress'),
@JsonValue(r'completed')
completed(r'completed'),
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const StudDealStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
