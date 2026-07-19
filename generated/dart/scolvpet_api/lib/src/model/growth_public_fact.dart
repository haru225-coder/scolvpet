//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_public_fact.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthPublicFact {
  /// Returns a new [GrowthPublicFact] instance.
  GrowthPublicFact({

    required  this.key,

    required  this.value,

    required  this.source_,
  });

  @JsonKey(

    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(

    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(

    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthPublicFact &&
      other.key == key &&
      other.value == value &&
      other.source_ == source_;

    @override
    int get hashCode =>
        key.hashCode +
        value.hashCode +
        source_.hashCode;

  factory GrowthPublicFact.fromJson(Map<String, dynamic> json) => _$GrowthPublicFactFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthPublicFactToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
