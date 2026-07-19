//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/error_object.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ErrorResponse {
  /// Returns a new [ErrorResponse] instance.
  ErrorResponse({

    required  this.error,

    required  this.meta,
  });

  @JsonKey(

    name: r'error',
    required: true,
    includeIfNull: false,
  )


  final ErrorObject error;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ErrorResponse &&
      other.error == error &&
      other.meta == meta;

    @override
    int get hashCode =>
        error.hashCode +
        meta.hashCode;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
