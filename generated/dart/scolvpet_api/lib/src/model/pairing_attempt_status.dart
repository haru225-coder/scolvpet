//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum PairingAttemptStatus {
      @JsonValue(r'active')
      active(r'active'),
      @JsonValue(r'separated')
      separated(r'separated'),
      @JsonValue(r'safety_hold')
      safetyHold(r'safety_hold'),
      @JsonValue(r'cancelled')
      cancelled(r'cancelled');

  const PairingAttemptStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
