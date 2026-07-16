//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum BatchTransactionStatus {
      @JsonValue(r'all_succeeded')
      allSucceeded(r'all_succeeded'),
      @JsonValue(r'partial')
      partial(r'partial'),
      @JsonValue(r'all_failed')
      allFailed(r'all_failed');

  const BatchTransactionStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
