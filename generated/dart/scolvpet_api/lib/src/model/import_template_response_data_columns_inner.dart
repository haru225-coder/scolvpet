//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_template_response_data_columns_inner_example.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_template_response_data_columns_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportTemplateResponseDataColumnsInner {
  /// Returns a new [ImportTemplateResponseDataColumnsInner] instance.
  ImportTemplateResponseDataColumnsInner({

    required  this.key,

    required  this.label,

    required  this.required_,

    required  this.dataType,

     this.example,
  });

  @JsonKey(

    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(

    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(

    name: r'required',
    required: true,
    includeIfNull: false,
  )


  final bool required_;



  @JsonKey(

    name: r'data_type',
    required: true,
    includeIfNull: false,
  )


  final String dataType;



  @JsonKey(

    name: r'example',
    required: false,
    includeIfNull: false,
  )


  final ImportTemplateResponseDataColumnsInnerExample? example;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportTemplateResponseDataColumnsInner &&
      other.key == key &&
      other.label == label &&
      other.required_ == required_ &&
      other.dataType == dataType &&
      other.example == example;

    @override
    int get hashCode =>
        key.hashCode +
        label.hashCode +
        required_.hashCode +
        dataType.hashCode +
        (example == null ? 0 : example.hashCode);

  factory ImportTemplateResponseDataColumnsInner.fromJson(Map<String, dynamic> json) => _$ImportTemplateResponseDataColumnsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$ImportTemplateResponseDataColumnsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
