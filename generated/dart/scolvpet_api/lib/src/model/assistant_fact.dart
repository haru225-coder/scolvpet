//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_fact.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantFact {
  /// Returns a new [AssistantFact] instance.
  AssistantFact({

    required  this.key,

    required  this.label,

    required  this.value,

    required  this.source_,
  });

  @JsonKey(

    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(

    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(

    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(

    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssistantFact &&
      other.key == key &&
      other.label == label &&
      other.value == value &&
      other.source_ == source_;

    @override
    int get hashCode =>
        key.hashCode +
        label.hashCode +
        value.hashCode +
        source_.hashCode;

  factory AssistantFact.fromJson(Map<String, dynamic> json) => _$AssistantFactFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantFactToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
