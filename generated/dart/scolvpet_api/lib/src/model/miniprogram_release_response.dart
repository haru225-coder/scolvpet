//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/miniprogram_release.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'miniprogram_release_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MiniprogramReleaseResponse {
  /// Returns a new [MiniprogramReleaseResponse] instance.
  MiniprogramReleaseResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final MiniprogramRelease data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MiniprogramReleaseResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory MiniprogramReleaseResponse.fromJson(Map<String, dynamic> json) => _$MiniprogramReleaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MiniprogramReleaseResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

