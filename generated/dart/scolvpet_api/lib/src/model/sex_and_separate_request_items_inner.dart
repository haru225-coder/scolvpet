//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/sex.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sex_and_separate_request_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SexAndSeparateRequestItemsInner {
  /// Returns a new [SexAndSeparateRequestItemsInner] instance.
  SexAndSeparateRequestItemsInner({

    required  this.pupIdentityId,

    required  this.sex,

     this.sexConfidence,

    required  this.destinationEnclosureId,

    required  this.requiresRecheck,

     this.notes,
  });

  @JsonKey(
    
    name: r'pup_identity_id',
    required: true,
    includeIfNull: false,
  )


  final String pupIdentityId;



  @JsonKey(
    
    name: r'sex',
    required: true,
    includeIfNull: false,
  )


  final Sex sex;



          // minimum: 0
          // maximum: 1
  @JsonKey(
    
    name: r'sex_confidence',
    required: false,
    includeIfNull: false,
  )


  final num? sexConfidence;



  @JsonKey(
    
    name: r'destination_enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String destinationEnclosureId;



  @JsonKey(
    
    name: r'requires_recheck',
    required: true,
    includeIfNull: false,
  )


  final bool requiresRecheck;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SexAndSeparateRequestItemsInner &&
      other.pupIdentityId == pupIdentityId &&
      other.sex == sex &&
      other.sexConfidence == sexConfidence &&
      other.destinationEnclosureId == destinationEnclosureId &&
      other.requiresRecheck == requiresRecheck &&
      other.notes == notes;

    @override
    int get hashCode =>
        pupIdentityId.hashCode +
        sex.hashCode +
        (sexConfidence == null ? 0 : sexConfidence.hashCode) +
        destinationEnclosureId.hashCode +
        requiresRecheck.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory SexAndSeparateRequestItemsInner.fromJson(Map<String, dynamic> json) => _$SexAndSeparateRequestItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$SexAndSeparateRequestItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

