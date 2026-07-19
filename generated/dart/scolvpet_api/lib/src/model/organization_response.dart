//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/organization.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrganizationResponse {
  /// Returns a new [OrganizationResponse] instance.
  OrganizationResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final Organization data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrganizationResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) => _$OrganizationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
