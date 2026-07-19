//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_simulation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticSimulationRequest {
  /// Returns a new [GeneticSimulationRequest] instance.
  GeneticSimulationRequest({

     this.mode,

     this.series,

     this.sirePhenotype,

     this.damPhenotype,

     this.sireHamsterId,

     this.damHamsterId,

     this.targetPhenotype,

     this.sire,

     this.dam,
  });

      /// phenotype_table=核心表查表；mendel=简化孟德尔
  @JsonKey(

    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final GeneticSimulationRequestModeEnum? mode;



      /// 系列代码或中文名，如 poly / 波利系列 / chocolate / 巧克力色系
  @JsonKey(

    name: r'series',
    required: false,
    includeIfNull: false,
  )


  final String? series;



      /// 父本表型（phenotype_table 模式）
  @JsonKey(

    name: r'sire_phenotype',
    required: false,
    includeIfNull: false,
  )


  final String? sirePhenotype;



      /// 母本表型（phenotype_table 模式）
  @JsonKey(

    name: r'dam_phenotype',
    required: false,
    includeIfNull: false,
  )


  final String? damPhenotype;



      /// 可选父本档案 ID；父母双方都提供时启用具体亲本历史校准
  @JsonKey(

    name: r'sire_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? sireHamsterId;



      /// 可选母本档案 ID；父母双方都提供时启用具体亲本历史校准
  @JsonKey(

    name: r'dam_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? damHamsterId;



      /// 可选重点表型；客户端可据最终概率计算本窝至少出现一只的机会
  @JsonKey(

    name: r'target_phenotype',
    required: false,
    includeIfNull: false,
  )


  final String? targetPhenotype;



      /// 父本基因型位点映射（mendel 模式）
  @JsonKey(

    name: r'sire',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? sire;



      /// 母本基因型位点映射（mendel 模式）
  @JsonKey(

    name: r'dam',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? dam;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticSimulationRequest &&
      other.mode == mode &&
      other.series == series &&
      other.sirePhenotype == sirePhenotype &&
      other.damPhenotype == damPhenotype &&
      other.sireHamsterId == sireHamsterId &&
      other.damHamsterId == damHamsterId &&
      other.targetPhenotype == targetPhenotype &&
      other.sire == sire &&
      other.dam == dam;

    @override
    int get hashCode =>
        mode.hashCode +
        series.hashCode +
        sirePhenotype.hashCode +
        damPhenotype.hashCode +
        sireHamsterId.hashCode +
        damHamsterId.hashCode +
        targetPhenotype.hashCode +
        sire.hashCode +
        dam.hashCode;

  factory GeneticSimulationRequest.fromJson(Map<String, dynamic> json) => _$GeneticSimulationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticSimulationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// phenotype_table=核心表查表；mendel=简化孟德尔
enum GeneticSimulationRequestModeEnum {
    /// phenotype_table=核心表查表；mendel=简化孟德尔
@JsonValue(r'phenotype_table')
phenotypeTable(r'phenotype_table'),
    /// phenotype_table=核心表查表；mendel=简化孟德尔
@JsonValue(r'mendel')
mendel(r'mendel');

const GeneticSimulationRequestModeEnum(this.value);

final String value;

@override
String toString() => value;
}
