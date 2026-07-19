//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_site.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicSite {
  /// Returns a new [PublicSite] instance.
  PublicSite({

     this.id,

    required  this.slug,

    required  this.title,

     this.tagline,

     this.about,

     this.contactWechat,

     this.contactPhone,

    required  this.themeColor,

    required  this.showStats,

    required  this.showContact,

    required  this.published,

     this.publishedAt,

     this.version,

     this.updatedAt,

     this.publicUrlPath,
  });

  @JsonKey(

    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(

    name: r'slug',
    required: true,
    includeIfNull: false,
  )


  final String slug;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'tagline',
    required: false,
    includeIfNull: false,
  )


  final String? tagline;



  @JsonKey(

    name: r'about',
    required: false,
    includeIfNull: false,
  )


  final String? about;



  @JsonKey(

    name: r'contact_wechat',
    required: false,
    includeIfNull: false,
  )


  final String? contactWechat;



  @JsonKey(

    name: r'contact_phone',
    required: false,
    includeIfNull: false,
  )


  final String? contactPhone;



  @JsonKey(

    name: r'theme_color',
    required: true,
    includeIfNull: false,
  )


  final String themeColor;



  @JsonKey(

    name: r'show_stats',
    required: true,
    includeIfNull: false,
  )


  final bool showStats;



  @JsonKey(

    name: r'show_contact',
    required: true,
    includeIfNull: false,
  )


  final bool showContact;



  @JsonKey(

    name: r'published',
    required: true,
    includeIfNull: false,
  )


  final bool published;



  @JsonKey(

    name: r'published_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? publishedAt;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: false,
    includeIfNull: false,
  )


  final int? version;



  @JsonKey(

    name: r'updated_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;



  @JsonKey(

    name: r'public_url_path',
    required: false,
    includeIfNull: false,
  )


  final String? publicUrlPath;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicSite &&
      other.id == id &&
      other.slug == slug &&
      other.title == title &&
      other.tagline == tagline &&
      other.about == about &&
      other.contactWechat == contactWechat &&
      other.contactPhone == contactPhone &&
      other.themeColor == themeColor &&
      other.showStats == showStats &&
      other.showContact == showContact &&
      other.published == published &&
      other.publishedAt == publishedAt &&
      other.version == version &&
      other.updatedAt == updatedAt &&
      other.publicUrlPath == publicUrlPath;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        title.hashCode +
        (tagline == null ? 0 : tagline.hashCode) +
        (about == null ? 0 : about.hashCode) +
        (contactWechat == null ? 0 : contactWechat.hashCode) +
        (contactPhone == null ? 0 : contactPhone.hashCode) +
        themeColor.hashCode +
        showStats.hashCode +
        showContact.hashCode +
        published.hashCode +
        (publishedAt == null ? 0 : publishedAt.hashCode) +
        version.hashCode +
        updatedAt.hashCode +
        publicUrlPath.hashCode;

  factory PublicSite.fromJson(Map<String, dynamic> json) => _$PublicSiteFromJson(json);

  Map<String, dynamic> toJson() => _$PublicSiteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
