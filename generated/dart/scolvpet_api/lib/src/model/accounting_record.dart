//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accounting_record.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountingRecord {
  /// Returns a new [AccountingRecord] instance.
  AccountingRecord({

    required  this.id,

     this.categoryId,

    required  this.entryType,

    required  this.amountCents,

    required  this.currency,

    required  this.title,

     this.notes,

     this.contactId,

    required  this.occurredAt,

    required  this.version,

     this.categoryName,

     this.contactName,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(

    name: r'entry_type',
    required: true,
    includeIfNull: false,
  )


  final AccountingRecordEntryTypeEnum entryType;



          // minimum: 1
  @JsonKey(

    name: r'amount_cents',
    required: true,
    includeIfNull: false,
  )


  final int amountCents;



  @JsonKey(

    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(

    name: r'contact_id',
    required: false,
    includeIfNull: false,
  )


  final String? contactId;



  @JsonKey(

    name: r'occurred_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime occurredAt;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'category_name',
    required: false,
    includeIfNull: false,
  )


  final String? categoryName;



  @JsonKey(

    name: r'contact_name',
    required: false,
    includeIfNull: false,
  )


  final String? contactName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountingRecord &&
      other.id == id &&
      other.categoryId == categoryId &&
      other.entryType == entryType &&
      other.amountCents == amountCents &&
      other.currency == currency &&
      other.title == title &&
      other.notes == notes &&
      other.contactId == contactId &&
      other.occurredAt == occurredAt &&
      other.version == version &&
      other.categoryName == categoryName &&
      other.contactName == contactName;

    @override
    int get hashCode =>
        id.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        entryType.hashCode +
        amountCents.hashCode +
        currency.hashCode +
        title.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (contactId == null ? 0 : contactId.hashCode) +
        occurredAt.hashCode +
        version.hashCode +
        categoryName.hashCode +
        contactName.hashCode;

  factory AccountingRecord.fromJson(Map<String, dynamic> json) => _$AccountingRecordFromJson(json);

  Map<String, dynamic> toJson() => _$AccountingRecordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AccountingRecordEntryTypeEnum {
@JsonValue(r'income')
income(r'income'),
@JsonValue(r'expense')
expense(r'expense');

const AccountingRecordEntryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
