//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accounting_category_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountingCategorySummary {
  /// Returns a new [AccountingCategorySummary] instance.
  AccountingCategorySummary({

     this.categoryId,

    required  this.categoryName,

    required  this.entryType,

    required  this.amountCents,

    required  this.count,
  });

  @JsonKey(

    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(

    name: r'category_name',
    required: true,
    includeIfNull: false,
  )


  final String categoryName;



  @JsonKey(

    name: r'entry_type',
    required: true,
    includeIfNull: false,
  )


  final AccountingCategorySummaryEntryTypeEnum entryType;



  @JsonKey(

    name: r'amount_cents',
    required: true,
    includeIfNull: false,
  )


  final int amountCents;



          // minimum: 0
  @JsonKey(

    name: r'count',
    required: true,
    includeIfNull: false,
  )


  final int count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountingCategorySummary &&
      other.categoryId == categoryId &&
      other.categoryName == categoryName &&
      other.entryType == entryType &&
      other.amountCents == amountCents &&
      other.count == count;

    @override
    int get hashCode =>
        (categoryId == null ? 0 : categoryId.hashCode) +
        categoryName.hashCode +
        entryType.hashCode +
        amountCents.hashCode +
        count.hashCode;

  factory AccountingCategorySummary.fromJson(Map<String, dynamic> json) => _$AccountingCategorySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AccountingCategorySummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AccountingCategorySummaryEntryTypeEnum {
@JsonValue(r'income')
income(r'income'),
@JsonValue(r'expense')
expense(r'expense');

const AccountingCategorySummaryEntryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
