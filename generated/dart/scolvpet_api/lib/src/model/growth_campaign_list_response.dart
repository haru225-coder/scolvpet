//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/growth_campaign.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_campaign_list_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthCampaignListResponse {
  /// Returns a new [GrowthCampaignListResponse] instance.
  GrowthCampaignListResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<GrowthCampaign> data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthCampaignListResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory GrowthCampaignListResponse.fromJson(Map<String, dynamic> json) => _$GrowthCampaignListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthCampaignListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
