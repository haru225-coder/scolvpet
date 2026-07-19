//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'field_error.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FieldError {
  /// Returns a new [FieldError] instance.
  FieldError({

    required  this.field,

    required  this.code,

    required  this.message,
  });

  @JsonKey(

    name: r'field',
    required: true,
    includeIfNull: false,
  )


  final String field;



  @JsonKey(

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(

    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FieldError &&
      other.field == field &&
      other.code == code &&
      other.message == message;

    @override
    int get hashCode =>
        field.hashCode +
        code.hashCode +
        message.hashCode;

  factory FieldError.fromJson(Map<String, dynamic> json) => _$FieldErrorFromJson(json);

  Map<String, dynamic> toJson() => _$FieldErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
