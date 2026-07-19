//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/litter_state.dart';
import 'package:scolvpet_api/src/model/dam_condition.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'litter.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Litter {
  /// Returns a new [Litter] instance.
  Litter({

    required  this.id,

    required  this.ownerId,

    required  this.origin,

    required  this.code,

     this.breedingPlanId,

     this.sireId,

     this.damId,

     this.bornAt,

    required  this.initialAliveCount,

    required  this.initialOtherCount,

    required  this.currentManagedCount,

    required  this.state,

     this.enclosureId,

    required  this.damCondition,

     this.weanedAt,

     this.sexSeparatedAt,

     this.reconciledAt,

     this.notes,

    required  this.version,

    required  this.createdAt,

    required  this.updatedAt,
  });

  @JsonKey(

    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(

    name: r'owner_id',
    required: true,
    includeIfNull: false,
  )


  final String ownerId;



  @JsonKey(

    name: r'origin',
    required: true,
    includeIfNull: false,
  )


  final LitterOriginEnum origin;



  @JsonKey(

    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(

    name: r'breeding_plan_id',
    required: false,
    includeIfNull: false,
  )


  final String? breedingPlanId;



  @JsonKey(

    name: r'sire_id',
    required: false,
    includeIfNull: false,
  )


  final String? sireId;



  @JsonKey(

    name: r'dam_id',
    required: false,
    includeIfNull: false,
  )


  final String? damId;



  @JsonKey(

    name: r'born_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? bornAt;



          // minimum: 0
  @JsonKey(

    name: r'initial_alive_count',
    required: true,
    includeIfNull: false,
  )


  final int initialAliveCount;



          // minimum: 0
  @JsonKey(

    name: r'initial_other_count',
    required: true,
    includeIfNull: false,
  )


  final int initialOtherCount;



          // minimum: 0
  @JsonKey(

    name: r'current_managed_count',
    required: true,
    includeIfNull: false,
  )


  final int currentManagedCount;



  @JsonKey(

    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final LitterState state;



  @JsonKey(

    name: r'enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? enclosureId;



  @JsonKey(

    name: r'dam_condition',
    required: true,
    includeIfNull: false,
  )


  final DamCondition damCondition;



  @JsonKey(

    name: r'weaned_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? weanedAt;



  @JsonKey(

    name: r'sex_separated_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? sexSeparatedAt;



  @JsonKey(

    name: r'reconciled_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? reconciledAt;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



          // minimum: 1
  @JsonKey(

    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;



  @JsonKey(

    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(

    name: r'updated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Litter &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.origin == origin &&
      other.code == code &&
      other.breedingPlanId == breedingPlanId &&
      other.sireId == sireId &&
      other.damId == damId &&
      other.bornAt == bornAt &&
      other.initialAliveCount == initialAliveCount &&
      other.initialOtherCount == initialOtherCount &&
      other.currentManagedCount == currentManagedCount &&
      other.state == state &&
      other.enclosureId == enclosureId &&
      other.damCondition == damCondition &&
      other.weanedAt == weanedAt &&
      other.sexSeparatedAt == sexSeparatedAt &&
      other.reconciledAt == reconciledAt &&
      other.notes == notes &&
      other.version == version &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        id.hashCode +
        ownerId.hashCode +
        origin.hashCode +
        code.hashCode +
        (breedingPlanId == null ? 0 : breedingPlanId.hashCode) +
        (sireId == null ? 0 : sireId.hashCode) +
        (damId == null ? 0 : damId.hashCode) +
        (bornAt == null ? 0 : bornAt.hashCode) +
        initialAliveCount.hashCode +
        initialOtherCount.hashCode +
        currentManagedCount.hashCode +
        state.hashCode +
        (enclosureId == null ? 0 : enclosureId.hashCode) +
        damCondition.hashCode +
        (weanedAt == null ? 0 : weanedAt.hashCode) +
        (sexSeparatedAt == null ? 0 : sexSeparatedAt.hashCode) +
        (reconciledAt == null ? 0 : reconciledAt.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        version.hashCode +
        createdAt.hashCode +
        updatedAt.hashCode;

  factory Litter.fromJson(Map<String, dynamic> json) => _$LitterFromJson(json);

  Map<String, dynamic> toJson() => _$LitterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum LitterOriginEnum {
@JsonValue(r'breeding')
breeding(r'breeding'),
@JsonValue(r'import')
import_(r'import');

const LitterOriginEnum(this.value);

final String value;

@override
String toString() => value;
}
