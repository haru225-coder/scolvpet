import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'pedigree_models.dart';
import 'pedigree_repository.dart';

class PedigreeController extends ChangeNotifier {
  PedigreeController({required this.repository});

  final PedigreeRepository repository;

  I2AsyncState<PedigreeGraph> graphState = const I2AsyncState.idle();
  List<List<PedigreeTreeSlot>> generations = const [];
  int requestedGenerations = 3;
  String? hamsterId;

  Future<void> load(String id, {int generationsDepth = 3}) async {
    hamsterId = id;
    requestedGenerations = generationsDepth;
    graphState = const I2AsyncState.loading();
    generations = const [];
    notifyListeners();
    try {
      // Fetch one extra hop so depth-3 display has enough edges from API.
      final graph = await repository.getPedigree(
        id,
        generations: generationsDepth + 1,
      );
      graphState = I2AsyncState.data(graph);
      generations = buildAncestorGenerations(
        graph,
        generations: generationsDepth,
      );
    } catch (error) {
      graphState = I2AsyncState.error(pedigreeErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> retry() async {
    final id = hamsterId;
    if (id == null) return;
    await load(id, generationsDepth: requestedGenerations);
  }
}
