//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_dimensions.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureDimensions {
  /// Returns a new [EnclosureDimensions] instance.
  EnclosureDimensions({

    required  this.length,

    required  this.width,

    required  this.height,

     this.unit,
  });

          // minimum: 1
  @JsonKey(
    
    name: r'length',
    required: true,
    includeIfNull: false,
  )


  final int length;



          // minimum: 1
  @JsonKey(
    
    name: r'width',
    required: true,
    includeIfNull: false,
  )


  final int width;



          // minimum: 1
  @JsonKey(
    
    name: r'height',
    required: true,
    includeIfNull: false,
  )


  final int height;



  @JsonKey(
    
    name: r'unit',
    required: false,
    includeIfNull: false,
  )


  final EnclosureDimensionsUnitEnum? unit;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureDimensions &&
      other.length == length &&
      other.width == width &&
      other.height == height &&
      other.unit == unit;

    @override
    int get hashCode =>
        length.hashCode +
        width.hashCode +
        height.hashCode +
        unit.hashCode;

  factory EnclosureDimensions.fromJson(Map<String, dynamic> json) => _$EnclosureDimensionsFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureDimensionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum EnclosureDimensionsUnitEnum {
@JsonValue(r'mm')
mm(r'mm');

const EnclosureDimensionsUnitEnum(this.value);

final String value;

@override
String toString() => value;
}


