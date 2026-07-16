//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/dam_condition.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'confirm_birth_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmBirthRequest {
  /// Returns a new [ConfirmBirthRequest] instance.
  ConfirmBirthRequest({

    required  this.bornAt,

     this.enclosureId,

    required  this.initialAliveCount,

    required  this.initialOtherCount,

    required  this.damCondition,

    required  this.outcomeReason,

     this.temporaryCodePrefix,

     this.temporaryCodes,

    required  this.timezone,

     this.notes,
  });

  @JsonKey(
    
    name: r'born_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime bornAt;



      /// initial_alive_count > 0 时必填；N=0 时必须省略或为 null
  @JsonKey(
    
    name: r'enclosure_id',
    required: false,
    includeIfNull: false,
  )


  final String? enclosureId;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'initial_alive_count',
    required: true,
    includeIfNull: false,
  )


  final int initialAliveCount;



          // minimum: 0
          // maximum: 100
  @JsonKey(
    
    name: r'initial_other_count',
    required: true,
    includeIfNull: false,
  )


  final int initialOtherCount;



  @JsonKey(
    
    name: r'dam_condition',
    required: true,
    includeIfNull: false,
  )


  final DamCondition damCondition;



      /// 生产结果原因；N=0 时必须明确无活仔原因
  @JsonKey(
    
    name: r'outcome_reason',
    required: true,
    includeIfNull: false,
  )


  final String outcomeReason;



  @JsonKey(
    
    name: r'temporary_code_prefix',
    required: false,
    includeIfNull: false,
  )


  final String? temporaryCodePrefix;



      /// 若提供，数量必须等于 initial_alive_count
  @JsonKey(
    
    name: r'temporary_codes',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? temporaryCodes;



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
    bool operator ==(Object other) => identical(this, other) || other is ConfirmBirthRequest &&
      other.bornAt == bornAt &&
      other.enclosureId == enclosureId &&
      other.initialAliveCount == initialAliveCount &&
      other.initialOtherCount == initialOtherCount &&
      other.damCondition == damCondition &&
      other.outcomeReason == outcomeReason &&
      other.temporaryCodePrefix == temporaryCodePrefix &&
      other.temporaryCodes == temporaryCodes &&
      other.timezone == timezone &&
      other.notes == notes;

    @override
    int get hashCode =>
        bornAt.hashCode +
        (enclosureId == null ? 0 : enclosureId.hashCode) +
        initialAliveCount.hashCode +
        initialOtherCount.hashCode +
        damCondition.hashCode +
        outcomeReason.hashCode +
        (temporaryCodePrefix == null ? 0 : temporaryCodePrefix.hashCode) +
        temporaryCodes.hashCode +
        timezone.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory ConfirmBirthRequest.fromJson(Map<String, dynamic> json) => _$ConfirmBirthRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmBirthRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

