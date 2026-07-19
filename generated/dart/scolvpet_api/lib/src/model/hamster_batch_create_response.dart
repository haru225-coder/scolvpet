//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/hamster_batch_create_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_batch_create_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterBatchCreateResponse {
  /// Returns a new [HamsterBatchCreateResponse] instance.
  HamsterBatchCreateResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final HamsterBatchCreateResponseData data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterBatchCreateResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory HamsterBatchCreateResponse.fromJson(Map<String, dynamic> json) => _$HamsterBatchCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterBatchCreateResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
