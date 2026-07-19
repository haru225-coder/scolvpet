//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_public_hamster_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthPublicHamsterRequest {
  /// Returns a new [GrowthPublicHamsterRequest] instance.
  GrowthPublicHamsterRequest({

     this.publicName,

     this.summary,

     this.traits,

    required  this.filmingStatus,

    required  this.published,

    required  this.consultable,

     this.ctaText,

     this.priceLabel,
  });

  @JsonKey(

    name: r'public_name',
    required: false,
    includeIfNull: false,
  )


  final String? publicName;



  @JsonKey(

    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(

    name: r'traits',
    required: false,
    includeIfNull: false,
  )


  final List<String>? traits;



  @JsonKey(

    name: r'filming_status',
    required: true,
    includeIfNull: false,
  )


  final GrowthPublicHamsterRequestFilmingStatusEnum filmingStatus;



  @JsonKey(

    name: r'published',
    required: true,
    includeIfNull: false,
  )


  final bool published;



  @JsonKey(

    name: r'consultable',
    required: true,
    includeIfNull: false,
  )


  final bool consultable;



  @JsonKey(

    name: r'cta_text',
    required: false,
    includeIfNull: false,
  )


  final String? ctaText;



  @JsonKey(

    name: r'price_label',
    required: false,
    includeIfNull: false,
  )


  final String? priceLabel;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthPublicHamsterRequest &&
      other.publicName == publicName &&
      other.summary == summary &&
      other.traits == traits &&
      other.filmingStatus == filmingStatus &&
      other.published == published &&
      other.consultable == consultable &&
      other.ctaText == ctaText &&
      other.priceLabel == priceLabel;

    @override
    int get hashCode =>
        publicName.hashCode +
        summary.hashCode +
        traits.hashCode +
        filmingStatus.hashCode +
        published.hashCode +
        consultable.hashCode +
        ctaText.hashCode +
        priceLabel.hashCode;

  factory GrowthPublicHamsterRequest.fromJson(Map<String, dynamic> json) => _$GrowthPublicHamsterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthPublicHamsterRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GrowthPublicHamsterRequestFilmingStatusEnum {
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'rest')
rest(r'rest'),
@JsonValue(r'restricted')
restricted(r'restricted');

const GrowthPublicHamsterRequestFilmingStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
