//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/action_item_result.dart';
import 'package:scolvpet_api/src/model/litter_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sex_and_separate_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SexAndSeparateResponseData {
  /// Returns a new [SexAndSeparateResponseData] instance.
  SexAndSeparateResponseData({

    required  this.litterId,

    required  this.litterState,

    required  this.separatedAt,

    required  this.processedCount,

    required  this.uncertainCount,

    required  this.itemResults,

    required  this.createdTaskIds,

    required  this.version,
  });

  @JsonKey(
    
    name: r'litter_id',
    required: true,
    includeIfNull: false,
  )


  final String litterId;



  @JsonKey(
    
    name: r'litter_state',
    required: true,
    includeIfNull: false,
  )


  final LitterState litterState;



  @JsonKey(
    
    name: r'separated_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime separatedAt;



          // minimum: 0
  @JsonKey(
    
    name: r'processed_count',
    required: true,
    includeIfNull: false,
  )


  final int processedCount;



          // minimum: 0
  @JsonKey(
    
    name: r'uncertain_count',
    required: true,
    includeIfNull: false,
  )


  final int uncertainCount;



  @JsonKey(
    
    name: r'item_results',
    required: true,
    includeIfNull: false,
  )


  final List<ActionItemResult> itemResults;



  @JsonKey(
    
    name: r'created_task_ids',
    required: true,
    includeIfNull: false,
  )


  final List<String> createdTaskIds;



          // minimum: 1
  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final int version;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SexAndSeparateResponseData &&
      other.litterId == litterId &&
      other.litterState == litterState &&
      other.separatedAt == separatedAt &&
      other.processedCount == processedCount &&
      other.uncertainCount == uncertainCount &&
      other.itemResults == itemResults &&
      other.createdTaskIds == createdTaskIds &&
      other.version == version;

    @override
    int get hashCode =>
        litterId.hashCode +
        litterState.hashCode +
        separatedAt.hashCode +
        processedCount.hashCode +
        uncertainCount.hashCode +
        itemResults.hashCode +
        createdTaskIds.hashCode +
        version.hashCode;

  factory SexAndSeparateResponseData.fromJson(Map<String, dynamic> json) => _$SexAndSeparateResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SexAndSeparateResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

