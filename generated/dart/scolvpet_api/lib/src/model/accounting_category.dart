//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accounting_category.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountingCategory {
  /// Returns a new [AccountingCategory] instance.
  AccountingCategory({

    required  this.id,

    required  this.entryType,

    required  this.name,

    required  this.sortOrder,

    required  this.version,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'entry_type',
    required: true,
    includeIfNull: false,
  )


  final AccountingCategoryEntryTypeEnum entryType;



  @JsonKey(

    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(

    name: r'sort_order',
    required: true,
    includeIfNull: false,
  )


  final int sortOrder;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountingCategory &&
      other.id == id &&
      other.entryType == entryType &&
      other.name == name &&
      other.sortOrder == sortOrder &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        entryType.hashCode +
        name.hashCode +
        sortOrder.hashCode +
        version.hashCode;

  factory AccountingCategory.fromJson(Map<String, dynamic> json) => _$AccountingCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$AccountingCategoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AccountingCategoryEntryTypeEnum {
@JsonValue(r'income')
income(r'income'),
@JsonValue(r'expense')
expense(r'expense');

const AccountingCategoryEntryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
