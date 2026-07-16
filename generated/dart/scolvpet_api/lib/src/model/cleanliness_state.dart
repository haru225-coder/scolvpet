//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum CleanlinessState {
      @JsonValue(r'clean')
      clean(r'clean'),
      @JsonValue(r'partial_due')
      partialDue(r'partial_due'),
      @JsonValue(r'full_due')
      fullDue(r'full_due');

  const CleanlinessState(this.value);

  final String value;

  @override
  String toString() => value;
}
