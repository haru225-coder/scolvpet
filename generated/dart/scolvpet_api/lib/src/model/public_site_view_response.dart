//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/public_site_view.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_site_view_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicSiteViewResponse {
  /// Returns a new [PublicSiteViewResponse] instance.
  PublicSiteViewResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final PublicSiteView data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicSiteViewResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory PublicSiteViewResponse.fromJson(Map<String, dynamic> json) => _$PublicSiteViewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PublicSiteViewResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
