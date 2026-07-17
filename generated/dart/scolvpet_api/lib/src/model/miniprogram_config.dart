//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'miniprogram_config.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MiniprogramConfig {
  /// Returns a new [MiniprogramConfig] instance.
  MiniprogramConfig({

     this.id,

    required  this.displayName,

     this.appId,

     this.boundPublicSlug,

    required  this.enabled,

     this.version,

     this.updatedAt,

    required  this.pipelineNote,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'display_name',
    required: true,
    includeIfNull: false,
  )


  final String displayName;



  @JsonKey(
    
    name: r'app_id',
    required: false,
    includeIfNull: false,
  )


  final String? appId;



  @JsonKey(
    
    name: r'bound_public_slug',
    required: false,
    includeIfNull: false,
  )


  final String? boundPublicSlug;



  @JsonKey(
    
    name: r'enabled',
    required: true,
    includeIfNull: false,
  )


  final bool enabled;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: false,
    includeIfNull: false,
  )


  final int? version;



  @JsonKey(
    
    name: r'updated_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



  @JsonKey(
    
    name: r'pipeline_note',
    required: true,
    includeIfNull: false,
  )


  final String pipelineNote;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MiniprogramConfig &&
      other.id == id &&
      other.displayName == displayName &&
      other.appId == appId &&
      other.boundPublicSlug == boundPublicSlug &&
      other.enabled == enabled &&
      other.version == version &&
      other.updatedAt == updatedAt &&
      other.pipelineNote == pipelineNote;

    @override
    int get hashCode =>
        id.hashCode +
        displayName.hashCode +
        (appId == null ? 0 : appId.hashCode) +
        (boundPublicSlug == null ? 0 : boundPublicSlug.hashCode) +
        enabled.hashCode +
        version.hashCode +
        updatedAt.hashCode +
        pipelineNote.hashCode;

  factory MiniprogramConfig.fromJson(Map<String, dynamic> json) => _$MiniprogramConfigFromJson(json);

  Map<String, dynamic> toJson() => _$MiniprogramConfigToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

