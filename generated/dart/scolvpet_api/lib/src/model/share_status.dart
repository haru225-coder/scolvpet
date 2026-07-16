//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum ShareStatus {
      @JsonValue(r'active')
      active(r'active'),
      @JsonValue(r'expired')
      expired(r'expired'),
      @JsonValue(r'revoked')
      revoked(r'revoked');

  const ShareStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
