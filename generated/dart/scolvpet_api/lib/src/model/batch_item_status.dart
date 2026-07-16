//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum BatchItemStatus {
      @JsonValue(r'succeeded')
      succeeded(r'succeeded'),
      @JsonValue(r'failed')
      failed(r'failed'),
      @JsonValue(r'skipped')
      skipped(r'skipped'),
      @JsonValue(r'succeeded_with_warning')
      succeededWithWarning(r'succeeded_with_warning'),
      @JsonValue(r'succeeded_with_exception')
      succeededWithException(r'succeeded_with_exception');

  const BatchItemStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
