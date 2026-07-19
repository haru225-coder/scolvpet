//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/enclosure_cleaning_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_cleaning.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureCleaning {
  /// Returns a new [EnclosureCleaning] instance.
  EnclosureCleaning({

    required  this.id,

    required  this.enclosureId,

    required  this.cleaningType,

    required  this.performedAt,

    required  this.supplies,

     this.notes,

     this.correctsCleaningRecordId,

     this.correctionReason,

    required  this.createdAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'enclosure_id',
    required: true,
    includeIfNull: false,
  )


  final String enclosureId;



  @JsonKey(

    name: r'cleaning_type',
    required: true,
    includeIfNull: false,
  )


  final EnclosureCleaningType cleaningType;



  @JsonKey(

    name: r'performed_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime performedAt;



  @JsonKey(

    name: r'supplies',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> supplies;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(

    name: r'corrects_cleaning_record_id',
    required: false,
    includeIfNull: false,
  )


  final String? correctsCleaningRecordId;



  @JsonKey(

    name: r'correction_reason',
    required: false,
    includeIfNull: false,
  )


  final String? correctionReason;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureCleaning &&
      other.id == id &&
      other.enclosureId == enclosureId &&
      other.cleaningType == cleaningType &&
      other.performedAt == performedAt &&
      other.supplies == supplies &&
      other.notes == notes &&
      other.correctsCleaningRecordId == correctsCleaningRecordId &&
      other.correctionReason == correctionReason &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        enclosureId.hashCode +
        cleaningType.hashCode +
        performedAt.hashCode +
        supplies.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (correctsCleaningRecordId == null ? 0 : correctsCleaningRecordId.hashCode) +
        (correctionReason == null ? 0 : correctionReason.hashCode) +
        createdAt.hashCode;

  factory EnclosureCleaning.fromJson(Map<String, dynamic> json) => _$EnclosureCleaningFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureCleaningToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
