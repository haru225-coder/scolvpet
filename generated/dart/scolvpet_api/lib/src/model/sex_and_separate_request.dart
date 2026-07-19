//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/sex_and_separate_request_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sex_and_separate_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SexAndSeparateRequest {
  /// Returns a new [SexAndSeparateRequest] instance.
  SexAndSeparateRequest({

    required  this.separatedAt,

    required  this.timezone,

    required  this.items,
  });

  @JsonKey(

    name: r'separated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime separatedAt;



  @JsonKey(

    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(

    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<SexAndSeparateRequestItemsInner> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SexAndSeparateRequest &&
      other.separatedAt == separatedAt &&
      other.timezone == timezone &&
      other.items == items;

    @override
    int get hashCode =>
        separatedAt.hashCode +
        timezone.hashCode +
        items.hashCode;

  factory SexAndSeparateRequest.fromJson(Map<String, dynamic> json) => _$SexAndSeparateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SexAndSeparateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
