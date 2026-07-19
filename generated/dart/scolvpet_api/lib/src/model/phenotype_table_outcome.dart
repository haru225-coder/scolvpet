//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phenotype_table_outcome.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PhenotypeTableOutcome {
  /// Returns a new [PhenotypeTableOutcome] instance.
  PhenotypeTableOutcome({

    required  this.phenotype,

    required  this.probability,

     this.fraction,

     this.note,
  });

  @JsonKey(

    name: r'phenotype',
    required: true,
    includeIfNull: false,
  )


  final String phenotype;



      /// 最终模拟概率；有历史数据时为权威表强先验校准后的概率
          // minimum: 0
          // maximum: 1
  @JsonKey(

    name: r'probability',
    required: true,
    includeIfNull: false,
  )


  final double probability;



      /// 仅静态权威表概率存在精确分数时返回
  @JsonKey(

    name: r'fraction',
    required: false,
    includeIfNull: false,
  )


  final String? fraction;



  @JsonKey(

    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PhenotypeTableOutcome &&
      other.phenotype == phenotype &&
      other.probability == probability &&
      other.fraction == fraction &&
      other.note == note;

    @override
    int get hashCode =>
        phenotype.hashCode +
        probability.hashCode +
        fraction.hashCode +
        note.hashCode;

  factory PhenotypeTableOutcome.fromJson(Map<String, dynamic> json) => _$PhenotypeTableOutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$PhenotypeTableOutcomeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
