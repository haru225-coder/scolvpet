//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_edit_recipe_request_operations_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaEditRecipeRequestOperationsInner {
  /// Returns a new [MediaEditRecipeRequestOperationsInner] instance.
  MediaEditRecipeRequestOperationsInner({

    required  this.type,

    required  this.parameters,
  });

  @JsonKey(

    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final MediaEditRecipeRequestOperationsInnerTypeEnum type;



  @JsonKey(

    name: r'parameters',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> parameters;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaEditRecipeRequestOperationsInner &&
      other.type == type &&
      other.parameters == parameters;

    @override
    int get hashCode =>
        type.hashCode +
        parameters.hashCode;

  factory MediaEditRecipeRequestOperationsInner.fromJson(Map<String, dynamic> json) => _$MediaEditRecipeRequestOperationsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$MediaEditRecipeRequestOperationsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MediaEditRecipeRequestOperationsInnerTypeEnum {
@JsonValue(r'crop')
crop(r'crop'),
@JsonValue(r'rotate')
rotate(r'rotate'),
@JsonValue(r'filter')
filter(r'filter'),
@JsonValue(r'annotation')
annotation(r'annotation');

const MediaEditRecipeRequestOperationsInnerTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
