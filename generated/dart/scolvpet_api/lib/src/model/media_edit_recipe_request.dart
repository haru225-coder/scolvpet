//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/media_edit_recipe_request_operations_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_edit_recipe_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaEditRecipeRequest {
  /// Returns a new [MediaEditRecipeRequest] instance.
  MediaEditRecipeRequest({

    required  this.operations,

     this.outputFormat = MediaEditRecipeRequestOutputFormatEnum.jpeg,
  });

  @JsonKey(
    
    name: r'operations',
    required: true,
    includeIfNull: false,
  )


  final List<MediaEditRecipeRequestOperationsInner> operations;



  @JsonKey(
    defaultValue: MediaEditRecipeRequestOutputFormatEnum.jpeg,
    name: r'output_format',
    required: false,
    includeIfNull: false,
  )


  final MediaEditRecipeRequestOutputFormatEnum? outputFormat;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaEditRecipeRequest &&
      other.operations == operations &&
      other.outputFormat == outputFormat;

    @override
    int get hashCode =>
        operations.hashCode +
        outputFormat.hashCode;

  factory MediaEditRecipeRequest.fromJson(Map<String, dynamic> json) => _$MediaEditRecipeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MediaEditRecipeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MediaEditRecipeRequestOutputFormatEnum {
@JsonValue(r'jpeg')
jpeg(r'jpeg'),
@JsonValue(r'png')
png(r'png'),
@JsonValue(r'webp')
webp(r'webp');

const MediaEditRecipeRequestOutputFormatEnum(this.value);

final String value;

@override
String toString() => value;
}


