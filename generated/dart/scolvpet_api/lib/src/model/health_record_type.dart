//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum HealthRecordType {
      @JsonValue(r'daily_check')
      dailyCheck(r'daily_check'),
      @JsonValue(r'anomaly')
      anomaly(r'anomaly'),
      @JsonValue(r'medication')
      medication(r'medication'),
      @JsonValue(r'follow_up')
      followUp(r'follow_up'),
      @JsonValue(r'isolation')
      isolation(r'isolation'),
      @JsonValue(r'death')
      death(r'death');

  const HealthRecordType(this.value);

  final String value;

  @override
  String toString() => value;
}
