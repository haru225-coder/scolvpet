//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plan_catalog_entry.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanCatalogEntry {
  /// Returns a new [PlanCatalogEntry] instance.
  PlanCatalogEntry({

    required  this.code,

    required  this.title,

    required  this.description,

    required  this.priceHint,

    required  this.features,

    required  this.limits,

    required  this.enforcement,

     this.highlight,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final PlanCatalogEntryCodeEnum code;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    
    name: r'price_hint',
    required: true,
    includeIfNull: false,
  )


  final String priceHint;



  @JsonKey(
    
    name: r'features',
    required: true,
    includeIfNull: false,
  )


  final Map<String, bool> features;



  @JsonKey(
    
    name: r'limits',
    required: true,
    includeIfNull: false,
  )


  final Map<String, num> limits;



  @JsonKey(
    
    name: r'enforcement',
    required: true,
    includeIfNull: false,
  )


  final PlanCatalogEntryEnforcementEnum enforcement;



  @JsonKey(
    
    name: r'highlight',
    required: false,
    includeIfNull: false,
  )


  final bool? highlight;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlanCatalogEntry &&
      other.code == code &&
      other.title == title &&
      other.description == description &&
      other.priceHint == priceHint &&
      other.features == features &&
      other.limits == limits &&
      other.enforcement == enforcement &&
      other.highlight == highlight;

    @override
    int get hashCode =>
        code.hashCode +
        title.hashCode +
        description.hashCode +
        priceHint.hashCode +
        features.hashCode +
        limits.hashCode +
        enforcement.hashCode +
        highlight.hashCode;

  factory PlanCatalogEntry.fromJson(Map<String, dynamic> json) => _$PlanCatalogEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PlanCatalogEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PlanCatalogEntryCodeEnum {
@JsonValue(r'free')
free(r'free'),
@JsonValue(r'pro')
pro(r'pro');

const PlanCatalogEntryCodeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum PlanCatalogEntryEnforcementEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'soft')
soft(r'soft'),
@JsonValue(r'hard')
hard(r'hard');

const PlanCatalogEntryEnforcementEnum(this.value);

final String value;

@override
String toString() => value;
}


