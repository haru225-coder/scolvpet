//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_processing_retry_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaProcessingRetryRequest {
  /// Returns a new [MediaProcessingRetryRequest] instance.
  MediaProcessingRetryRequest({

    required  this.scope,

     this.variantIds,

    required  this.reason,
  });

  @JsonKey(
    
    name: r'scope',
    required: true,
    includeIfNull: false,
  )


  final MediaProcessingRetryRequestScopeEnum scope;



      /// scope=failed_variants 时可限定失败派生；省略表示全部失败派生
  @JsonKey(
    
    name: r'variant_ids',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? variantIds;



  @JsonKey(
    
    name: r'reason',
    required: true,
    includeIfNull: false,
  )


  final String reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaProcessingRetryRequest &&
      other.scope == scope &&
      other.variantIds == variantIds &&
      other.reason == reason;

    @override
    int get hashCode =>
        scope.hashCode +
        variantIds.hashCode +
        reason.hashCode;

  factory MediaProcessingRetryRequest.fromJson(Map<String, dynamic> json) => _$MediaProcessingRetryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MediaProcessingRetryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MediaProcessingRetryRequestScopeEnum {
@JsonValue(r'failed_variants')
failedVariants(r'failed_variants'),
@JsonValue(r'video_transcode')
videoTranscode(r'video_transcode'),
@JsonValue(r'image_derivatives')
imageDerivatives(r'image_derivatives');

const MediaProcessingRetryRequestScopeEnum(this.value);

final String value;

@override
String toString() => value;
}


