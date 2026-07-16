//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum ReminderState {
      @JsonValue(r'pending')
      pending(r'pending'),
      @JsonValue(r'sent')
      sent(r'sent'),
      @JsonValue(r'read')
      read(r'read'),
      @JsonValue(r'failed')
      failed(r'failed'),
      @JsonValue(r'superseded')
      superseded(r'superseded'),
      @JsonValue(r'cancelled')
      cancelled(r'cancelled');

  const ReminderState(this.value);

  final String value;

  @override
  String toString() => value;
}
