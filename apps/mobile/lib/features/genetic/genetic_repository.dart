import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'genetic_models.dart';

abstract interface class GeneticRepository {
  Future<List<GeneticLocus>> listLoci();
  Future<PhenotypeCatalog> listPhenotypeCatalog();
  Future<List<GeneticProfile>> listProfiles();
  Future<GeneticProfile> createProfile(GeneticProfileDraft draft);
  Future<GeneticSimulationResult> simulate({
    required Map<String, String> sire,
    required Map<String, String> dam,
  });
  Future<GeneticSimulationResult> simulatePhenotype({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    String? sireHamsterId,
    String? damHamsterId,
  });
  Future<List<TargetCrossRecommendation>> findTargetCrosses({
    required String series,
    required String targetPhenotype,
  });
  Future<PhenotypeCompareResult> compareActual({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    required Map<String, int> actualCounts,
    bool save = false,
    String? breedingPlanId,
    String? litterId,
  });
  Future<List<PhenotypeFeedbackPairSummary>> listFeedbackSummary();
}

class GeneticRepositoryException implements Exception {
  const GeneticRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String geneticErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '遗传请求失败',
  nonDioFallback: '暂时无法完成遗传操作，请稍后重试',
  mapLocal: (e) {
    if (e is GeneticRepositoryException) return e.message;
    if (e is FormatException) return '表型数据格式不正确，请稍后重试';
    return null;
  },
);

/// Loads authority phenotype table from Flutter assets (same JSON as API).
Future<PhenotypeTableIndex> loadBundledPhenotypeTable() async {
  final raw = await rootBundle.loadString(
    'assets/genetic/syrian_phenotype_table_v1.json',
  );
  final json = jsonDecode(raw);
  if (json is! Map) {
    throw const GeneticRepositoryException('表型选项暂时不可用，请稍后重试');
  }
  return PhenotypeTableIndex.fromJson(Map<String, dynamic>.from(json));
}
class DefaultApiGeneticRepository implements GeneticRepository {
  DefaultApiGeneticRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'genetic-${_uuid.v4()}';

  List<Map<String, dynamic>> _listData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const GeneticRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<GeneticLocus>> listLoci() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/genetic/loci',
    );
    final items = _listData(response).map(GeneticLocus.fromJson).toList();
    return items.isEmpty ? defaultGeneticLoci : items;
  }

  @override
  Future<PhenotypeCatalog> listPhenotypeCatalog() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/genetic/phenotype-catalog',
    );
    return PhenotypeCatalog.fromJson(_data(response));
  }

  @override
  Future<List<GeneticProfile>> listProfiles() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/genetic/profiles',
    );
    return _listData(response).map(GeneticProfile.fromJson).toList();
  }

  @override
  Future<GeneticProfile> createProfile(GeneticProfileDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/genetic/profiles',
      data: {
        'name': draft.name,
        'genotype': draft.genotype,
        'confidence': draft.confidence,
        if (draft.notes != null) 'notes': draft.notes,
        if (draft.hamsterId != null) 'hamster_id': draft.hamsterId,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return GeneticProfile.fromJson(_data(response));
  }

  @override
  Future<GeneticSimulationResult> simulate({
    required Map<String, String> sire,
    required Map<String, String> dam,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/genetic/simulate',
      data: {'mode': 'mendel', 'sire': sire, 'dam': dam},
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return GeneticSimulationResult.fromJson(_data(response));
  }

  @override
  Future<GeneticSimulationResult> simulatePhenotype({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    String? sireHamsterId,
    String? damHamsterId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/genetic/simulate',
      data: {
        'mode': 'phenotype_table',
        'series': series,
        'sire_phenotype': sirePhenotype,
        'dam_phenotype': damPhenotype,
        if (sireHamsterId != null && sireHamsterId.isNotEmpty)
          'sire_hamster_id': sireHamsterId,
        if (damHamsterId != null && damHamsterId.isNotEmpty)
          'dam_hamster_id': damHamsterId,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return GeneticSimulationResult.fromJson(_data(response));
  }

  @override
  Future<List<TargetCrossRecommendation>> findTargetCrosses({
    required String series,
    required String targetPhenotype,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/genetic/target-crosses',
      queryParameters: {'series': series, 'phenotype': targetPhenotype},
    );
    final data = _data(response);
    final crosses = data['crosses'];
    if (crosses is! List) return const [];
    return crosses
        .whereType<Map>()
        .map(
          (e) =>
              TargetCrossRecommendation.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  @override
  Future<PhenotypeCompareResult> compareActual({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    required Map<String, int> actualCounts,
    bool save = false,
    String? breedingPlanId,
    String? litterId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/genetic/compare-actual',
      data: {
        'series': series,
        'sire_phenotype': sirePhenotype,
        'dam_phenotype': damPhenotype,
        'actual_counts': actualCounts,
        'save': save,
        if (breedingPlanId != null) 'breeding_plan_id': breedingPlanId,
        if (litterId != null) 'litter_id': litterId,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return PhenotypeCompareResult.fromJson(_data(response));
  }

  @override
  Future<List<PhenotypeFeedbackPairSummary>> listFeedbackSummary() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/genetic/feedback-summary',
    );
    final data = _data(response);
    final pairs = data['pairs'];
    if (pairs is! List) return const [];
    return pairs
        .whereType<Map>()
        .map(
          (e) => PhenotypeFeedbackPairSummary.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }
}
