//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_template.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentTemplate {
  /// Returns a new [DocumentTemplate] instance.
  DocumentTemplate({

    required  this.id,

    required  this.kind,

    required  this.name,

    required  this.bodyText,

    required  this.version,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final DocumentTemplateKindEnum kind;



  @JsonKey(

    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(

    name: r'body_text',
    required: true,
    includeIfNull: false,
  )


  final String bodyText;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DocumentTemplate &&
      other.id == id &&
      other.kind == kind &&
      other.name == name &&
      other.bodyText == bodyText &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        name.hashCode +
        bodyText.hashCode +
        version.hashCode;

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) => _$DocumentTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentTemplateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum DocumentTemplateKindEnum {
@JsonValue(r'contract')
contract(r'contract'),
@JsonValue(r'receipt')
receipt(r'receipt');

const DocumentTemplateKindEnum(this.value);

final String value;

@override
String toString() => value;
}
