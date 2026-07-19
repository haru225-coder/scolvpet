import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'growth_models.dart';
import 'growth_repository.dart';

class GrowthController extends ChangeNotifier {
  GrowthController({required this.repository});

  final GrowthRepository repository;

  I2AsyncState<List<GrowthPublicHamster>> profilesState =
      const I2AsyncState.idle();
  I2AsyncState<List<GrowthCampaign>> campaignsState = const I2AsyncState.idle();
  I2AsyncState<List<GrowthLead>> leadsState = const I2AsyncState.idle();
  bool busy = false;
  String? lastMessage;

  List<GrowthOpportunity> get opportunities =>
      opportunitiesFromProfiles(profilesState.data ?? const []);

  int get readyFilmingCount => (profilesState.data ?? const [])
      .where((e) => e.filmingStatus == 'ready' && e.published)
      .length;

  int get draftCampaignCount => (campaignsState.data ?? const [])
      .where((e) => e.status == 'draft' || e.status == 'ready')
      .length;

  int get leadCount => leadsState.data?.length ?? 0;

  GrowthPublicHamster? profileById(String hamsterId) {
    for (final item in profilesState.data ?? const <GrowthPublicHamster>[]) {
      if (item.hamsterId == hamsterId) return item;
    }
    return null;
  }

  GrowthCampaign? campaignById(String campaignId) {
    for (final item in campaignsState.data ?? const <GrowthCampaign>[]) {
      if (item.id == campaignId) return item;
    }
    return null;
  }

  Future<void> refreshAll() async {
    await Future.wait([refreshProfiles(), refreshCampaigns(), refreshLeads()]);
  }

  Future<void> refreshProfiles() => _load(
    set: (s) => profilesState = s,
    fetch: repository.listPublicHamsters,
    empty: '还没有公开仓鼠资料',
  );

  Future<void> refreshCampaigns() => _load(
    set: (s) => campaignsState = s,
    fetch: repository.listCampaigns,
    empty: '还没有获客活动',
  );

  Future<void> refreshLeads() => _load(
    set: (s) => leadsState = s,
    fetch: repository.listLeads,
    empty: '还没有新线索',
  );

  Future<void> _load<T>({
    required void Function(I2AsyncState<List<T>>) set,
    required Future<List<T>> Function() fetch,
    required String empty,
  }) async {
    set(const I2AsyncState.loading());
    notifyListeners();
    try {
      final items = await fetch();
      set(
        items.isEmpty
            ? I2AsyncState.empty(message: empty)
            : I2AsyncState.data(items),
      );
    } catch (error) {
      set(I2AsyncState.error(growthErrorMessage(error)));
    }
    notifyListeners();
  }

  Future<bool> upsertProfile(
    String hamsterId,
    GrowthPublicHamsterDraft draft,
  ) => _run(() async {
    await repository.upsertPublicHamster(hamsterId, draft);
    lastMessage = '公开资料已保存';
    await refreshProfiles();
  });

  Future<GrowthCampaign?> generate(GrowthGenerateDraft draft) async {
    busy = true;
    lastMessage = null;
    notifyListeners();
    try {
      final campaign = await repository.generateCampaign(draft);
      lastMessage = '脚本已生成';
      await refreshCampaigns();
      return campaign;
    } catch (error) {
      lastMessage = growthErrorMessage(error);
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> publish(String campaignId) => _run(() async {
    await repository.publishCampaign(campaignId);
    lastMessage = '活动已发布';
    await refreshCampaigns();
  });

  Future<bool> archive(String campaignId) => _run(() async {
    await repository.archiveCampaign(campaignId);
    lastMessage = '活动已归档';
    await refreshCampaigns();
  });

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    lastMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (error) {
      lastMessage = growthErrorMessage(error);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
