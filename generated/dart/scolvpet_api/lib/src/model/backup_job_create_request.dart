//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backup_job_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BackupJobCreateRequest {
  /// Returns a new [BackupJobCreateRequest] instance.
  BackupJobCreateRequest({

    required  this.includeMediaManifest,

    required  this.includeChecksums,

    required  this.timezone,

     this.encryptionHint,
  });

  @JsonKey(

    name: r'include_media_manifest',
    required: true,
    includeIfNull: false,
  )


  final BackupJobCreateRequestIncludeMediaManifestEnum includeMediaManifest;



  @JsonKey(

    name: r'include_checksums',
    required: true,
    includeIfNull: false,
  )


  final BackupJobCreateRequestIncludeChecksumsEnum includeChecksums;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'encryption_hint',
    required: false,
    includeIfNull: false,
  )


  final String? encryptionHint;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BackupJobCreateRequest &&
      other.includeMediaManifest == includeMediaManifest &&
      other.includeChecksums == includeChecksums &&
      other.timezone == timezone &&
      other.encryptionHint == encryptionHint;

    @override
    int get hashCode =>
        includeMediaManifest.hashCode +
        includeChecksums.hashCode +
        timezone.hashCode +
        (encryptionHint == null ? 0 : encryptionHint.hashCode);

  factory BackupJobCreateRequest.fromJson(Map<String, dynamic> json) => _$BackupJobCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BackupJobCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum BackupJobCreateRequestIncludeMediaManifestEnum {
@JsonValue('true')
true_('true');

const BackupJobCreateRequestIncludeMediaManifestEnum(this.value);

final String value;

@override
String toString() => value;
}



enum BackupJobCreateRequestIncludeChecksumsEnum {
@JsonValue('true')
true_('true');

const BackupJobCreateRequestIncludeChecksumsEnum(this.value);

final String value;

@override
String toString() => value;
}
