//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/response_meta.dart';
import 'package:scolvpet_api/src/model/entitlement_snapshot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_snapshot_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EntitlementSnapshotResponse {
  /// Returns a new [EntitlementSnapshotResponse] instance.
  EntitlementSnapshotResponse({

    required  this.data,

    required  this.meta,
  });

  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final EntitlementSnapshot data;



  @JsonKey(
    
    name: r'meta',
    required: true,
    includeIfNull: false,
  )


  final ResponseMeta meta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EntitlementSnapshotResponse &&
      other.data == data &&
      other.meta == meta;

    @override
    int get hashCode =>
        data.hashCode +
        meta.hashCode;

  factory EntitlementSnapshotResponse.fromJson(Map<String, dynamic> json) => _$EntitlementSnapshotResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementSnapshotResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

