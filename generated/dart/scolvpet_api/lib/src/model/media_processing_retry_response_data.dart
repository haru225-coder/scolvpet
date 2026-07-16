//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:scolvpet_api/src/model/media_asset.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_processing_retry_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaProcessingRetryResponseData {
  /// Returns a new [MediaProcessingRetryResponseData] instance.
  MediaProcessingRetryResponseData({

    required  this.media,

    required  this.job,
  });

  @JsonKey(
    
    name: r'media',
    required: true,
    includeIfNull: false,
  )


  final MediaAsset media;



  @JsonKey(
    
    name: r'job',
    required: true,
    includeIfNull: false,
  )


  final AsyncJob job;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaProcessingRetryResponseData &&
      other.media == media &&
      other.job == job;

    @override
    int get hashCode =>
        media.hashCode +
        job.hashCode;

  factory MediaProcessingRetryResponseData.fromJson(Map<String, dynamic> json) => _$MediaProcessingRetryResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$MediaProcessingRetryResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

