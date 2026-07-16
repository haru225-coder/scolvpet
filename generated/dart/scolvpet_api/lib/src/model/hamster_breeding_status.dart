//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum HamsterBreedingStatus {
      @JsonValue(r'candidate')
      candidate(r'candidate'),
      @JsonValue(r'active')
      active(r'active'),
      @JsonValue(r'resting')
      resting(r'resting'),
      @JsonValue(r'retired')
      retired(r'retired');

  const HamsterBreedingStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
