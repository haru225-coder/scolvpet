import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'miniprogram_models.dart';
import 'miniprogram_repository.dart';

class MiniprogramController extends ChangeNotifier {
  MiniprogramController({required this.repository});

  final MiniprogramRepository repository;

  I2AsyncState<MiniprogramConfig> configState = const I2AsyncState.idle();
  I2AsyncState<List<MiniprogramRelease>> releasesState =
      const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refreshAll() async {
    await Future.wait([refreshConfig(), refreshReleases()]);
  }

  Future<void> refreshConfig() async {
    configState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final cfg = await repository.getConfig();
      configState = I2AsyncState.data(cfg);
    } catch (error) {
      configState = I2AsyncState.error(miniprogramErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshReleases() async {
    releasesState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listReleases();
      releasesState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无发布版本')
          : I2AsyncState.data(items);
    } catch (error) {
      releasesState = I2AsyncState.error(miniprogramErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> saveConfig(MiniprogramConfigDraft draft) => _run(() async {
    final cfg = await repository.saveConfig(draft);
    configState = I2AsyncState.data(cfg);
    lastMessage = '配置已保存';
  });

  Future<bool> createRelease(MiniprogramReleaseDraft draft) => _run(() async {
    await repository.createRelease(draft);
    lastMessage = '版本草稿已创建';
    await refreshReleases();
  });

  Future<bool> submit(MiniprogramRelease item) => _run(() async {
    await repository.submit(item.id);
    lastMessage = '已提交审核';
    await refreshReleases();
  });

  Future<bool> approve(MiniprogramRelease item) => _run(() async {
    await repository.audit(item.id, approve: true);
    lastMessage = '沙箱审核通过';
    await refreshReleases();
  });

  Future<bool> reject(MiniprogramRelease item) => _run(() async {
    await repository.audit(item.id, approve: false);
    lastMessage = '沙箱已驳回';
    await refreshReleases();
  });

  Future<bool> publish(MiniprogramRelease item) => _run(() async {
    await repository.publish(item.id);
    lastMessage = '已发布上线';
    await refreshReleases();
  });

  Future<bool> rollback(MiniprogramRelease item) => _run(() async {
    await repository.rollback(item.id);
    lastMessage = '已回滚下线';
    await refreshReleases();
  });

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
      final message = miniprogramErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
