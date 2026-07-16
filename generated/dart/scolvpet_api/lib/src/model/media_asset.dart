//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/media_variant.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_asset.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaAsset {
  /// Returns a new [MediaAsset] instance.
  MediaAsset({

    required  this.id,

    required  this.ownerId,

    required  this.mediaType,

    required  this.contentType,

    required  this.sizeBytes,

    required  this.sha256,

    required  this.status,

     this.originalUrl,

     this.coverVariantId,

    required  this.variants,

    required  this.version,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(
    
    name: r'media_type',
    required: true,
    includeIfNull: false,
  )


  final MediaAssetMediaTypeEnum mediaType;



  @JsonKey(
    
    name: r'content_type',
    required: true,
    includeIfNull: false,
  )


  final String contentType;



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
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MediaAssetStatusEnum status;



  @JsonKey(
    
    name: r'original_url',
    required: false,
    includeIfNull: false,
  )


  final String? originalUrl;



  @JsonKey(
    
    name: r'cover_variant_id',
    required: false,
    includeIfNull: false,
  )


  final String? coverVariantId;



  @JsonKey(
    
    name: r'variants',
    required: true,
    includeIfNull: false,
  )


  final List<MediaVariant> variants;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(
    
    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaAsset &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.mediaType == mediaType &&
      other.contentType == contentType &&
      other.sizeBytes == sizeBytes &&
      other.sha256 == sha256 &&
      other.status == status &&
      other.originalUrl == originalUrl &&
      other.coverVariantId == coverVariantId &&
      other.variants == variants &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        mediaType.hashCode +
        contentType.hashCode +
        sizeBytes.hashCode +
        sha256.hashCode +
        status.hashCode +
        (originalUrl == null ? 0 : originalUrl.hashCode) +
        (coverVariantId == null ? 0 : coverVariantId.hashCode) +
        variants.hashCode +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory MediaAsset.fromJson(Map<String, dynamic> json) => _$MediaAssetFromJson(json);

  Map<String, dynamic> toJson() => _$MediaAssetToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MediaAssetMediaTypeEnum {
@JsonValue(r'image')
image(r'image'),
@JsonValue(r'video')
video(r'video');

const MediaAssetMediaTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum MediaAssetStatusEnum {
@JsonValue(r'processing')
processing(r'processing'),
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'failed')
failed(r'failed');

const MediaAssetStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


