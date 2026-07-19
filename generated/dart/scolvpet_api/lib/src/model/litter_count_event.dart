//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter_count_event.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LitterCountEvent {
  /// Returns a new [LitterCountEvent] instance.
  LitterCountEvent({

    required  this.id,

    required  this.litterId,

    required  this.eventType,

    required  this.delta,

    required  this.occurredAt,

     this.reason,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'litter_id',
    required: true,
    includeIfNull: false,
  )


  final String litterId;



      /// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
  @JsonKey(

    name: r'event_type',
    required: true,
    includeIfNull: false,
  )


  final LitterCountEventEventTypeEnum eventType;



  @JsonKey(

    name: r'delta',
    required: true,
    includeIfNull: false,
  )


  final int delta;



  @JsonKey(

    name: r'occurred_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime occurredAt;



  @JsonKey(

    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LitterCountEvent &&
      other.id == id &&
      other.litterId == litterId &&
      other.eventType == eventType &&
      other.delta == delta &&
      other.occurredAt == occurredAt &&
      other.reason == reason;

    @override
    int get hashCode =>
        id.hashCode +
        litterId.hashCode +
        eventType.hashCode +
        delta.hashCode +
        occurredAt.hashCode +
        (reason == null ? 0 : reason.hashCode);

  factory LitterCountEvent.fromJson(Map<String, dynamic> json) => _$LitterCountEventFromJson(json);

  Map<String, dynamic> toJson() => _$LitterCountEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
enum LitterCountEventEventTypeEnum {
    /// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
@JsonValue(r'initial_alive')
initialAlive(r'initial_alive'),
    /// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
@JsonValue(r'discovered')
discovered(r'discovered'),
    /// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
@JsonValue(r'death')
death(r'death'),
    /// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
@JsonValue(r'transferred_out')
transferredOut(r'transferred_out'),
    /// confirm-birth 的 initial_alive 为正；discovered 为正；death/transferred_out 为负；correction 非零
@JsonValue(r'correction')
correction(r'correction');

const LitterCountEventEventTypeEnum(this.value);

final String value;

@override
String toString() => value;
}
