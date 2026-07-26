//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_public_site_simulate_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PostPublicSiteSimulateRequest {
  /// Returns a new [PostPublicSiteSimulateRequest] instance.
  PostPublicSiteSimulateRequest({

     this.sireHamsterId,

     this.damHamsterId,

     this.series,

     this.sirePhenotype,

     this.damPhenotype,
  });

  @JsonKey(

    name: r'sire_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? sireHamsterId;



  @JsonKey(

    name: r'dam_hamster_id',
    required: false,
    includeIfNull: false,
  )


  final String? damHamsterId;



  @JsonKey(

    name: r'series',
    required: false,
    includeIfNull: false,
  )


  final String? series;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is PostPublicSiteSimulateRequest &&
      other.sireHamsterId == sireHamsterId &&
      other.damHamsterId == damHamsterId &&
      other.series == series &&
      other.sirePhenotype == sirePhenotype &&
      other.damPhenotype == damPhenotype;

    @override
    int get hashCode =>
        sireHamsterId.hashCode +
        damHamsterId.hashCode +
        series.hashCode +
        sirePhenotype.hashCode +
        damPhenotype.hashCode;

  factory PostPublicSiteSimulateRequest.fromJson(Map<String, dynamic> json) => _$PostPublicSiteSimulateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostPublicSiteSimulateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}
