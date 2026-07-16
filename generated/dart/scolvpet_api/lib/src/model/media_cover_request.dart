//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_cover_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaCoverRequest {
  /// Returns a new [MediaCoverRequest] instance.
  MediaCoverRequest({

     this.timeOffsetSeconds,

     this.mediaVariantId,
  });

          // minimum: 0
  @JsonKey(
    
    name: r'time_offset_seconds',
    required: false,
    includeIfNull: false,
  )


  final num? timeOffsetSeconds;



  @JsonKey(
    
    name: r'media_variant_id',
    required: false,
    includeIfNull: false,
  )


  final String? mediaVariantId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaCoverRequest &&
      other.timeOffsetSeconds == timeOffsetSeconds &&
      other.mediaVariantId == mediaVariantId;

    @override
    int get hashCode =>
        timeOffsetSeconds.hashCode +
        mediaVariantId.hashCode;

  factory MediaCoverRequest.fromJson(Map<String, dynamic> json) => _$MediaCoverRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MediaCoverRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

