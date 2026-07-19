//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:scolvpet_api/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_upload_complete_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaUploadCompleteResponseData {
  /// Returns a new [MediaUploadCompleteResponseData] instance.
  MediaUploadCompleteResponseData({

    required  this.media,

    required  this.processingJob,
  });

  @JsonKey(

    name: r'media',
    required: true,
    includeIfNull: false,
  )


  final MediaAsset media;



  @JsonKey(

    name: r'processing_job',
    required: true,
    includeIfNull: false,
  )


  final AsyncJob processingJob;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaUploadCompleteResponseData &&
      other.media == media &&
      other.processingJob == processingJob;

    @override
    int get hashCode =>
        media.hashCode +
        processingJob.hashCode;

  factory MediaUploadCompleteResponseData.fromJson(Map<String, dynamic> json) => _$MediaUploadCompleteResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$MediaUploadCompleteResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
