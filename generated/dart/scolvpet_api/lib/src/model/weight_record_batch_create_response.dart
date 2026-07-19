//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/weight_record_batch_create_response_data.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_record_batch_create_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightRecordBatchCreateResponse {
  /// Returns a new [WeightRecordBatchCreateResponse] instance.
  WeightRecordBatchCreateResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final WeightRecordBatchCreateResponseData data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeightRecordBatchCreateResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory WeightRecordBatchCreateResponse.fromJson(Map<String, dynamic> json) => _$WeightRecordBatchCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WeightRecordBatchCreateResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
