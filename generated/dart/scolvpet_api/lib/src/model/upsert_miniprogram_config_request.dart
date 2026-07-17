//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_miniprogram_config_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertMiniprogramConfigRequest {
  /// Returns a new [UpsertMiniprogramConfigRequest] instance.
  UpsertMiniprogramConfigRequest({

     this.displayName,

     this.appId,

     this.boundPublicSlug,

     this.enabled,
  });

  @JsonKey(
    
    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



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
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpsertMiniprogramConfigRequest &&
      other.displayName == displayName &&
      other.appId == appId &&
      other.boundPublicSlug == boundPublicSlug &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        displayName.hashCode +
        (appId == null ? 0 : appId.hashCode) +
        (boundPublicSlug == null ? 0 : boundPublicSlug.hashCode) +
        (enabled == null ? 0 : enabled.hashCode);

  factory UpsertMiniprogramConfigRequest.fromJson(Map<String, dynamic> json) => _$UpsertMiniprogramConfigRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertMiniprogramConfigRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

