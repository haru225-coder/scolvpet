//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_public_site_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertPublicSiteRequest {
  /// Returns a new [UpsertPublicSiteRequest] instance.
  UpsertPublicSiteRequest({

    required  this.slug,

    required  this.title,

     this.tagline,

     this.about,

     this.contactWechat,

     this.contactPhone,

     this.themeColor = '#c77852',

     this.showStats = true,

     this.showContact = true,
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
    defaultValue: '#c77852',
    name: r'theme_color',
    required: false,
    includeIfNull: false,
  )


  final String? themeColor;



  @JsonKey(
    defaultValue: true,
    name: r'show_stats',
    required: false,
    includeIfNull: false,
  )


  final bool? showStats;



  @JsonKey(
    defaultValue: true,
    name: r'show_contact',
    required: false,
    includeIfNull: false,
  )


  final bool? showContact;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpsertPublicSiteRequest &&
      other.slug == slug &&
      other.title == title &&
      other.tagline == tagline &&
      other.about == about &&
      other.contactWechat == contactWechat &&
      other.contactPhone == contactPhone &&
      other.themeColor == themeColor &&
      other.showStats == showStats &&
      other.showContact == showContact;

    @override
    int get hashCode =>
        slug.hashCode +
        title.hashCode +
        (tagline == null ? 0 : tagline.hashCode) +
        (about == null ? 0 : about.hashCode) +
        (contactWechat == null ? 0 : contactWechat.hashCode) +
        (contactPhone == null ? 0 : contactPhone.hashCode) +
        themeColor.hashCode +
        (showStats == null ? 0 : showStats.hashCode) +
        (showContact == null ? 0 : showContact.hashCode);

  factory UpsertPublicSiteRequest.fromJson(Map<String, dynamic> json) => _$UpsertPublicSiteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertPublicSiteRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

