//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/import_template_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_job_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportJobCreateRequest {
  /// Returns a new [ImportJobCreateRequest] instance.
  ImportJobCreateRequest({

    required  this.uploadId,

    required  this.templateType,

    required  this.templateVersion,

     this.sourceEncoding,

     this.timezone = 'Asia/Shanghai',
  });

  @JsonKey(

    name: r'upload_id',
    required: true,
    includeIfNull: false,
  )


  final String uploadId;



  @JsonKey(

    name: r'template_type',
    required: true,
    includeIfNull: false,
  )


  final ImportTemplateType templateType;



  @JsonKey(

    name: r'template_version',
    required: true,
    includeIfNull: false,
  )


  final String templateVersion;



  @JsonKey(

    name: r'source_encoding',
    required: false,
    includeIfNull: false,
  )


  final ImportJobCreateRequestSourceEncodingEnum? sourceEncoding;



  @JsonKey(
    defaultValue: 'Asia/Shanghai',
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportJobCreateRequest &&
      other.uploadId == uploadId &&
      other.templateType == templateType &&
      other.templateVersion == templateVersion &&
      other.sourceEncoding == sourceEncoding &&
      other.timezone == timezone;

    @override
    int get hashCode =>
        uploadId.hashCode +
        templateType.hashCode +
        templateVersion.hashCode +
        (sourceEncoding == null ? 0 : sourceEncoding.hashCode) +
        timezone.hashCode;

  factory ImportJobCreateRequest.fromJson(Map<String, dynamic> json) => _$ImportJobCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImportJobCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ImportJobCreateRequestSourceEncodingEnum {
@JsonValue(r'utf-8')
utf8(r'utf-8'),
@JsonValue(r'utf-8-bom')
utf8Bom(r'utf-8-bom'),
@JsonValue(r'gb18030')
gb18030(r'gb18030');

const ImportJobCreateRequestSourceEncodingEnum(this.value);

final String value;

@override
String toString() => value;
}
