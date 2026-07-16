//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/share_page.dart';
import 'package:scolvpet_api/src/model/share_revocation_response_data_cache_invalidation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_revocation_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareRevocationResponseData {
  /// Returns a new [ShareRevocationResponseData] instance.
  ShareRevocationResponseData({

    required  this.share,

    required  this.revokedAt,

    required  this.cacheInvalidation,
  });

  @JsonKey(
    
    name: r'share',
    required: true,
    includeIfNull: false,
  )


  final SharePage share;



  @JsonKey(
    
    name: r'revoked_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime revokedAt;



  @JsonKey(
    
    name: r'cache_invalidation',
    required: true,
    includeIfNull: false,
  )


  final ShareRevocationResponseDataCacheInvalidation cacheInvalidation;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareRevocationResponseData &&
      other.share == share &&
      other.revokedAt == revokedAt &&
      other.cacheInvalidation == cacheInvalidation;

    @override
    int get hashCode =>
        share.hashCode +
        revokedAt.hashCode +
        cacheInvalidation.hashCode;

  factory ShareRevocationResponseData.fromJson(Map<String, dynamic> json) => _$ShareRevocationResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ShareRevocationResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

