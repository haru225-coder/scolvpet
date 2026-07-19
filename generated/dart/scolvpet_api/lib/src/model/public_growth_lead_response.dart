//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_lead_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthLeadResponse {
  /// Returns a new [PublicGrowthLeadResponse] instance.
  PublicGrowthLeadResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthLeadResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory PublicGrowthLeadResponse.fromJson(Map<String, dynamic> json) => _$PublicGrowthLeadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthLeadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
