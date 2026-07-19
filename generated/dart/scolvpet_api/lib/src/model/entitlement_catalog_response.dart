//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/plan_catalog_entry.dart';
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_catalog_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementCatalogResponse {
  /// Returns a new [EntitlementCatalogResponse] instance.
  EntitlementCatalogResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final List<PlanCatalogEntry> data;



  @JsonKey(

    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementCatalogResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory EntitlementCatalogResponse.fromJson(Map<String, dynamic> json) => _$EntitlementCatalogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementCatalogResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
