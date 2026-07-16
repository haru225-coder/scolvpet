//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_upload_complete_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaUploadCompleteRequest {
  /// Returns a new [MediaUploadCompleteRequest] instance.
  MediaUploadCompleteRequest({

    required  this.objectEtag,

    required  this.sizeBytes,

    required  this.sha256,

     this.capturedAt,

     this.timezone,
  });

  @JsonKey(
    
    name: r'object_etag',
    required: true,
    includeIfNull: false,
  )


  final String objectEtag;



          // minimum: 1
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



  @JsonKey(
    
    name: r'captured_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? capturedAt;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaUploadCompleteRequest &&
      other.objectEtag == objectEtag &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256 &&
      other.capturedAt == capturedAt &&
      other.timezone == timezone;

    @override
    int get hashCode =>
        objectEtag.hashCode +
        sizeBytes.hashCode +
        sha256.hashCode +
        (capturedAt == null ? 0 : capturedAt.hashCode) +
        (timezone == null ? 0 : timezone.hashCode);

  factory MediaUploadCompleteRequest.fromJson(Map<String, dynamic> json) => _$MediaUploadCompleteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MediaUploadCompleteRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

