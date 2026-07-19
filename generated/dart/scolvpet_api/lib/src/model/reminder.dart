//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reminder_delivery.dart';
import 'package:scolvpet_api/src/model/reminder_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reminder {
  /// Returns a new [Reminder] instance.
  Reminder({

    required  this.id,

    required  this.ruleCode,

     this.ruleVersion,

     this.baseEventId,

     this.targetType,

     this.targetId,

    required  this.scheduledAt,

    required  this.state,

     this.supersededBy,

    required  this.channelStatuses,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'rule_code',
    required: true,
    includeIfNull: false,
  )


  final String ruleCode;



  @JsonKey(

    name: r'rule_version',
    required: false,
    includeIfNull: false,
  )


  final String? ruleVersion;



  @JsonKey(

    name: r'base_event_id',
    required: false,
    includeIfNull: false,
  )


  final String? baseEventId;



  @JsonKey(

    name: r'target_type',
    required: false,
    includeIfNull: false,
  )


  final String? targetType;



  @JsonKey(

    name: r'target_id',
    required: false,
    includeIfNull: false,
  )


  final String? targetId;



  @JsonKey(

    name: r'scheduled_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime scheduledAt;



  @JsonKey(

    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final ReminderState state;



  @JsonKey(

    name: r'superseded_by',
    required: false,
    includeIfNull: false,
  )


  final String? supersededBy;



  @JsonKey(

    name: r'channel_statuses',
    required: true,
    includeIfNull: false,
  )


  final List<ReminderDelivery> channelStatuses;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Reminder &&
      other.id == id &&
      other.ruleCode == ruleCode &&
      other.ruleVersion == ruleVersion &&
      other.baseEventId == baseEventId &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.scheduledAt == scheduledAt &&
      other.state == state &&
      other.supersededBy == supersededBy &&
      other.channelStatuses == channelStatuses;

    @override
    int get hashCode =>
        id.hashCode +
        ruleCode.hashCode +
        (ruleVersion == null ? 0 : ruleVersion.hashCode) +
        (baseEventId == null ? 0 : baseEventId.hashCode) +
        (targetType == null ? 0 : targetType.hashCode) +
        (targetId == null ? 0 : targetId.hashCode) +
        scheduledAt.hashCode +
        state.hashCode +
        (supersededBy == null ? 0 : supersededBy.hashCode) +
        channelStatuses.hashCode;

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
