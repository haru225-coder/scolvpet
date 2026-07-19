//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/async_job.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_edit_recipe_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaEditRecipeResponseData {
  /// Returns a new [MediaEditRecipeResponseData] instance.
  MediaEditRecipeResponseData({

    required  this.sourceMediaId,

    required  this.recipeId,

    required  this.job,
  });

  @JsonKey(

    name: r'source_media_id',
    required: true,
    includeIfNull: false,
  )


  final String sourceMediaId;



  @JsonKey(

    name: r'recipe_id',
    required: true,
    includeIfNull: false,
  )


  final String recipeId;



  @JsonKey(

    name: r'job',
    required: true,
    includeIfNull: false,
  )


  final AsyncJob job;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MediaEditRecipeResponseData &&
      other.sourceMediaId == sourceMediaId &&
      other.recipeId == recipeId &&
      other.job == job;

    @override
    int get hashCode =>
        sourceMediaId.hashCode +
        recipeId.hashCode +
        job.hashCode;

  factory MediaEditRecipeResponseData.fromJson(Map<String, dynamic> json) => _$MediaEditRecipeResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$MediaEditRecipeResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
