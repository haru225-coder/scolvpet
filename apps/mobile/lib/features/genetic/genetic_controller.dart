import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'genetic_models.dart';
import 'genetic_repository.dart';

class GeneticController extends ChangeNotifier {
  GeneticController({required this.repository});

  final GeneticRepository repository;

  I2AsyncState<List<GeneticLocus>> lociState = const I2AsyncState.idle();
  I2AsyncState<PhenotypeCatalog> catalogState = const I2AsyncState.idle();
  I2AsyncState<List<GeneticProfile>> profilesState = const I2AsyncState.idle();
  I2AsyncState<GeneticSimulationResult> simulateState =
      const I2AsyncState.idle();
  I2AsyncState<List<TargetCrossRecommendation>> targetState =
      const I2AsyncState.idle();
  I2AsyncState<PhenotypeCompareResult> compareState = const I2AsyncState.idle();
  I2AsyncState<List<PhenotypeFeedbackPairSummary>> summaryState =
      const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([
      refreshLoci(),
      refreshCatalog(),
      refreshProfiles(),
      refreshFeedbackSummary(),
    ]);
  }

  Future<void> refreshLoci() async {
    lociState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listLoci();
      lociState = I2AsyncState.data(items);
    } catch (error) {
      lociState = I2AsyncState.error(geneticErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshCatalog() async {
    catalogState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final catalog = await repository.listPhenotypeCatalog();
      catalogState = I2AsyncState.data(catalog);
    } catch (error) {
      catalogState = I2AsyncState.error(geneticErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshProfiles() async {
    profilesState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listProfiles();
      profilesState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无遗传档案')
          : I2AsyncState.data(items);
    } catch (error) {
      profilesState = I2AsyncState.error(geneticErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> createProfile(GeneticProfileDraft draft) => _run(() async {
    await repository.createProfile(draft);
    lastMessage = '遗传档案已创建';
    await refreshProfiles();
  });

  Future<bool> simulate({
    required Map<String, String> sire,
    required Map<String, String> dam,
  }) async {
    simulateState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final result = await repository.simulate(sire: sire, dam: dam);
      simulateState = I2AsyncState.data(result);
      lastMessage = '模拟完成 · ${result.outcomes.length} 种组合';
      notifyListeners();
      return true;
    } catch (error) {
      final message = geneticErrorMessage(error);
      simulateState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> simulatePhenotype({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    String? sireHamsterId,
    String? damHamsterId,
  }) async {
    simulateState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final result = await repository.simulatePhenotype(
        series: series,
        sirePhenotype: sirePhenotype,
        damPhenotype: damPhenotype,
        sireHamsterId: sireHamsterId,
        damHamsterId: damHamsterId,
      );
      simulateState = I2AsyncState.data(result);
      lastMessage = '预测完成 · ${result.outcomes.length} 种后代表型';
      notifyListeners();
      return true;
    } catch (error) {
      final message = geneticErrorMessage(error);
      simulateState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> findTargetCrosses({
    required String series,
    required String targetPhenotype,
  }) async {
    targetState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final items = await repository.findTargetCrosses(
        series: series,
        targetPhenotype: targetPhenotype,
      );
      if (items.isEmpty) {
        targetState = const I2AsyncState.empty(message: '核心表中无产出该表型的配对');
        lastMessage = '暂时没有找到合适的组合';
      } else {
        targetState = I2AsyncState.data(items);
        lastMessage = '找到 ${items.length} 组可产出「$targetPhenotype」的配对';
      }
      notifyListeners();
      return items.isNotEmpty;
    } catch (error) {
      final message = geneticErrorMessage(error);
      targetState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> compareActual({
    required String series,
    required String sirePhenotype,
    required String damPhenotype,
    required Map<String, int> actualCounts,
    bool save = true,
    String? breedingPlanId,
    String? litterId,
  }) async {
    compareState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final result = await repository.compareActual(
        series: series,
        sirePhenotype: sirePhenotype,
        damPhenotype: damPhenotype,
        actualCounts: actualCounts,
        save: save,
        breedingPlanId: breedingPlanId,
        litterId: litterId,
      );
      compareState = I2AsyncState.data(result);
      lastMessage = save ? '本窝记录已保存' : '本窝结果已完成比较';
      if (save) {
        await refreshFeedbackSummary();
      } else {
        notifyListeners();
      }
      return true;
    } catch (error) {
      final message = geneticErrorMessage(error);
      compareState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshFeedbackSummary() async {
    summaryState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listFeedbackSummary();
      summaryState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无历史回填，完成产仔对比后会出现')
          : I2AsyncState.data(items);
    } catch (error) {
      summaryState = I2AsyncState.error(geneticErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() body) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await body();
      actionState = const I2AsyncState.data(null);
      notifyListeners();
      return true;
    } catch (error) {
      final message = geneticErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
