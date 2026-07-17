//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_document_template_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDocumentTemplateRequest {
  /// Returns a new [CreateDocumentTemplateRequest] instance.
  CreateDocumentTemplateRequest({

    required  this.name,

     this.bodyText,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'body_text',
    required: false,
    includeIfNull: false,
  )


  final String? bodyText;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateDocumentTemplateRequest &&
      other.name == name &&
      other.bodyText == bodyText;

    @override
    int get hashCode =>
        name.hashCode +
        bodyText.hashCode;

  factory CreateDocumentTemplateRequest.fromJson(Map<String, dynamic> json) => _$CreateDocumentTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDocumentTemplateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

