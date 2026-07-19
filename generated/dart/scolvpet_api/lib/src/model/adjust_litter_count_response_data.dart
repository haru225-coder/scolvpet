//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/reconciliation.dart';
import 'package:scolvpet_api/src/model/pup_identity.dart';
import 'package:scolvpet_api/src/model/litter_count_event.dart';
import 'package:scolvpet_api/src/model/litter.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'adjust_litter_count_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdjustLitterCountResponseData {
  /// Returns a new [AdjustLitterCountResponseData] instance.
  AdjustLitterCountResponseData({

    required  this.litter,

    required  this.countEvent,

    required  this.createdPupIdentities,

    required  this.closedPupIdentityIds,

    required  this.reconciliation,
  });

  @JsonKey(

    name: r'litter',
    required: true,
    includeIfNull: false,
  )


  final Litter litter;



  @JsonKey(

    name: r'count_event',
    required: true,
    includeIfNull: false,
  )


  final LitterCountEvent countEvent;



  @JsonKey(

    name: r'created_pup_identities',
    required: true,
    includeIfNull: false,
  )


  final List<PupIdentity> createdPupIdentities;



  @JsonKey(

    name: r'closed_pup_identity_ids',
    required: true,
    includeIfNull: false,
  )


  final List<String> closedPupIdentityIds;



  @JsonKey(

    name: r'reconciliation',
    required: true,
    includeIfNull: false,
  )


  final Reconciliation reconciliation;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdjustLitterCountResponseData &&
      other.litter == litter &&
      other.countEvent == countEvent &&
      other.createdPupIdentities == createdPupIdentities &&
      other.closedPupIdentityIds == closedPupIdentityIds &&
      other.reconciliation == reconciliation;

    @override
    int get hashCode =>
        litter.hashCode +
        countEvent.hashCode +
        createdPupIdentities.hashCode +
        closedPupIdentityIds.hashCode +
        reconciliation.hashCode;

  factory AdjustLitterCountResponseData.fromJson(Map<String, dynamic> json) => _$AdjustLitterCountResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustLitterCountResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
