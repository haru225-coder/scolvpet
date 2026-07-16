//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum HamsterLifecycleStatus {
      @JsonValue(r'active')
      active(r'active'),
      @JsonValue(r'transferred')
      transferred(r'transferred'),
      @JsonValue(r'retired')
      retired(r'retired'),
      @JsonValue(r'deceased')
      deceased(r'deceased');

  const HamsterLifecycleStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
