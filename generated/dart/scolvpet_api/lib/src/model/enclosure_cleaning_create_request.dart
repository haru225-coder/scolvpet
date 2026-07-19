//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/enclosure_cleaning_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_cleaning_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureCleaningCreateRequest {
  /// Returns a new [EnclosureCleaningCreateRequest] instance.
  EnclosureCleaningCreateRequest({

    required  this.cleaningType,

    required  this.performedAt,

     this.supplies,

     this.notes,

     this.correctsCleaningRecordId,

     this.correctionReason,
  });

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
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? supplies;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureCleaningCreateRequest &&
      other.cleaningType == cleaningType &&
      other.performedAt == performedAt &&
      other.supplies == supplies &&
      other.notes == notes &&
      other.correctsCleaningRecordId == correctsCleaningRecordId &&
      other.correctionReason == correctionReason;

    @override
    int get hashCode =>
        cleaningType.hashCode +
        performedAt.hashCode +
        supplies.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        (correctsCleaningRecordId == null ? 0 : correctsCleaningRecordId.hashCode) +
        (correctionReason == null ? 0 : correctionReason.hashCode);

  factory EnclosureCleaningCreateRequest.fromJson(Map<String, dynamic> json) => _$EnclosureCleaningCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureCleaningCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
