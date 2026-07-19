//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/pup_outcome_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wean_litter_request_items_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeanLitterRequestItemsInner {
  /// Returns a new [WeanLitterRequestItemsInner] instance.
  WeanLitterRequestItemsInner({

    required  this.pupIdentityId,

    required  this.outcomeStatus,

     this.destinationEnclosureId,

     this.notes,
  });

  @JsonKey(

    name: r'pup_identity_id',
    required: true,
    includeIfNull: false,
  )


  final String pupIdentityId;



  @JsonKey(

    name: r'outcome_status',
    required: true,
    includeIfNull: false,
  )


  final PupOutcomeStatus outcomeStatus;



  @JsonKey(

    name: r'destination_enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? destinationEnclosureId;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeanLitterRequestItemsInner &&
      other.pupIdentityId == pupIdentityId &&
      other.outcomeStatus == outcomeStatus &&
      other.destinationEnclosureId == destinationEnclosureId &&
      other.notes == notes;

    @override
    int get hashCode =>
        pupIdentityId.hashCode +
        outcomeStatus.hashCode +
        (destinationEnclosureId == null ? 0 : destinationEnclosureId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory WeanLitterRequestItemsInner.fromJson(Map<String, dynamic> json) => _$WeanLitterRequestItemsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$WeanLitterRequestItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
