//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/phenotype_table_outcome.dart';
import 'package:scolvpet_api/src/model/genetic_outcome.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genetic_simulation_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneticSimulationResult {
  /// Returns a new [GeneticSimulationResult] instance.
  GeneticSimulationResult({

     this.mode,

     this.tableId,

     this.tableVersion,

     this.series,

     this.seriesName,

     this.sirePhenotype,

     this.damPhenotype,

    required  this.sire,

    required  this.dam,

    required  this.outcomes,

     this.tableOutcomes,

     this.predictionBasis,

     this.historyLitterCount,

     this.historyPupCount,

    required  this.notes,
  });

  @JsonKey(

    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final GeneticSimulationResultModeEnum? mode;



  @JsonKey(

    name: r'table_id',
    required: false,
    includeIfNull: false,
  )


  final String? tableId;



  @JsonKey(

    name: r'table_version',
    required: false,
    includeIfNull: false,
  )


  final String? tableVersion;



  @JsonKey(

    name: r'series',
    required: false,
    includeIfNull: false,
  )


  final String? series;



  @JsonKey(

    name: r'series_name',
    required: false,
    includeIfNull: false,
  )


  final String? seriesName;



  @JsonKey(

    name: r'sire_phenotype',
    required: false,
    includeIfNull: false,
  )


  final String? sirePhenotype;



  @JsonKey(

    name: r'dam_phenotype',
    required: false,
    includeIfNull: false,
  )


  final String? damPhenotype;



  @JsonKey(

    name: r'sire',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> sire;



  @JsonKey(

    name: r'dam',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> dam;



  @JsonKey(

    name: r'outcomes',
    required: true,
    includeIfNull: false,
  )


  final List<GeneticOutcome> outcomes;



  @JsonKey(

    name: r'table_outcomes',
    required: false,
    includeIfNull: false,
  )


  final List<PhenotypeTableOutcome>? tableOutcomes;



      /// 前端仅需映射为“基于权威表”或“已结合历史繁殖记录”
  @JsonKey(

    name: r'prediction_basis',
    required: false,
    includeIfNull: false,
  )


  final GeneticSimulationResultPredictionBasisEnum? predictionBasis;



          // minimum: 0
  @JsonKey(

    name: r'history_litter_count',
    required: false,
    includeIfNull: false,
  )


  final int? historyLitterCount;



          // minimum: 0
  @JsonKey(

    name: r'history_pup_count',
    required: false,
    includeIfNull: false,
  )


  final int? historyPupCount;



  @JsonKey(

    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final String notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GeneticSimulationResult &&
      other.mode == mode &&
      other.tableId == tableId &&
      other.tableVersion == tableVersion &&
      other.series == series &&
      other.seriesName == seriesName &&
      other.sirePhenotype == sirePhenotype &&
      other.damPhenotype == damPhenotype &&
      other.sire == sire &&
      other.dam == dam &&
      other.outcomes == outcomes &&
      other.tableOutcomes == tableOutcomes &&
      other.predictionBasis == predictionBasis &&
      other.historyLitterCount == historyLitterCount &&
      other.historyPupCount == historyPupCount &&
      other.notes == notes;

    @override
    int get hashCode =>
        mode.hashCode +
        tableId.hashCode +
        tableVersion.hashCode +
        series.hashCode +
        seriesName.hashCode +
        sirePhenotype.hashCode +
        damPhenotype.hashCode +
        sire.hashCode +
        dam.hashCode +
        outcomes.hashCode +
        tableOutcomes.hashCode +
        predictionBasis.hashCode +
        historyLitterCount.hashCode +
        historyPupCount.hashCode +
        notes.hashCode;

  factory GeneticSimulationResult.fromJson(Map<String, dynamic> json) => _$GeneticSimulationResultFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticSimulationResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GeneticSimulationResultModeEnum {
@JsonValue(r'phenotype_table')
phenotypeTable(r'phenotype_table'),
@JsonValue(r'mendel')
mendel(r'mendel');

const GeneticSimulationResultModeEnum(this.value);

final String value;

@override
String toString() => value;
}


/// 前端仅需映射为“基于权威表”或“已结合历史繁殖记录”
enum GeneticSimulationResultPredictionBasisEnum {
    /// 前端仅需映射为“基于权威表”或“已结合历史繁殖记录”
@JsonValue(r'authority_table')
authorityTable(r'authority_table'),
    /// 前端仅需映射为“基于权威表”或“已结合历史繁殖记录”
@JsonValue(r'authority_table_plus_history')
authorityTablePlusHistory(r'authority_table_plus_history');

const GeneticSimulationResultPredictionBasisEnum(this.value);

final String value;

@override
String toString() => value;
}
