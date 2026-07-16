//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum Sex {
      @JsonValue(r'male')
      male(r'male'),
      @JsonValue(r'female')
      female(r'female'),
      @JsonValue(r'unknown')
      unknown(r'unknown');

  const Sex(this.value);

  final String value;

  @override
  String toString() => value;
}
