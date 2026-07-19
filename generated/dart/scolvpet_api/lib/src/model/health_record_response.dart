//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/health_record.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_record_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthRecordResponse {
  /// Returns a new [HealthRecordResponse] instance.
  HealthRecordResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: true,
  )


  final HealthRecord? data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HealthRecordResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        (data == null ? 0 : data.hashCode) +
        meta.hashCode;

  factory HealthRecordResponse.fromJson(Map<String, dynamic> json) => _$HealthRecordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthRecordResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
