//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrganizationUpdateRequest {
  /// Returns a new [OrganizationUpdateRequest] instance.
  OrganizationUpdateRequest({

     this.name,

     this.mode,

     this.timezone,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final OrganizationUpdateRequestModeEnum? mode;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrganizationUpdateRequest &&
      other.name == name &&
      other.mode == mode &&
      other.timezone == timezone;

    @override
    int get hashCode =>
        name.hashCode +
        mode.hashCode +
        timezone.hashCode;

  factory OrganizationUpdateRequest.fromJson(Map<String, dynamic> json) => _$OrganizationUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum OrganizationUpdateRequestModeEnum {
@JsonValue(r'personal')
personal(r'personal'),
@JsonValue(r'professional')
professional(r'professional');

const OrganizationUpdateRequestModeEnum(this.value);

final String value;

@override
String toString() => value;
}


