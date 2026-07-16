//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/share_status.dart';
import 'package:scolvpet_api/src/model/share_public_field.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_page.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SharePage {
  /// Returns a new [SharePage] instance.
  SharePage({

    required  this.id,

    required  this.ownerId,

    required  this.subjectType,

    required  this.subjectId,

    required  this.status,

    required  this.fields,

    required  this.mediaIds,

    required  this.publicUrl,

     this.expiresAt,

     this.revokedAt,

    required  this.version,

    required  this.createdAt,
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
    
    name: r'subject_type',
    required: true,
    includeIfNull: false,
  )


  final SharePageSubjectTypeEnum subjectType;



  @JsonKey(
    
    name: r'subject_id',
    required: true,
    includeIfNull: false,
  )


  final String subjectId;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ShareStatus status;



  @JsonKey(
    
    name: r'fields',
    required: true,
    includeIfNull: false,
  )


  final Set<SharePublicField> fields;



  @JsonKey(
    
    name: r'media_ids',
    required: true,
    includeIfNull: false,
  )


  final Set<String> mediaIds;



  @JsonKey(
    
    name: r'public_url',
    required: true,
    includeIfNull: false,
  )


  final String publicUrl;



  @JsonKey(
    
    name: r'expires_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;



  @JsonKey(
    
    name: r'revoked_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? revokedAt;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is SharePage &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.subjectType == subjectType &&
      other.subjectId == subjectId &&
      other.status == status &&
      other.fields == fields &&
      other.mediaIds == mediaIds &&
      other.publicUrl == publicUrl &&
      other.expiresAt == expiresAt &&
      other.revokedAt == revokedAt &&
      other.version == version &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        subjectType.hashCode +
        subjectId.hashCode +
        status.hashCode +
        fields.hashCode +
        mediaIds.hashCode +
        publicUrl.hashCode +
        (expiresAt == null ? 0 : expiresAt.hashCode) +
        (revokedAt == null ? 0 : revokedAt.hashCode) +
        version.hashCode +
        createdAt.hashCode;

  factory SharePage.fromJson(Map<String, dynamic> json) => _$SharePageFromJson(json);

  Map<String, dynamic> toJson() => _$SharePageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SharePageSubjectTypeEnum {
@JsonValue(r'hamster')
hamster(r'hamster'),
@JsonValue(r'litter')
litter(r'litter');

const SharePageSubjectTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


