//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_site_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicSiteView {
  /// Returns a new [PublicSiteView] instance.
  PublicSiteView({

    required  this.slug,

    required  this.title,

     this.tagline,

     this.about,

    required  this.themeColor,

     this.contactWechat,

     this.contactPhone,

     this.stats,

     this.organizationName,

     this.publishedAt,
  });

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

    name: r'theme_color',
    required: true,
    includeIfNull: false,
  )


  final String themeColor;



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

    name: r'stats',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? stats;



  @JsonKey(

    name: r'organization_name',
    required: false,
    includeIfNull: false,
  )


  final String? organizationName;



  @JsonKey(

    name: r'published_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? publishedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicSiteView &&
      other.slug == slug &&
      other.title == title &&
      other.tagline == tagline &&
      other.about == about &&
      other.themeColor == themeColor &&
      other.contactWechat == contactWechat &&
      other.contactPhone == contactPhone &&
      other.stats == stats &&
      other.organizationName == organizationName &&
      other.publishedAt == publishedAt;

    @override
    int get hashCode =>
        slug.hashCode +
        title.hashCode +
        (tagline == null ? 0 : tagline.hashCode) +
        (about == null ? 0 : about.hashCode) +
        themeColor.hashCode +
        (contactWechat == null ? 0 : contactWechat.hashCode) +
        (contactPhone == null ? 0 : contactPhone.hashCode) +
        stats.hashCode +
        (organizationName == null ? 0 : organizationName.hashCode) +
        (publishedAt == null ? 0 : publishedAt.hashCode);

  factory PublicSiteView.fromJson(Map<String, dynamic> json) => _$PublicSiteViewFromJson(json);

  Map<String, dynamic> toJson() => _$PublicSiteViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
