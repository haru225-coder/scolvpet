//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/growth_campaign.dart';
import 'package:scolvpet_api/src/model/growth_public_hamster.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_growth_catalog.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicGrowthCatalog {
  /// Returns a new [PublicGrowthCatalog] instance.
  PublicGrowthCatalog({

    required  this.site,

    required  this.hamsters,

     this.campaign,
  });

  @JsonKey(

    name: r'site',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> site;



  @JsonKey(

    name: r'hamsters',
    required: true,
    includeIfNull: false,
  )


  final List<GrowthPublicHamster> hamsters;



  @JsonKey(

    name: r'campaign',
    required: false,
    includeIfNull: false,
  )


  final GrowthCampaign? campaign;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicGrowthCatalog &&
      other.site == site &&
      other.hamsters == hamsters &&
      other.campaign == campaign;

    @override
    int get hashCode =>
        site.hashCode +
        hamsters.hashCode +
        (campaign == null ? 0 : campaign.hashCode);

  factory PublicGrowthCatalog.fromJson(Map<String, dynamic> json) => _$PublicGrowthCatalogFromJson(json);

  Map<String, dynamic> toJson() => _$PublicGrowthCatalogToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
