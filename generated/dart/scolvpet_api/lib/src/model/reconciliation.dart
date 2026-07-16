//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reconciliation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reconciliation {
  /// Returns a new [Reconciliation] instance.
  Reconciliation({

    required  this.initialAliveCount,

    required  this.discoveredCount,

    required  this.deceasedCount,

    required  this.transferredCount,

    required  this.expectedManagedCount,

    required  this.unindividualizedAliveCount,

    required  this.individualizedAliveCount,

    required  this.difference,

    required  this.closed,
  });

          // minimum: 0
  @JsonKey(
    
    name: r'initial_alive_count',
    required: true,
    includeIfNull: false,
  )


  final int initialAliveCount;



          // minimum: 0
  @JsonKey(
    
    name: r'discovered_count',
    required: true,
    includeIfNull: false,
  )


  final int discoveredCount;



          // minimum: 0
  @JsonKey(
    
    name: r'deceased_count',
    required: true,
    includeIfNull: false,
  )


  final int deceasedCount;



          // minimum: 0
  @JsonKey(
    
    name: r'transferred_count',
    required: true,
    includeIfNull: false,
  )


  final int transferredCount;



          // minimum: 0
  @JsonKey(
    
    name: r'expected_managed_count',
    required: true,
    includeIfNull: false,
  )


  final int expectedManagedCount;



          // minimum: 0
  @JsonKey(
    
    name: r'unindividualized_alive_count',
    required: true,
    includeIfNull: false,
  )


  final int unindividualizedAliveCount;



          // minimum: 0
  @JsonKey(
    
    name: r'individualized_alive_count',
    required: true,
    includeIfNull: false,
  )


  final int individualizedAliveCount;



  @JsonKey(
    
    name: r'difference',
    required: true,
    includeIfNull: false,
  )


  final int difference;



  @JsonKey(
    
    name: r'closed',
    required: true,
    includeIfNull: false,
  )


  final bool closed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Reconciliation &&
      other.initialAliveCount == initialAliveCount &&
      other.discoveredCount == discoveredCount &&
      other.deceasedCount == deceasedCount &&
      other.transferredCount == transferredCount &&
      other.expectedManagedCount == expectedManagedCount &&
      other.unindividualizedAliveCount == unindividualizedAliveCount &&
      other.individualizedAliveCount == individualizedAliveCount &&
      other.difference == difference &&
      other.closed == closed;

    @override
    int get hashCode =>
        initialAliveCount.hashCode +
        discoveredCount.hashCode +
        deceasedCount.hashCode +
        transferredCount.hashCode +
        expectedManagedCount.hashCode +
        unindividualizedAliveCount.hashCode +
        individualizedAliveCount.hashCode +
        difference.hashCode +
        closed.hashCode;

  factory Reconciliation.fromJson(Map<String, dynamic> json) => _$ReconciliationFromJson(json);

  Map<String, dynamic> toJson() => _$ReconciliationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

