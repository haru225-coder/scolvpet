//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_template_response_data_columns_inner_example.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_issue.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportIssue {
  /// Returns a new [ImportIssue] instance.
  ImportIssue({

    required  this.rowNumber,

     this.columnName,

    required  this.code,

    required  this.message,

    required  this.severity,

     this.originalValue,

     this.suggestion,
  });

          // minimum: 1
  @JsonKey(
    
    name: r'row_number',
    required: true,
    includeIfNull: false,
  )


  final int rowNumber;



  @JsonKey(
    
    name: r'column_name',
    required: false,
    includeIfNull: false,
  )


  final String? columnName;



  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'severity',
    required: true,
    includeIfNull: false,
  )


  final ImportIssueSeverityEnum severity;



  @JsonKey(
    
    name: r'original_value',
    required: false,
    includeIfNull: false,
  )


  final ImportTemplateResponseDataColumnsInnerExample? originalValue;



  @JsonKey(
    
    name: r'suggestion',
    required: false,
    includeIfNull: false,
  )


  final String? suggestion;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportIssue &&
      other.rowNumber == rowNumber &&
      other.columnName == columnName &&
      other.code == code &&
      other.message == message &&
      other.severity == severity &&
      other.originalValue == originalValue &&
      other.suggestion == suggestion;

    @override
    int get hashCode =>
        rowNumber.hashCode +
        (columnName == null ? 0 : columnName.hashCode) +
        code.hashCode +
        message.hashCode +
        severity.hashCode +
        (originalValue == null ? 0 : originalValue.hashCode) +
        (suggestion == null ? 0 : suggestion.hashCode);

  factory ImportIssue.fromJson(Map<String, dynamic> json) => _$ImportIssueFromJson(json);

  Map<String, dynamic> toJson() => _$ImportIssueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ImportIssueSeverityEnum {
@JsonValue(r'warning')
warning(r'warning'),
@JsonValue(r'blocking')
blocking(r'blocking');

const ImportIssueSeverityEnum(this.value);

final String value;

@override
String toString() => value;
}


