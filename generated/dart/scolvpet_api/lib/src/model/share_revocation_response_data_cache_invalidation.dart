//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'share_revocation_response_data_cache_invalidation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ShareRevocationResponseDataCacheInvalidation {
  /// Returns a new [ShareRevocationResponseDataCacheInvalidation] instance.
  ShareRevocationResponseDataCacheInvalidation({

    required  this.status,

    required  this.outboxEventId,

    required  this.queuedAt,

    required  this.maxEdgeTtlSeconds,
  });

  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ShareRevocationResponseDataCacheInvalidationStatusEnum status;



  @JsonKey(

    name: r'outbox_event_id',
    required: true,
    includeIfNull: false,
  )


  final String outboxEventId;



  @JsonKey(

    name: r'queued_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime queuedAt;



  @JsonKey(

    name: r'max_edge_ttl_seconds',
    required: true,
    includeIfNull: false,
  )


  final ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum maxEdgeTtlSeconds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ShareRevocationResponseDataCacheInvalidation &&
      other.status == status &&
      other.outboxEventId == outboxEventId &&
      other.queuedAt == queuedAt &&
      other.maxEdgeTtlSeconds == maxEdgeTtlSeconds;

    @override
    int get hashCode =>
        status.hashCode +
        outboxEventId.hashCode +
        queuedAt.hashCode +
        maxEdgeTtlSeconds.hashCode;

  factory ShareRevocationResponseDataCacheInvalidation.fromJson(Map<String, dynamic> json) => _$ShareRevocationResponseDataCacheInvalidationFromJson(json);

  Map<String, dynamic> toJson() => _$ShareRevocationResponseDataCacheInvalidationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ShareRevocationResponseDataCacheInvalidationStatusEnum {
@JsonValue(r'queued')
queued(r'queued');

const ShareRevocationResponseDataCacheInvalidationStatusEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum {
@JsonValue(60)
number60('60');

const ShareRevocationResponseDataCacheInvalidationMaxEdgeTtlSecondsEnum(this.value);

final String value;

@override
String toString() => value;
}
