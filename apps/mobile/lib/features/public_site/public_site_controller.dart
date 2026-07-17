import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'public_site_models.dart';
import 'public_site_repository.dart';

class PublicSiteController extends ChangeNotifier {
  PublicSiteController({required this.repository});

  final PublicSiteRepository repository;

  I2AsyncState<PublicSite> siteState = const I2AsyncState.idle();
  I2AsyncState<PublicSiteView> previewState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  Future<void> refresh() async {
    siteState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final site = await repository.getMine();
      siteState = I2AsyncState.data(site);
    } catch (error) {
      siteState = I2AsyncState.error(publicSiteErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> save(PublicSiteDraft draft) => _run(() async {
    final site = await repository.save(draft);
    siteState = I2AsyncState.data(site);
    lastMessage = '已保存';
  });

  Future<bool> publish() => _run(() async {
    final site = await repository.publish();
    siteState = I2AsyncState.data(site);
    lastMessage = '已发布公开主页';
  });

  Future<bool> unpublish() => _run(() async {
    final site = await repository.unpublish();
    siteState = I2AsyncState.data(site);
    lastMessage = '已取消发布';
  });

  Future<void> loadPublicPreview(String slug) async {
    previewState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final view = await repository.getPublicBySlug(slug);
      previewState = I2AsyncState.data(view);
    } catch (error) {
      previewState = I2AsyncState.error(publicSiteErrorMessage(error));
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
      final message = publicSiteErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
