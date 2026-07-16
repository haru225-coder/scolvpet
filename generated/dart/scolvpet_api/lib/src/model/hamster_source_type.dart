//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum HamsterSourceType {
      @JsonValue(r'born_here')
      bornHere(r'born_here'),
      @JsonValue(r'introduced')
      introduced(r'introduced'),
      @JsonValue(r'customer')
      customer(r'customer'),
      @JsonValue(r'imported')
      imported(r'imported');

  const HamsterSourceType(this.value);

  final String value;

  @override
  String toString() => value;
}
