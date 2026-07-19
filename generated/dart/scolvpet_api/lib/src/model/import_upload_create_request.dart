//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_upload_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportUploadCreateRequest {
  /// Returns a new [ImportUploadCreateRequest] instance.
  ImportUploadCreateRequest({

    required  this.fileName,

    required  this.sizeBytes,

    required  this.sha256,
  });

  @JsonKey(

    name: r'file_name',
    required: true,
    includeIfNull: false,
  )


  final String fileName;



          // minimum: 1
          // maximum: 104857600
  @JsonKey(

    name: r'size_bytes',
    required: true,
    includeIfNull: false,
  )


  final int sizeBytes;



  @JsonKey(

    name: r'sha256',
    required: true,
    includeIfNull: false,
  )


  final String sha256;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ImportUploadCreateRequest &&
      other.fileName == fileName &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256;

    @override
    int get hashCode =>
        fileName.hashCode +
        sizeBytes.hashCode +
        sha256.hashCode;

  factory ImportUploadCreateRequest.fromJson(Map<String, dynamic> json) => _$ImportUploadCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImportUploadCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
