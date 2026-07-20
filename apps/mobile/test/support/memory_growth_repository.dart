// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/growth/growth_models.dart';
import 'package:scolvpet_mobile/features/growth/growth_repository.dart';

class MemoryGrowthRepository implements GrowthRepository {
  final Map<String, GrowthPublicHamster> _profiles = {
    'h-naicha': const GrowthPublicHamster(
      hamsterId: 'h-naicha',
      publicName: '奶茶',
      summary: '亲人、活动规律',
      traits: ['亲人', '活动规律'],
      sex: 'female',
      variety: '金丝熊',
      birthDate: '2026-04-18',
      filmingStatus: 'ready',
      published: true,
      consultable: true,
      ctaText: '进入主页咨询',
      media: [
        GrowthMedia(
          id: 'media-naicha',
          url: 'assets/brand/login_hero.png',
          kind: 'cover',
        ),
      ],
    ),
  };
  final List<GrowthCampaign> _campaigns = [];
  int _seq = 0;

  @override
  Future<List<GrowthPublicHamster>> listPublicHamsters() async =>
      _profiles.values.toList();

  @override
  Future<GrowthPublicHamster> upsertPublicHamster(
    String hamsterId,
    GrowthPublicHamsterDraft draft,
  ) async {
    if (draft.consultable && !draft.published) {
      throw const GrowthRepositoryException('接受咨询前必须先公开资料');
    }
    final prev = _profiles[hamsterId];
    final item = GrowthPublicHamster(
      hamsterId: hamsterId,
      publicName: draft.publicName.trim().isEmpty ? '公开仓鼠' : draft.publicName,
      summary: draft.summary,
      traits: draft.traits,
      sex: prev?.sex,
      variety: prev?.variety,
      birthDate: prev?.birthDate,
      filmingStatus: draft.filmingStatus,
      published: draft.published,
      consultable: draft.consultable,
      ctaText: draft.ctaText,
      priceLabel: draft.priceLabel,
      media: prev?.media ?? const [],
    );
    _profiles[hamsterId] = item;
    return item;
  }

  @override
  Future<List<GrowthCampaign>> listCampaigns() async =>
      List.unmodifiable(_campaigns.reversed);

  @override
  Future<GrowthCampaign> generateCampaign(GrowthGenerateDraft draft) async {
    final subject = _profiles[draft.hamsterId];
    if (subject == null || !subject.published) {
      throw const GrowthRepositoryException('请先发布这只仓鼠的公开资料');
    }
    // ponytail: fixed fixture; real template/LLM lives in Go growthcore.
    _seq += 1;
    final code = 'c_mem${_seq.toString().padLeft(4, '0')}';
    final cta = draft.cta?.trim().isNotEmpty == true
        ? draft.cta!.trim()
        : (subject.ctaText ?? '想了解这只仓鼠，可以进入主页咨询。');
    final script = GrowthScript(
      title: '${subject.publicName}｜${draft.goal}',
      hook: '你见过${subject.publicName}这样自然活动吗？',
      coverText: '认识${subject.publicName}',
      sections: [
        GrowthScriptSection(
          order: 1,
          durationSeconds: draft.durationSeconds ?? 35,
          shot: '仓鼠出镜',
          voiceover: '${subject.publicName}，${subject.traits.join('、')}。',
          overlay: subject.publicName,
        ),
      ],
      caption: '${subject.publicName}｜${draft.goal}。$cta',
      hashtags: const ['#仓鼠', '#金丝熊', '#熊舍日常'],
      cta: cta,
      facts: [
        GrowthPublicFact(
          key: 'public_name',
          value: subject.publicName,
          source: 'hamster_public_profile.public_name',
        ),
      ],
    );
    final campaign = GrowthCampaign(
      id: 'camp-$_seq',
      campaignCode: code,
      campaignType: draft.campaignType,
      platform: draft.platform,
      status: 'ready',
      subjectType: 'hamster',
      subjectId: draft.hamsterId,
      title: script.title,
      goal: draft.goal,
      durationSeconds: draft.durationSeconds ?? 35,
      tone: draft.tone,
      cta: script.cta,
      script: script,
      modelName: 'template-v1',
      promptVersion: 'growth-p0-v1',
      version: 1,
      publicUrlPath: '/p/snow-cattery?campaign=$code',
      createdAt: DateTime.now().toUtc(),
    );
    _campaigns.add(campaign);
    return campaign;
  }

  Future<GrowthCampaign> _setStatus(String campaignId, String status) async {
    final index = _campaigns.indexWhere((e) => e.id == campaignId);
    if (index < 0) throw const GrowthRepositoryException('活动不存在');
    final updated = _campaigns[index].withStatus(status);
    _campaigns[index] = updated;
    return updated;
  }

  @override
  Future<GrowthCampaign> publishCampaign(String campaignId) =>
      _setStatus(campaignId, 'published');

  @override
  Future<GrowthCampaign> archiveCampaign(String campaignId) =>
      _setStatus(campaignId, 'archived');

  @override
  Future<List<GrowthLead>> listLeads() async => [
    GrowthLead(
      id: 'lead-1',
      contactId: 'contact-1',
      name: '阿雪',
      wechat: 'snow123',
      campaignId: _campaigns.isEmpty ? null : _campaigns.last.id,
      campaignCode: _campaigns.isEmpty ? null : _campaigns.last.campaignCode,
      campaignTitle: _campaigns.isEmpty ? null : _campaigns.last.title,
      sourceChannel: 'public_page',
      landingPath: '/p/snow-cattery',
      interestHamsterId: 'h-naicha',
      interestHamsterName: '奶茶',
      intentSummary: '新手适合哪只',
      createdAt: DateTime.now().toUtc(),
    ),
  ];
}

