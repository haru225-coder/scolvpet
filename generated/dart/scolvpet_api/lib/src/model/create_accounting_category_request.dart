//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_accounting_category_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateAccountingCategoryRequest {
  /// Returns a new [CreateAccountingCategoryRequest] instance.
  CreateAccountingCategoryRequest({

    required  this.entryType,

    required  this.name,

     this.sortOrder,
  });

  @JsonKey(
    
    name: r'entry_type',
    required: true,
    includeIfNull: false,
  )


  final CreateAccountingCategoryRequestEntryTypeEnum entryType;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'sort_order',
    required: false,
    includeIfNull: false,
  )


  final int? sortOrder;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateAccountingCategoryRequest &&
      other.entryType == entryType &&
      other.name == name &&
      other.sortOrder == sortOrder;

    @override
    int get hashCode =>
        entryType.hashCode +
        name.hashCode +
        (sortOrder == null ? 0 : sortOrder.hashCode);

  factory CreateAccountingCategoryRequest.fromJson(Map<String, dynamic> json) => _$CreateAccountingCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAccountingCategoryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CreateAccountingCategoryRequestEntryTypeEnum {
@JsonValue(r'income')
income(r'income'),
@JsonValue(r'expense')
expense(r'expense');

const CreateAccountingCategoryRequestEntryTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


