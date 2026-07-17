//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/organization_member.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_member_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrganizationMemberListResponse {
  /// Returns a new [OrganizationMemberListResponse] instance.
  OrganizationMemberListResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<OrganizationMember> data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrganizationMemberListResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory OrganizationMemberListResponse.fromJson(Map<String, dynamic> json) => _$OrganizationMemberListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationMemberListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

