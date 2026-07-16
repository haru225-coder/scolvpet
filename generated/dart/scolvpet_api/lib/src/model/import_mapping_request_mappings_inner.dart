//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_template_response_data_columns_inner_example.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_mapping_request_mappings_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportMappingRequestMappingsInner {
  /// Returns a new [ImportMappingRequestMappingsInner] instance.
  ImportMappingRequestMappingsInner({

    required  this.sourceColumn,

    required  this.targetField,

    required  this.emptyValuePolicy,

     this.defaultValue,

     this.formatHint,
  });

  @JsonKey(
    
    name: r'source_column',
    required: true,
    includeIfNull: false,
  )


  final String sourceColumn;



  @JsonKey(
    
    name: r'target_field',
    required: true,
    includeIfNull: false,
  )


  final String targetField;



  @JsonKey(
    
    name: r'empty_value_policy',
    required: true,
    includeIfNull: false,
  )


  final ImportMappingRequestMappingsInnerEmptyValuePolicyEnum emptyValuePolicy;



  @JsonKey(
    
    name: r'default_value',
    required: false,
    includeIfNull: false,
  )


  final ImportTemplateResponseDataColumnsInnerExample? defaultValue;



  @JsonKey(
    
    name: r'format_hint',
    required: false,
    includeIfNull: false,
  )


  final String? formatHint;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportMappingRequestMappingsInner &&
      other.sourceColumn == sourceColumn &&
      other.targetField == targetField &&
      other.emptyValuePolicy == emptyValuePolicy &&
      other.defaultValue == defaultValue &&
      other.formatHint == formatHint;

    @override
    int get hashCode =>
        sourceColumn.hashCode +
        targetField.hashCode +
        emptyValuePolicy.hashCode +
        (defaultValue == null ? 0 : defaultValue.hashCode) +
        (formatHint == null ? 0 : formatHint.hashCode);

  factory ImportMappingRequestMappingsInner.fromJson(Map<String, dynamic> json) => _$ImportMappingRequestMappingsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ImportMappingRequestMappingsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ImportMappingRequestMappingsInnerEmptyValuePolicyEnum {
@JsonValue(r'keep_null')
keepNull(r'keep_null'),
@JsonValue(r'use_default')
useDefault(r'use_default'),
@JsonValue(r'reject_row')
rejectRow(r'reject_row');

const ImportMappingRequestMappingsInnerEmptyValuePolicyEnum(this.value);

final String value;

@override
String toString() => value;
}


