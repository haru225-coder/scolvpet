//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stud_listing.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StudListing {
  /// Returns a new [StudListing] instance.
  StudListing({

    required  this.id,

    required  this.ownerId,

    required  this.sireLabel,

    required  this.title,

    required  this.feeCents,

    required  this.currency,

     this.notes,

    required  this.published,

    required  this.version,

    required  this.updatedAt,

     this.catteryName,

    required  this.isMine,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(

    name: r'sire_label',
    required: true,
    includeIfNull: false,
  )


  final String sireLabel;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



          // minimum: 0
  @JsonKey(

    name: r'fee_cents',
    required: true,
    includeIfNull: false,
  )


  final int feeCents;



  @JsonKey(

    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(

    name: r'published',
    required: true,
    includeIfNull: false,
  )


  final bool published;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;



  @JsonKey(

    name: r'cattery_name',
    required: false,
    includeIfNull: false,
  )


  final String? catteryName;



  @JsonKey(

    name: r'is_mine',
    required: true,
    includeIfNull: false,
  )


  final bool isMine;





    @override
    bool operator ==(Object other) => identical(this, other) || other is StudListing &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.sireLabel == sireLabel &&
      other.title == title &&
      other.feeCents == feeCents &&
      other.currency == currency &&
      other.notes == notes &&
      other.published == published &&
      other.version == version &&
      other.updatedAt == updatedAt &&
      other.catteryName == catteryName &&
      other.isMine == isMine;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        sireLabel.hashCode +
        title.hashCode +
        feeCents.hashCode +
        currency.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        published.hashCode +
        version.hashCode +
        updatedAt.hashCode +
        catteryName.hashCode +
        isMine.hashCode;

  factory StudListing.fromJson(Map<String, dynamic> json) => _$StudListingFromJson(json);

  Map<String, dynamic> toJson() => _$StudListingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
