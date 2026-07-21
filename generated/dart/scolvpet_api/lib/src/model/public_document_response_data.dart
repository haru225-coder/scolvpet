//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_document_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicDocumentResponseData {
  /// Returns a new [PublicDocumentResponseData] instance.
  PublicDocumentResponseData({

    required  this.kind,

     this.kindLabel,

    required  this.title,

    required  this.bodyFilled,

     this.contactName,

     this.currency,

     this.amountCents,

     this.amountLabel,

     this.issuedAt,

    required  this.status,
  });

  @JsonKey(

    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PublicDocumentResponseDataKindEnum kind;



  @JsonKey(

    name: r'kind_label',
    required: false,
    includeIfNull: false,
  )


  final String? kindLabel;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'body_filled',
    required: true,
    includeIfNull: false,
  )


  final String bodyFilled;



  @JsonKey(

    name: r'contact_name',
    required: false,
    includeIfNull: false,
  )


  final String? contactName;



  @JsonKey(

    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(

    name: r'amount_cents',
    required: false,
    includeIfNull: false,
  )


  final int? amountCents;



  @JsonKey(

    name: r'amount_label',
    required: false,
    includeIfNull: false,
  )


  final String? amountLabel;



  @JsonKey(

    name: r'issued_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? issuedAt;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final PublicDocumentResponseDataStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicDocumentResponseData &&
      other.kind == kind &&
      other.kindLabel == kindLabel &&
      other.title == title &&
      other.bodyFilled == bodyFilled &&
      other.contactName == contactName &&
      other.currency == currency &&
      other.amountCents == amountCents &&
      other.amountLabel == amountLabel &&
      other.issuedAt == issuedAt &&
      other.status == status;

    @override
    int get hashCode =>
        kind.hashCode +
        kindLabel.hashCode +
        title.hashCode +
        bodyFilled.hashCode +
        contactName.hashCode +
        currency.hashCode +
        (amountCents == null ? 0 : amountCents.hashCode) +
        (amountLabel == null ? 0 : amountLabel.hashCode) +
        (issuedAt == null ? 0 : issuedAt.hashCode) +
        status.hashCode;

  factory PublicDocumentResponseData.fromJson(Map<String, dynamic> json) => _$PublicDocumentResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$PublicDocumentResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PublicDocumentResponseDataKindEnum {
@JsonValue(r'contract')
contract(r'contract'),
@JsonValue(r'receipt')
receipt(r'receipt');

const PublicDocumentResponseDataKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PublicDocumentResponseDataStatusEnum {
@JsonValue(r'issued')
issued(r'issued');

const PublicDocumentResponseDataStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
