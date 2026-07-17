//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'miniprogram_release.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MiniprogramRelease {
  /// Returns a new [MiniprogramRelease] instance.
  MiniprogramRelease({

    required  this.id,

    required  this.versionLabel,

    required  this.status,

    required  this.title,

     this.summary,

     this.publicSlug,

     this.auditNote,

     this.submittedAt,

     this.auditedAt,

     this.publishedAt,

     this.rolledBackAt,

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
    
    name: r'version_label',
    required: true,
    includeIfNull: false,
  )


  final String versionLabel;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MiniprogramReleaseStatusEnum status;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'public_slug',
    required: false,
    includeIfNull: false,
  )


  final String? publicSlug;



  @JsonKey(
    
    name: r'audit_note',
    required: false,
    includeIfNull: false,
  )


  final String? auditNote;



  @JsonKey(
    
    name: r'submitted_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? submittedAt;



  @JsonKey(
    
    name: r'audited_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? auditedAt;



  @JsonKey(
    
    name: r'published_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? publishedAt;



  @JsonKey(
    
    name: r'rolled_back_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? rolledBackAt;



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
    bool operator ==(Object other) => identical(this, other) || other is MiniprogramRelease &&
      other.id == id &&
      other.versionLabel == versionLabel &&
      other.status == status &&
      other.title == title &&
      other.summary == summary &&
      other.publicSlug == publicSlug &&
      other.auditNote == auditNote &&
      other.submittedAt == submittedAt &&
      other.auditedAt == auditedAt &&
      other.publishedAt == publishedAt &&
      other.rolledBackAt == rolledBackAt &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        versionLabel.hashCode +
        status.hashCode +
        title.hashCode +
        (summary == null ? 0 : summary.hashCode) +
        (publicSlug == null ? 0 : publicSlug.hashCode) +
        (auditNote == null ? 0 : auditNote.hashCode) +
        (submittedAt == null ? 0 : submittedAt.hashCode) +
        (auditedAt == null ? 0 : auditedAt.hashCode) +
        (publishedAt == null ? 0 : publishedAt.hashCode) +
        (rolledBackAt == null ? 0 : rolledBackAt.hashCode) +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory MiniprogramRelease.fromJson(Map<String, dynamic> json) => _$MiniprogramReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$MiniprogramReleaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MiniprogramReleaseStatusEnum {
@JsonValue(r'draft')
draft(r'draft'),
@JsonValue(r'submitted')
submitted(r'submitted'),
@JsonValue(r'auditing')
auditing(r'auditing'),
@JsonValue(r'approved')
approved(r'approved'),
@JsonValue(r'rejected')
rejected(r'rejected'),
@JsonValue(r'published')
published(r'published'),
@JsonValue(r'rolled_back')
rolledBack(r'rolled_back');

const MiniprogramReleaseStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


