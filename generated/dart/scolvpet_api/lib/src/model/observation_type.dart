//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum ObservationType {
      @JsonValue(r'contact')
      contact(r'contact'),
      @JsonValue(r'chase')
      chase(r'chase'),
      @JsonValue(r'conflict')
      conflict(r'conflict'),
      @JsonValue(r'mating')
      mating(r'mating'),
      @JsonValue(r'separated')
      separated(r'separated'),
      @JsonValue(r'other')
      other(r'other');

  const ObservationType(this.value);

  final String value;

  @override
  String toString() => value;
}
