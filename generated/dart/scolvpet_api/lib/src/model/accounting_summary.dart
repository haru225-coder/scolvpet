//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/accounting_category_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accounting_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountingSummary {
  /// Returns a new [AccountingSummary] instance.
  AccountingSummary({

    required  this.from,

    required  this.to,

    required  this.incomeCents,

    required  this.expenseCents,

    required  this.netCents,

    required  this.currency,

    required  this.recordCount,

    required  this.byCategory,
  });

  @JsonKey(
    
    name: r'from',
    required: true,
    includeIfNull: false,
  )


  final DateTime from;



  @JsonKey(
    
    name: r'to',
    required: true,
    includeIfNull: false,
  )


  final DateTime to;



  @JsonKey(
    
    name: r'income_cents',
    required: true,
    includeIfNull: false,
  )


  final int incomeCents;



  @JsonKey(
    
    name: r'expense_cents',
    required: true,
    includeIfNull: false,
  )


  final int expenseCents;



  @JsonKey(
    
    name: r'net_cents',
    required: true,
    includeIfNull: false,
  )


  final int netCents;



  @JsonKey(
    
    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



          // minimum: 0
  @JsonKey(
    
    name: r'record_count',
    required: true,
    includeIfNull: false,
  )


  final int recordCount;



  @JsonKey(
    
    name: r'by_category',
    required: true,
    includeIfNull: false,
  )


  final List<AccountingCategorySummary> byCategory;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountingSummary &&
      other.from == from &&
      other.to == to &&
      other.incomeCents == incomeCents &&
      other.expenseCents == expenseCents &&
      other.netCents == netCents &&
      other.currency == currency &&
      other.recordCount == recordCount &&
      other.byCategory == byCategory;

    @override
    int get hashCode =>
        from.hashCode +
        to.hashCode +
        incomeCents.hashCode +
        expenseCents.hashCode +
        netCents.hashCode +
        currency.hashCode +
        recordCount.hashCode +
        byCategory.hashCode;

  factory AccountingSummary.fromJson(Map<String, dynamic> json) => _$AccountingSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AccountingSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

