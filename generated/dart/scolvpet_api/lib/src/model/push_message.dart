//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushMessage {
  /// Returns a new [PushMessage] instance.
  PushMessage({

    required  this.id,

    required  this.title,

    required  this.body,

    required  this.data,

    required  this.status,

     this.targetDeviceId,

    required  this.provider,

     this.providerMessageId,

    required  this.attemptCount,

     this.lastError,

     this.sentAt,

    required  this.version,

    required  this.createdAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(

    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(

    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> data;



  @JsonKey(

    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final PushMessageStatusEnum status;



  @JsonKey(

    name: r'target_device_id',
    required: false,
    includeIfNull: false,
  )


  final String? targetDeviceId;



  @JsonKey(

    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final String provider;



  @JsonKey(

    name: r'provider_message_id',
    required: false,
    includeIfNull: false,
  )


  final String? providerMessageId;



          // minimum: 0
  @JsonKey(

    name: r'attempt_count',
    required: true,
    includeIfNull: false,
  )


  final int attemptCount;



  @JsonKey(

    name: r'last_error',
    required: false,
    includeIfNull: false,
  )


  final String? lastError;



  @JsonKey(

    name: r'sent_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? sentAt;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PushMessage &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.data == data &&
      other.status == status &&
      other.targetDeviceId == targetDeviceId &&
      other.provider == provider &&
      other.providerMessageId == providerMessageId &&
      other.attemptCount == attemptCount &&
      other.lastError == lastError &&
      other.sentAt == sentAt &&
      other.version == version &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        body.hashCode +
        data.hashCode +
        status.hashCode +
        (targetDeviceId == null ? 0 : targetDeviceId.hashCode) +
        provider.hashCode +
        (providerMessageId == null ? 0 : providerMessageId.hashCode) +
        attemptCount.hashCode +
        (lastError == null ? 0 : lastError.hashCode) +
        (sentAt == null ? 0 : sentAt.hashCode) +
        version.hashCode +
        createdAt.hashCode;

  factory PushMessage.fromJson(Map<String, dynamic> json) => _$PushMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PushMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PushMessageStatusEnum {
@JsonValue(r'queued')
queued(r'queued'),
@JsonValue(r'sending')
sending(r'sending'),
@JsonValue(r'sent')
sent(r'sent'),
@JsonValue(r'failed')
failed(r'failed');

const PushMessageStatusEnum(this.value);

final String value;

@override
String toString() => value;
}
