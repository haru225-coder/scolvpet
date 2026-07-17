import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'genetic_models.dart';
import 'genetic_repository.dart';

class GeneticController extends ChangeNotifier {
  GeneticController({required this.repository});

  final GeneticRepository repository;

  I2AsyncState<List<GeneticLocus>> lociState = const I2AsyncState.idle();
  I2AsyncState<List<GeneticProfile>> profilesState = const I2AsyncState.idle();
  I2AsyncState<GeneticSimulationResult> simulateState =
      const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([refreshLoci(), refreshProfiles()]);
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
