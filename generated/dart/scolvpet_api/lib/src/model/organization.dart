//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Organization {
  /// Returns a new [Organization] instance.
  Organization({

    required  this.id,

    required  this.ownerId,

    required  this.name,

    required  this.mode,

     this.timezone = 'Asia/Shanghai',

    required  this.weightUnit,

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



      /// 由认证上下文确定
  @JsonKey(

    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(

    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(

    name: r'mode',
    required: true,
    includeIfNull: false,
  )


  final OrganizationModeEnum mode;



  @JsonKey(
    defaultValue: 'Asia/Shanghai',
    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'weight_unit',
    required: true,
    includeIfNull: false,
  )


  final OrganizationWeightUnitEnum weightUnit;



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
    bool operator ==(Object other) => identical(this, other) || other is Organization &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.name == name &&
      other.mode == mode &&
      other.timezone == timezone &&
      other.weightUnit == weightUnit &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        name.hashCode +
        mode.hashCode +
        timezone.hashCode +
        weightUnit.hashCode +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum OrganizationModeEnum {
@JsonValue(r'personal')
personal(r'personal'),
@JsonValue(r'professional')
professional(r'professional');

const OrganizationModeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum OrganizationWeightUnitEnum {
@JsonValue(r'g')
g(r'g');

const OrganizationWeightUnitEnum(this.value);

final String value;

@override
String toString() => value;
}
