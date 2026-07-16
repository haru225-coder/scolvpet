//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum TaskState {
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'in_progress')
      inProgress(r'in_progress'),
      @JsonValue(r'completed')
      completed(r'completed'),
      @JsonValue(r'snoozed')
      snoozed(r'snoozed'),
      @JsonValue(r'cancelled')
      cancelled(r'cancelled'),
      @JsonValue(r'superseded')
      superseded(r'superseded');

  const TaskState(this.value);

  final String value;

  @override
  String toString() => value;
}
