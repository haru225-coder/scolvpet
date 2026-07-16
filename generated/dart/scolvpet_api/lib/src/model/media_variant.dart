//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_variant.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaVariant {
  /// Returns a new [MediaVariant] instance.
  MediaVariant({

    required  this.id,

    required  this.kind,

    required  this.status,

     this.url,

     this.width,

     this.height,

     this.durationSeconds,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final MediaVariantKindEnum kind;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MediaVariantStatusEnum status;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



          // minimum: 1
  @JsonKey(
    
    name: r'width',
    required: false,
    includeIfNull: false,
  )


  final int? width;



          // minimum: 1
  @JsonKey(
    
    name: r'height',
    required: false,
    includeIfNull: false,
  )


  final int? height;



          // minimum: 0
  @JsonKey(
    
    name: r'duration_seconds',
    required: false,
    includeIfNull: false,
  )


  final num? durationSeconds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaVariant &&
      other.id == id &&
      other.kind == kind &&
      other.status == status &&
      other.url == url &&
      other.width == width &&
      other.height == height &&
      other.durationSeconds == durationSeconds;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        status.hashCode +
        (url == null ? 0 : url.hashCode) +
        (width == null ? 0 : width.hashCode) +
        (height == null ? 0 : height.hashCode) +
        (durationSeconds == null ? 0 : durationSeconds.hashCode);

  factory MediaVariant.fromJson(Map<String, dynamic> json) => _$MediaVariantFromJson(json);

  Map<String, dynamic> toJson() => _$MediaVariantToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MediaVariantKindEnum {
@JsonValue(r'thumbnail')
thumbnail(r'thumbnail'),
@JsonValue(r'preview')
preview(r'preview'),
@JsonValue(r'edited')
edited(r'edited'),
@JsonValue(r'video_720p')
video720p(r'video_720p'),
@JsonValue(r'video_1080p')
video1080p(r'video_1080p'),
@JsonValue(r'cover')
cover(r'cover');

const MediaVariantKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum MediaVariantStatusEnum {
@JsonValue(r'queued')
queued(r'queued'),
@JsonValue(r'processing')
processing(r'processing'),
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'failed')
failed(r'failed');

const MediaVariantStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


