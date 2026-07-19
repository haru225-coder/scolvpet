//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/hamster_source_type.dart';
import 'package:scolvpet_api/src/model/sex.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hamster_create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HamsterCreateRequest {
  /// Returns a new [HamsterCreateRequest] instance.
  HamsterCreateRequest({

    required  this.internalCode,

     this.name,

    required  this.speciesRuleVersionId,

     this.varietyCode,

    required  this.sex,

     this.sexConfidence,

     this.birthDate,

    required  this.sourceType,

     this.coverMediaId,

     this.notes,

     this.sireId,

     this.damId,

     this.litterId,
  });

  @JsonKey(

    name: r'internal_code',
    required: true,
    includeIfNull: false,
  )


  final String internalCode;



  @JsonKey(

    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(

    name: r'species_rule_version_id',
    required: true,
    includeIfNull: false,
  )


  final String speciesRuleVersionId;



  @JsonKey(

    name: r'variety_code',
    required: false,
    includeIfNull: false,
  )


  final String? varietyCode;



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

    name: r'birth_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? birthDate;



  @JsonKey(

    name: r'source_type',
    required: true,
    includeIfNull: false,
  )


  final HamsterSourceType sourceType;



  @JsonKey(

    name: r'cover_media_id',
    required: false,
    includeIfNull: false,
  )


  final String? coverMediaId;



  @JsonKey(

    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



      /// 创建时可附带父本断言，服务端写入 pedigree_parentage
  @JsonKey(

    name: r'sire_id',
    required: false,
    includeIfNull: false,
  )


  final String? sireId;



      /// 创建时可附带母本断言，服务端写入 pedigree_parentage
  @JsonKey(

    name: r'dam_id',
    required: false,
    includeIfNull: false,
  )


  final String? damId;



      /// 外部或历史导入时关联窝次
  @JsonKey(

    name: r'litter_id',
    required: false,
    includeIfNull: false,
  )


  final String? litterId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HamsterCreateRequest &&
      other.internalCode == internalCode &&
      other.name == name &&
      other.speciesRuleVersionId == speciesRuleVersionId &&
      other.varietyCode == varietyCode &&
      other.sex == sex &&
      other.sexConfidence == sexConfidence &&
      other.birthDate == birthDate &&
      other.sourceType == sourceType &&
      other.coverMediaId == coverMediaId &&
      other.notes == notes &&
      other.sireId == sireId &&
      other.damId == damId &&
      other.litterId == litterId;

    @override
    int get hashCode =>
        internalCode.hashCode +
        (name == null ? 0 : name.hashCode) +
        speciesRuleVersionId.hashCode +
        (varietyCode == null ? 0 : varietyCode.hashCode) +
        sex.hashCode +
        (sexConfidence == null ? 0 : sexConfidence.hashCode) +
        (birthDate == null ? 0 : birthDate.hashCode) +
        sourceType.hashCode +
        (coverMediaId == null ? 0 : coverMediaId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (sireId == null ? 0 : sireId.hashCode) +
        (damId == null ? 0 : damId.hashCode) +
        (litterId == null ? 0 : litterId.hashCode);

  factory HamsterCreateRequest.fromJson(Map<String, dynamic> json) => _$HamsterCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HamsterCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
