import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'litter_board_models.dart';
import 'litter_board_repository.dart';

class LitterBoardController extends ChangeNotifier {
  LitterBoardController({required this.repository});

  final LitterBoardRepository repository;

  I2AsyncState<List<LitterBoard>> listState = const I2AsyncState.idle();
  I2AsyncState<LitterBoard> detailState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshList() async {
    listState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final litters = await repository.listLitters();
      listState = litters.isEmpty
          ? const I2AsyncState.empty(message: '暂无窝次记录')
          : I2AsyncState.data(litters);
    } catch (error) {
      listState = I2AsyncState.error(litterBoardErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> openLitter(String litterId) async {
    detailState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final board = await repository.getLitter(litterId);
      detailState = I2AsyncState.data(board);
    } catch (error) {
      detailState = I2AsyncState.error(litterBoardErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> runNextAction({
    required String maleEnclosureId,
    required String femaleEnclosureId,
  }) async {
    final board = detailState.data;
    if (board == null) {
      lastMessage = '请先打开窝次';
      notifyListeners();
      return false;
    }
    final action = nextLitterAction(board.state);
    if (action == null) {
      lastMessage = '当前状态无需继续';
      notifyListeners();
      return false;
    }

    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final LitterBoard next;
      switch (action) {
        case LitterBoardAction.wean:
          next = await repository.wean(
            litterId: board.id,
            version: board.version,
          );
          lastMessage = '断奶完成';
        case LitterBoardAction.sexAndSeparate:
          next = await repository.sexAndSeparate(
            litterId: board.id,
            version: board.version,
            maleEnclosureId: maleEnclosureId,
            femaleEnclosureId: femaleEnclosureId,
          );
          lastMessage = '分性分笼完成';
        case LitterBoardAction.individualize:
          next = await repository.individualize(
            litterId: board.id,
            version: board.version,
          );
          lastMessage = '个体化建档完成';
      }
      detailState = I2AsyncState.data(next);
      actionState = const I2AsyncState.data(null);
      await refreshList();
      notifyListeners();
      return true;
    } catch (error) {
      final message = litterBoardErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
