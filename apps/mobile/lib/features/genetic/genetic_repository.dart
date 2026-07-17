import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import 'genetic_models.dart';

abstract interface class GeneticRepository {
  Future<List<GeneticLocus>> listLoci();
  Future<List<GeneticProfile>> listProfiles();
  Future<GeneticProfile> createProfile(GeneticProfileDraft draft);
  Future<GeneticSimulationResult> simulate({
    required Map<String, String> sire,
    required Map<String, String> dam,
  });
}

class GeneticRepositoryException implements Exception {
  const GeneticRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String geneticErrorMessage(Object error) {
  if (error is GeneticRepositoryException) return error.message;
  if (error is FormatException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return '遗传请求失败';
  }
  return error.toString();
}

class MemoryGeneticRepository implements GeneticRepository {
  final List<GeneticProfile> _profiles = [];
  int _seq = 0;

  @override
  Future<List<GeneticLocus>> listLoci() async => defaultGeneticLoci;

  @override
  Future<List<GeneticProfile>> listProfiles() async =>
      List<GeneticProfile>.from(_profiles);

  @override
  Future<GeneticProfile> createProfile(GeneticProfileDraft draft) async {
    final name = draft.name.trim();
    if (name.isEmpty) {
      throw const GeneticRepositoryException('档案名称必填');
    }
    final genotype = <String, String>{};
    for (final entry in draft.genotype.entries) {
      final locus = defaultGeneticLoci.cast<GeneticLocus?>().firstWhere(
        (l) => l?.code == entry.key,
        orElse: () => null,
      );
      if (locus == null) continue;
      final norm = normalizeAllelePair(locus, entry.value);
      if (norm == null) {
        throw GeneticRepositoryException('位点 ${entry.key} 基因型无效');
      }
      genotype[entry.key] = norm;
    }
    final pheno = phenotypeMapFor(genotype);
    final item = GeneticProfile(
      id: 'gprof-${_seq++}',
      hamsterId: draft.hamsterId,
      name: name,
      phenotype: {
        ...pheno,
        'summary': phenotypeLabelFor(genotype),
      },
      genotype: genotype,
      confidence: draft.confidence,
      notes: draft.notes,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
    );
    _profiles.insert(0, item);
    return item;
  }

  @override
  Future<GeneticSimulationResult> simulate({
    required Map<String, String> sire,
    required Map<String, String> dam,
  }) async {
    try {
      return simulateBreeding(sire, dam);
    } on FormatException catch (error) {
      throw GeneticRepositoryException(error.message);
    }
  }
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
      data: {'sire': sire, 'dam': dam},
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return GeneticSimulationResult.fromJson(_data(response));
  }
}
