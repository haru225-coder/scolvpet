//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_accounting_record_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateAccountingRecordRequest {
  /// Returns a new [CreateAccountingRecordRequest] instance.
  CreateAccountingRecordRequest({

     this.categoryId,

    required  this.entryType,

    required  this.amountCents,

     this.currency = 'CNY',

    required  this.title,

     this.notes,

     this.contactId,

     this.occurredAt,
  });

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


  final CreateAccountingRecordRequestEntryTypeEnum entryType;



          // minimum: 1
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
    required: false,
    includeIfNull: false,
  )


  final DateTime? occurredAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateAccountingRecordRequest &&
      other.categoryId == categoryId &&
      other.entryType == entryType &&
      other.amountCents == amountCents &&
      other.currency == currency &&
      other.title == title &&
      other.notes == notes &&
      other.contactId == contactId &&
      other.occurredAt == occurredAt;

    @override
    int get hashCode =>
        (categoryId == null ? 0 : categoryId.hashCode) +
        entryType.hashCode +
        amountCents.hashCode +
        currency.hashCode +
        title.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (contactId == null ? 0 : contactId.hashCode) +
        (occurredAt == null ? 0 : occurredAt.hashCode);

  factory CreateAccountingRecordRequest.fromJson(Map<String, dynamic> json) => _$CreateAccountingRecordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAccountingRecordRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateAccountingRecordRequestEntryTypeEnum {
@JsonValue(r'income')
income(r'income'),
@JsonValue(r'expense')
expense(r'expense');

const CreateAccountingRecordRequestEntryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
