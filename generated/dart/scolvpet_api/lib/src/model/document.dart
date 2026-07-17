//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Document {
  /// Returns a new [Document] instance.
  Document({

    required  this.id,

    required  this.templateId,

    required  this.kind,

     this.contactId,

     this.handoverId,

    required  this.title,

    required  this.bodyFilled,

     this.amountCents,

    required  this.currency,

    required  this.status,

     this.issuedAt,

     this.notes,

    required  this.version,

     this.contactName,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'template_id',
    required: true,
    includeIfNull: false,
  )


  final String templateId;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final DocumentKindEnum kind;



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



          // minimum: 0
  @JsonKey(
    
    name: r'amount_cents',
    required: false,
    includeIfNull: false,
  )


  final int? amountCents;



  @JsonKey(
    
    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final DocumentStatusEnum status;



  @JsonKey(
    
    name: r'issued_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? issuedAt;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is Document &&
      other.id == id &&
      other.templateId == templateId &&
      other.kind == kind &&
      other.contactId == contactId &&
      other.handoverId == handoverId &&
      other.title == title &&
      other.bodyFilled == bodyFilled &&
      other.amountCents == amountCents &&
      other.currency == currency &&
      other.status == status &&
      other.issuedAt == issuedAt &&
      other.notes == notes &&
      other.version == version &&
      other.contactName == contactName;

    @override
    int get hashCode =>
        id.hashCode +
        templateId.hashCode +
        kind.hashCode +
        (contactId == null ? 0 : contactId.hashCode) +
        (handoverId == null ? 0 : handoverId.hashCode) +
        title.hashCode +
        bodyFilled.hashCode +
        (amountCents == null ? 0 : amountCents.hashCode) +
        currency.hashCode +
        status.hashCode +
        (issuedAt == null ? 0 : issuedAt.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        contactName.hashCode;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DocumentKindEnum {
@JsonValue(r'contract')
contract(r'contract'),
@JsonValue(r'receipt')
receipt(r'receipt');

const DocumentKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum DocumentStatusEnum {
@JsonValue(r'draft')
draft(r'draft'),
@JsonValue(r'issued')
issued(r'issued'),
@JsonValue(r'archived')
archived(r'archived');

const DocumentStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


