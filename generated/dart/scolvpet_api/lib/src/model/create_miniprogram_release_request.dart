//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_miniprogram_release_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateMiniprogramReleaseRequest {
  /// Returns a new [CreateMiniprogramReleaseRequest] instance.
  CreateMiniprogramReleaseRequest({

     this.versionLabel,

     this.title,

     this.summary,

     this.publicSlug,
  });

  @JsonKey(
    
    name: r'version_label',
    required: false,
    includeIfNull: false,
  )


  final String? versionLabel;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateMiniprogramReleaseRequest &&
      other.versionLabel == versionLabel &&
      other.title == title &&
      other.summary == summary &&
      other.publicSlug == publicSlug;

    @override
    int get hashCode =>
        versionLabel.hashCode +
        title.hashCode +
        (summary == null ? 0 : summary.hashCode) +
        (publicSlug == null ? 0 : publicSlug.hashCode);

  factory CreateMiniprogramReleaseRequest.fromJson(Map<String, dynamic> json) => _$CreateMiniprogramReleaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMiniprogramReleaseRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

