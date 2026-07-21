//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/growth_public_media.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'growth_public_hamster.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GrowthPublicHamster {
  /// Returns a new [GrowthPublicHamster] instance.
  GrowthPublicHamster({

    required  this.hamsterId,

    required  this.publicName,

     this.summary,

     this.traits,

     this.sex,

     this.variety,

     this.birthDate,

    required  this.filmingStatus,

    required  this.published,

    required  this.consultable,

    required  this.reservable,

     this.ctaText,

     this.priceLabel,

     this.media,
  });

  @JsonKey(

    name: r'hamster_id',
    required: true,
    includeIfNull: false,
  )


  final String hamsterId;



  @JsonKey(

    name: r'public_name',
    required: true,
    includeIfNull: false,
  )


  final String publicName;



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

    name: r'sex',
    required: false,
    includeIfNull: false,
  )


  final String? sex;



  @JsonKey(

    name: r'variety',
    required: false,
    includeIfNull: false,
  )


  final String? variety;



  @JsonKey(

    name: r'birth_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? birthDate;



  @JsonKey(

    name: r'filming_status',
    required: true,
    includeIfNull: false,
  )


  final GrowthPublicHamsterFilmingStatusEnum filmingStatus;



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



      /// Backend 唯一可订判定（公开可咨询且无 held/confirmed 预订）
  @JsonKey(

    name: r'reservable',
    required: true,
    includeIfNull: false,
  )


  final bool reservable;



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



  @JsonKey(

    name: r'media',
    required: false,
    includeIfNull: false,
  )


  final List<GrowthPublicMedia>? media;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GrowthPublicHamster &&
      other.hamsterId == hamsterId &&
      other.publicName == publicName &&
      other.summary == summary &&
      other.traits == traits &&
      other.sex == sex &&
      other.variety == variety &&
      other.birthDate == birthDate &&
      other.filmingStatus == filmingStatus &&
      other.published == published &&
      other.consultable == consultable &&
      other.reservable == reservable &&
      other.ctaText == ctaText &&
      other.priceLabel == priceLabel &&
      other.media == media;

    @override
    int get hashCode =>
        hamsterId.hashCode +
        publicName.hashCode +
        summary.hashCode +
        traits.hashCode +
        sex.hashCode +
        variety.hashCode +
        birthDate.hashCode +
        filmingStatus.hashCode +
        published.hashCode +
        consultable.hashCode +
        reservable.hashCode +
        ctaText.hashCode +
        priceLabel.hashCode +
        media.hashCode;

  factory GrowthPublicHamster.fromJson(Map<String, dynamic> json) => _$GrowthPublicHamsterFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthPublicHamsterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GrowthPublicHamsterFilmingStatusEnum {
@JsonValue(r'ready')
ready(r'ready'),
@JsonValue(r'rest')
rest(r'rest'),
@JsonValue(r'restricted')
restricted(r'restricted');

const GrowthPublicHamsterFilmingStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
