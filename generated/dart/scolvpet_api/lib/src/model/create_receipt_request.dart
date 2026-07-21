//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_receipt_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateReceiptRequest {
  /// Returns a new [CreateReceiptRequest] instance.
  CreateReceiptRequest({

    required  this.templateId,

     this.contactId,

     this.handoverId,

     this.reservationId,

     this.title,

    required  this.amountCents,

     this.currency = 'CNY',

     this.notes,

     this.contactName,

     this.hamsterName,
  });

  @JsonKey(

    name: r'template_id',
    required: true,
    includeIfNull: false,
  )


  final String templateId;



  @JsonKey(

    name: r'contact_id',
    required: false,
    includeIfNull: false,
  )


  final String? contactId;



  @JsonKey(

    name: r'handover_id',
    required: false,
    includeIfNull: false,
  )


  final String? handoverId;



      /// 从统一预订继承客户与仓鼠；可同时关联已有交付
  @JsonKey(

    name: r'reservation_id',
    required: false,
    includeIfNull: false,
  )


  final String? reservationId;



  @JsonKey(

    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



          // minimum: 0
  @JsonKey(

    name: r'amount_cents',
    required: true,
    includeIfNull: false,
  )


  final int amountCents;



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
    bool operator ==(Object other) => identical(this, other) || other is CreateReceiptRequest &&
      other.templateId == templateId &&
      other.contactId == contactId &&
      other.handoverId == handoverId &&
      other.reservationId == reservationId &&
      other.title == title &&
      other.amountCents == amountCents &&
      other.currency == currency &&
      other.notes == notes &&
      other.contactName == contactName &&
      other.hamsterName == hamsterName;

    @override
    int get hashCode =>
        templateId.hashCode +
        (contactId == null ? 0 : contactId.hashCode) +
        (handoverId == null ? 0 : handoverId.hashCode) +
        (reservationId == null ? 0 : reservationId.hashCode) +
        title.hashCode +
        amountCents.hashCode +
        currency.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (contactName == null ? 0 : contactName.hashCode) +
        (hamsterName == null ? 0 : hamsterName.hashCode);

  factory CreateReceiptRequest.fromJson(Map<String, dynamic> json) => _$CreateReceiptRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReceiptRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
