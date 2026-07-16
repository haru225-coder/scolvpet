//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'complete_breeding_plan_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompleteBreedingPlanRequest {
  /// Returns a new [CompleteBreedingPlanRequest] instance.
  CompleteBreedingPlanRequest({

    required  this.completedAt,

    required  this.timezone,

     this.notes,
  });

  @JsonKey(
    
    name: r'completed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime completedAt;



  @JsonKey(
    
    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompleteBreedingPlanRequest &&
      other.completedAt == completedAt &&
      other.timezone == timezone &&
      other.notes == notes;

    @override
    int get hashCode =>
        completedAt.hashCode +
        timezone.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory CompleteBreedingPlanRequest.fromJson(Map<String, dynamic> json) => _$CompleteBreedingPlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteBreedingPlanRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

