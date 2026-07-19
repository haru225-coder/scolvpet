//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/action_item_result.dart';
import 'package:scolvpet_api/src/model/litter_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wean_litter_response_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeanLitterResponseData {
  /// Returns a new [WeanLitterResponseData] instance.
  WeanLitterResponseData({

    required  this.litterId,

    required  this.litterState,

    required  this.weanedAt,

    required  this.processedCount,

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

    name: r'weaned_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime weanedAt;



          // minimum: 0
  @JsonKey(

    name: r'processed_count',
    required: true,
    includeIfNull: false,
  )


  final int processedCount;



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
    bool operator ==(Object other) => identical(this, other) || other is WeanLitterResponseData &&
      other.litterId == litterId &&
      other.litterState == litterState &&
      other.weanedAt == weanedAt &&
      other.processedCount == processedCount &&
      other.itemResults == itemResults &&
      other.createdTaskIds == createdTaskIds &&
      other.version == version;

    @override
    int get hashCode =>
        litterId.hashCode +
        litterState.hashCode +
        weanedAt.hashCode +
        processedCount.hashCode +
        itemResults.hashCode +
        createdTaskIds.hashCode +
        version.hashCode;

  factory WeanLitterResponseData.fromJson(Map<String, dynamic> json) => _$WeanLitterResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeanLitterResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
