//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_upload_presign_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaUploadPresignRequest {
  /// Returns a new [MediaUploadPresignRequest] instance.
  MediaUploadPresignRequest({

    required  this.fileName,

    required  this.contentType,

    required  this.sizeBytes,

    required  this.sha256,

     this.purpose,
  });

  @JsonKey(
    
    name: r'file_name',
    required: true,
    includeIfNull: false,
  )


  final String fileName;



  @JsonKey(
    
    name: r'content_type',
    required: true,
    includeIfNull: false,
  )


  final MediaUploadPresignRequestContentTypeEnum contentType;



          // minimum: 1
          // maximum: 524288000
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
    
    name: r'purpose',
    required: false,
    includeIfNull: false,
  )


  final MediaUploadPresignRequestPurposeEnum? purpose;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaUploadPresignRequest &&
      other.fileName == fileName &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256 &&
      other.purpose == purpose;

    @override
    int get hashCode =>
        fileName.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode +
        sha256.hashCode +
        purpose.hashCode;

  factory MediaUploadPresignRequest.fromJson(Map<String, dynamic> json) => _$MediaUploadPresignRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MediaUploadPresignRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MediaUploadPresignRequestContentTypeEnum {
@JsonValue(r'image/jpeg')
imageSlashJpeg(r'image/jpeg'),
@JsonValue(r'image/png')
imageSlashPng(r'image/png'),
@JsonValue(r'image/webp')
imageSlashWebp(r'image/webp'),
@JsonValue(r'video/mp4')
videoSlashMp4(r'video/mp4'),
@JsonValue(r'video/quicktime')
videoSlashQuicktime(r'video/quicktime');

const MediaUploadPresignRequestContentTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum MediaUploadPresignRequestPurposeEnum {
@JsonValue(r'hamster_profile')
hamsterProfile(r'hamster_profile'),
@JsonValue(r'litter_timeline')
litterTimeline(r'litter_timeline'),
@JsonValue(r'health_record')
healthRecord(r'health_record'),
@JsonValue(r'pairing_observation')
pairingObservation(r'pairing_observation'),
@JsonValue(r'share')
share(r'share'),
@JsonValue(r'other')
other(r'other');

const MediaUploadPresignRequestPurposeEnum(this.value);

final String value;

@override
String toString() => value;
}


