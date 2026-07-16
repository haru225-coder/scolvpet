//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';


enum BreedingPlanState {
      @JsonValue(r'draft')
      draft(r'draft'),
      @JsonValue(r'pair_ready')
      pairReady(r'pair_ready'),
      @JsonValue(r'pairing')
      pairing(r'pairing'),
      @JsonValue(r'post_pair')
      postPair(r'post_pair'),
      @JsonValue(r'gestation')
      gestation(r'gestation'),
      @JsonValue(r'litter_nursing')
      litterNursing(r'litter_nursing'),
      @JsonValue(r'weaning_due')
      weaningDue(r'weaning_due'),
      @JsonValue(r'sex_separation_due')
      sexSeparationDue(r'sex_separation_due'),
      @JsonValue(r'individualizing')
      individualizing(r'individualizing'),
      @JsonValue(r'completed')
      completed(r'completed'),
      @JsonValue(r'no_litter_outcome')
      noLitterOutcome(r'no_litter_outcome'),
      @JsonValue(r'hold')
      hold(r'hold'),
      @JsonValue(r'unsuccessful')
      unsuccessful(r'unsuccessful'),
      @JsonValue(r'cancelled')
      cancelled(r'cancelled');

  const BreedingPlanState(this.value);

  final String value;

  @override
  String toString() => value;
}
