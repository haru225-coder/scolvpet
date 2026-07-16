//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_session.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadSession {
  /// Returns a new [UploadSession] instance.
  UploadSession({

    required  this.id,

    required  this.uploadUrl,

    required  this.method,

    required  this.headers,

     this.objectKey,

    required  this.expiresAt,

    required  this.version,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'upload_url',
    required: true,
    includeIfNull: false,
  )


  final String uploadUrl;



  @JsonKey(
    
    name: r'method',
    required: true,
    includeIfNull: false,
  )


  final UploadSessionMethodEnum method;



  @JsonKey(
    
    name: r'headers',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> headers;



  @JsonKey(
    
    name: r'object_key',
    required: false,
    includeIfNull: false,
  )


  final String? objectKey;



  @JsonKey(
    
    name: r'expires_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime expiresAt;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadSession &&
      other.id == id &&
      other.uploadUrl == uploadUrl &&
      other.method == method &&
      other.headers == headers &&
      other.objectKey == objectKey &&
      other.expiresAt == expiresAt &&
      other.version == version;

    @override
    int get hashCode =>
        id.hashCode +
        uploadUrl.hashCode +
        method.hashCode +
        headers.hashCode +
        objectKey.hashCode +
        expiresAt.hashCode +
        version.hashCode;

  factory UploadSession.fromJson(Map<String, dynamic> json) => _$UploadSessionFromJson(json);

  Map<String, dynamic> toJson() => _$UploadSessionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum UploadSessionMethodEnum {
@JsonValue(r'PUT')
PUT(r'PUT');

const UploadSessionMethodEnum(this.value);

final String value;

@override
String toString() => value;
}


