//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/data_center_summary_response_data.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_center_summary_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataCenterSummaryResponse {
  /// Returns a new [DataCenterSummaryResponse] instance.
  DataCenterSummaryResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final DataCenterSummaryResponseData data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DataCenterSummaryResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory DataCenterSummaryResponse.fromJson(Map<String, dynamic> json) => _$DataCenterSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DataCenterSummaryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
