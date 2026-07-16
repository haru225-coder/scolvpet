//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:scolvpet_api/src/model/enclosure_dimensions.dart';
import 'package:scolvpet_api/src/model/cleanliness_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enclosure_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnclosureUpdateRequest {
  /// Returns a new [EnclosureUpdateRequest] instance.
  EnclosureUpdateRequest({

     this.code,

     this.rackCode,

     this.levelCode,

     this.dimensions,

     this.cleanlinessState,

     this.capacity,

     this.equipment,

     this.lastCleanedAt,
  });

  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(
    
    name: r'rack_code',
    required: false,
    includeIfNull: false,
  )


  final String? rackCode;



  @JsonKey(
    
    name: r'level_code',
    required: false,
    includeIfNull: false,
  )


  final String? levelCode;



  @JsonKey(
    
    name: r'dimensions',
    required: false,
    includeIfNull: false,
  )


  final EnclosureDimensions? dimensions;



  @JsonKey(
    
    name: r'cleanliness_state',
    required: false,
    includeIfNull: false,
  )


  final CleanlinessState? cleanlinessState;



          // minimum: 1
  @JsonKey(
    
    name: r'capacity',
    required: false,
    includeIfNull: false,
  )


  final int? capacity;



  @JsonKey(
    
    name: r'equipment',
    required: false,
    includeIfNull: false,
  )


  final List<String>? equipment;



  @JsonKey(
    
    name: r'last_cleaned_at',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastCleanedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EnclosureUpdateRequest &&
      other.code == code &&
      other.rackCode == rackCode &&
      other.levelCode == levelCode &&
      other.dimensions == dimensions &&
      other.cleanlinessState == cleanlinessState &&
      other.capacity == capacity &&
      other.equipment == equipment &&
      other.lastCleanedAt == lastCleanedAt;

    @override
    int get hashCode =>
        code.hashCode +
        (rackCode == null ? 0 : rackCode.hashCode) +
        (levelCode == null ? 0 : levelCode.hashCode) +
        (dimensions == null ? 0 : dimensions.hashCode) +
        cleanlinessState.hashCode +
        capacity.hashCode +
        equipment.hashCode +
        (lastCleanedAt == null ? 0 : lastCleanedAt.hashCode);

  factory EnclosureUpdateRequest.fromJson(Map<String, dynamic> json) => _$EnclosureUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosureUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

