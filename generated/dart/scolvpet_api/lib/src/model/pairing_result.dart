//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum PairingResult {
      @JsonValue(r'effective')
      effective(r'effective'),
      @JsonValue(r'uncertain')
      uncertain(r'uncertain'),
      @JsonValue(r'ineffective')
      ineffective(r'ineffective'),
      @JsonValue(r'safety_stop')
      safetyStop(r'safety_stop');

  const PairingResult(this.value);

  final String value;

  @override
  String toString() => value;
}
