//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_feature.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementFeature {
  /// Returns a new [EntitlementFeature] instance.
  EntitlementFeature({

    required  this.code,

    required  this.title,

    required  this.description,

    required  this.allowed,
  });

  @JsonKey(

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(

    name: r'allowed',
    required: true,
    includeIfNull: false,
  )


  final bool allowed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementFeature &&
      other.code == code &&
      other.title == title &&
      other.description == description &&
      other.allowed == allowed;

    @override
    int get hashCode =>
        code.hashCode +
        title.hashCode +
        description.hashCode +
        allowed.hashCode;

  factory EntitlementFeature.fromJson(Map<String, dynamic> json) => _$EntitlementFeatureFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementFeatureToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
