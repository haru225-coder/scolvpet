import '../../core/app_config.dart';

class GrowthMedia {
  const GrowthMedia({
    this.id,
    required this.url,
    this.kind = 'preview',
    this.status = 'ready',
  });

  final String? id;
  final String url;
  final String kind;
  final String status;

  bool get isReady => status == 'ready' && url.trim().isNotEmpty;

  factory GrowthMedia.fromJson(Map<String, dynamic> json) => GrowthMedia(
    id: json['id']?.toString(),
    url: json['url'] as String? ?? '',
    kind: json['kind'] as String? ?? 'preview',
    status: json['status'] as String? ?? 'ready',
  );
}

class GrowthPublicHamster {
  const GrowthPublicHamster({
    required this.hamsterId,
    required this.publicName,
    this.summary,
    this.traits = const [],
    this.sex,
    this.variety,
    this.birthDate,
    required this.filmingStatus,
    required this.published,
    required this.consultable,
    this.ctaText,
    this.priceLabel,
    this.media = const [],
  });

  final String hamsterId;
  final String publicName;
  final String? summary;
  final List<String> traits;
  final String? sex;
  final String? variety;
  final String? birthDate;
  final String filmingStatus;
  final bool published;
  final bool consultable;
  final String? ctaText;
  final String? priceLabel;
  final List<GrowthMedia> media;

  GrowthMedia? get coverMedia {
    for (final kind in const ['cover', 'thumbnail', 'preview']) {
      for (final item in media) {
        if (item.isReady && item.kind == kind) return item;
      }
    }
    for (final item in media) {
      if (item.isReady) return item;
    }
    return null;
  }

  String get filmingLabel => switch (filmingStatus) {
    'ready' => '可拍摄',
    'rest' => '休息中',
    'restricted' => '不宜出镜',
    _ => filmingStatus,
  };

  factory GrowthPublicHamster.fromJson(Map<String, dynamic> json) {
    final traits = json['traits'];
    final media = json['media'];
    return GrowthPublicHamster(
      hamsterId: json['hamster_id'] as String? ?? '',
      publicName: json['public_name'] as String? ?? '',
      summary: json['summary'] as String?,
      traits: traits is List
          ? traits.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      sex: json['sex'] as String?,
      variety: json['variety'] as String?,
      birthDate: json['birth_date'] as String?,
      filmingStatus: json['filming_status'] as String? ?? 'rest',
      published: json['published'] as bool? ?? false,
      consultable: json['consultable'] as bool? ?? false,
      ctaText: json['cta_text'] as String?,
      priceLabel: json['price_label'] as String?,
      media: media is List
          ? media
                .whereType<Map>()
                .map(
                  (item) =>
                      GrowthMedia.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }
}

class GrowthPublicHamsterDraft {
  const GrowthPublicHamsterDraft({
    required this.publicName,
    this.summary,
    this.traits = const [],
    this.filmingStatus = 'rest',
    this.published = false,
    this.consultable = false,
    this.ctaText,
    this.priceLabel,
  });

  final String publicName;
  final String? summary;
  final List<String> traits;
  final String filmingStatus;
  final bool published;
  final bool consultable;
  final String? ctaText;
  final String? priceLabel;

  Map<String, dynamic> toJson() => {
    'public_name': publicName,
    'summary': summary,
    'traits': traits,
    'filming_status': filmingStatus,
    'published': published,
    'consultable': consultable,
    'cta_text': ctaText,
    'price_label': priceLabel,
  };
}

class GrowthOpportunity {
  const GrowthOpportunity({
    required this.kind,
    required this.hamsterId,
    required this.title,
    required this.reason,
    required this.priority,
    required this.suggestion,
    this.publicName,
  });

  final String kind;
  final String hamsterId;
  final String title;
  final String reason;
  final int priority;
  final String suggestion;
  final String? publicName;

  factory GrowthOpportunity.fromJson(Map<String, dynamic> json) =>
      GrowthOpportunity(
        kind: json['kind'] as String? ?? 'hamster_profile',
        hamsterId: json['hamster_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        priority: (json['priority'] as num?)?.toInt() ?? 0,
        suggestion: json['suggestion'] as String? ?? '生成短视频脚本',
        publicName: json['public_name'] as String?,
      );
}

/// Client-side opportunity list from profiles (avoids a second fetch).
List<GrowthOpportunity> opportunitiesFromProfiles(
  List<GrowthPublicHamster> profiles,
) {
  final items =
      profiles
          .where((e) => e.published)
          .map(
            (e) => GrowthOpportunity(
              kind: 'hamster_profile',
              hamsterId: e.hamsterId,
              title: '为${e.publicName}拍一条内容',
              reason: e.filmingStatus == 'ready'
                  ? '当前适合拍摄，可以生成一条真实成长内容。'
                  : '公开资料已经准备好，可以开始持续曝光。',
              priority: e.filmingStatus == 'ready' && e.consultable ? 100 : 50,
              suggestion: '生成短视频脚本',
              publicName: e.publicName,
            ),
          )
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
  return items;
}

class GrowthScriptSection {
  const GrowthScriptSection({
    required this.order,
    required this.durationSeconds,
    required this.shot,
    required this.voiceover,
    required this.overlay,
  });

  final int order;
  final int durationSeconds;
  final String shot;
  final String voiceover;
  final String overlay;

  factory GrowthScriptSection.fromJson(Map<String, dynamic> json) =>
      GrowthScriptSection(
        order: (json['order'] as num?)?.toInt() ?? 0,
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
        shot: json['shot'] as String? ?? '',
        voiceover: json['voiceover'] as String? ?? '',
        overlay: json['overlay'] as String? ?? '',
      );

  String get plainText =>
      '[$order · ${durationSeconds}s] $shot\n口播：$voiceover\n字幕：$overlay';
}

class GrowthPublicFact {
  const GrowthPublicFact({
    required this.key,
    required this.value,
    required this.source,
  });

  final String key;
  final String value;
  final String source;

  String get label => switch (key) {
    'public_name' => '公开名称',
    'variety' => '品种',
    'sex' => '性别',
    'birth_date' => '生日',
    'summary' => '公开简介',
    'traits' => '公开特点',
    _ => '公开资料',
  };

  factory GrowthPublicFact.fromJson(Map<String, dynamic> json) =>
      GrowthPublicFact(
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
        source: json['source'] as String? ?? '',
      );
}

class GrowthScript {
  const GrowthScript({
    required this.title,
    required this.hook,
    required this.coverText,
    required this.sections,
    required this.caption,
    required this.hashtags,
    required this.cta,
    required this.facts,
  });

  final String title;
  final String hook;
  final String coverText;
  final List<GrowthScriptSection> sections;
  final String caption;
  final List<String> hashtags;
  final String cta;
  final List<GrowthPublicFact> facts;

  factory GrowthScript.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'];
    final hashtags = json['hashtags'];
    final facts = json['facts'];
    return GrowthScript(
      title: json['title'] as String? ?? '',
      hook: json['hook'] as String? ?? '',
      coverText: json['cover_text'] as String? ?? '',
      sections: sections is List
          ? sections
                .whereType<Map>()
                .map(
                  (e) => GrowthScriptSection.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      caption: json['caption'] as String? ?? '',
      hashtags: hashtags is List
          ? hashtags.map((e) => e.toString()).toList()
          : const [],
      cta: json['cta'] as String? ?? '',
      facts: facts is List
          ? facts
                .whereType<Map>()
                .map(
                  (e) =>
                      GrowthPublicFact.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  String get fullCopyText {
    final buffer = StringBuffer()
      ..writeln(title)
      ..writeln(hook)
      ..writeln(coverText)
      ..writeln();
    for (final section in sections) {
      buffer
        ..writeln(section.plainText)
        ..writeln();
    }
    buffer
      ..writeln(caption)
      ..writeln(hashtags.join(' '))
      ..writeln(cta);
    return buffer.toString().trim();
  }
}

class GrowthCampaign {
  const GrowthCampaign({
    required this.id,
    required this.campaignCode,
    required this.campaignType,
    required this.platform,
    required this.status,
    required this.subjectType,
    required this.subjectId,
    required this.title,
    required this.goal,
    this.durationSeconds,
    required this.tone,
    required this.cta,
    required this.script,
    required this.modelName,
    required this.promptVersion,
    required this.version,
    this.publicUrlPath,
    this.createdAt,
    this.publishedAt,
  });

  final String id;
  final String campaignCode;
  final String campaignType;
  final String platform;
  final String status;
  final String subjectType;
  final String subjectId;
  final String title;
  final String goal;
  final int? durationSeconds;
  final String tone;
  final String cta;
  final GrowthScript script;
  final String modelName;
  final String promptVersion;
  final int version;
  final String? publicUrlPath;
  final DateTime? createdAt;
  final DateTime? publishedAt;

  String get typeLabel => campaignType == 'live' ? '直播' : '短视频';

  String get platformLabel => switch (platform) {
    'douyin' => '抖音',
    'xiaohongshu' => '小红书',
    'wechat_channels' => '视频号',
    'other' => '其他',
    _ => platform,
  };

  String get statusLabel => switch (status) {
    'draft' => '草稿',
    'ready' => '已生成',
    'published' => '已发布',
    'archived' => '已归档',
    _ => status,
  };

  String publicUrl({String host = publicSiteHost}) {
    final path = publicUrlPath;
    if (path == null || path.isEmpty) return '$host/p/?campaign=$campaignCode';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$host${path.startsWith('/') ? path : '/$path'}';
  }

  bool get hasPublicUrl =>
      publicUrlPath != null && publicUrlPath!.trim().isNotEmpty;

  GrowthCampaign withStatus(String next) => GrowthCampaign(
    id: id,
    campaignCode: campaignCode,
    campaignType: campaignType,
    platform: platform,
    status: next,
    subjectType: subjectType,
    subjectId: subjectId,
    title: title,
    goal: goal,
    durationSeconds: durationSeconds,
    tone: tone,
    cta: cta,
    script: script,
    modelName: modelName,
    promptVersion: promptVersion,
    version: version + 1,
    publicUrlPath: publicUrlPath,
    createdAt: createdAt,
    publishedAt: next == 'published' ? DateTime.now().toUtc() : null,
  );

  factory GrowthCampaign.fromJson(Map<String, dynamic> json) {
    final scriptRaw = json['script'];
    return GrowthCampaign(
      id: json['id'] as String? ?? '',
      campaignCode: json['campaign_code'] as String? ?? '',
      campaignType: json['campaign_type'] as String? ?? 'video',
      platform: json['platform'] as String? ?? 'other',
      status: json['status'] as String? ?? 'draft',
      subjectType: json['subject_type'] as String? ?? 'hamster',
      subjectId: json['subject_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      tone: json['tone'] as String? ?? '',
      cta: json['cta'] as String? ?? '',
      script: scriptRaw is Map
          ? GrowthScript.fromJson(Map<String, dynamic>.from(scriptRaw))
          : const GrowthScript(
              title: '',
              hook: '',
              coverText: '',
              sections: [],
              caption: '',
              hashtags: [],
              cta: '',
              facts: [],
            ),
      modelName: json['model_name'] as String? ?? 'template-v1',
      promptVersion: json['prompt_version'] as String? ?? 'growth-p0-v1',
      version: (json['version'] as num?)?.toInt() ?? 1,
      publicUrlPath: json['public_url_path'] as String?,
      createdAt: DateTime.tryParse(
        json['created_at'] as String? ?? '',
      )?.toUtc(),
      publishedAt: DateTime.tryParse(
        json['published_at'] as String? ?? '',
      )?.toUtc(),
    );
  }
}

class GrowthGenerateDraft {
  const GrowthGenerateDraft({
    required this.campaignType,
    required this.platform,
    required this.goal,
    this.durationSeconds,
    required this.tone,
    this.cta,
    required this.hamsterId,
  });

  final String campaignType;
  final String platform;
  final String goal;
  final int? durationSeconds;
  final String tone;
  final String? cta;
  final String hamsterId;

  Map<String, dynamic> toJson() => {
    'campaign_type': campaignType,
    'platform': platform,
    'goal': goal,
    if (durationSeconds != null) 'duration_seconds': durationSeconds,
    'tone': tone,
    if (cta != null && cta!.trim().isNotEmpty) 'cta': cta,
    'hamster_id': hamsterId,
  };
}

class GrowthLead {
  const GrowthLead({
    required this.id,
    required this.contactId,
    required this.name,
    this.phone,
    this.wechat,
    this.campaignId,
    this.campaignCode,
    this.campaignTitle,
    this.consultationId,
    required this.sourceChannel,
    this.landingPath,
    this.interestHamsterId,
    this.interestHamsterName,
    this.intentSummary,
    required this.createdAt,
  });

  final String id;
  final String contactId;
  final String name;
  final String? phone;
  final String? wechat;
  final String? campaignId;
  final String? campaignCode;
  final String? campaignTitle;
  final String? consultationId;
  final String sourceChannel;
  final String? landingPath;
  final String? interestHamsterId;
  final String? interestHamsterName;
  final String? intentSummary;
  final DateTime createdAt;

  String get contactLabel {
    final parts = <String>[
      if (phone != null && phone!.isNotEmpty) phone!,
      if (wechat != null && wechat!.isNotEmpty) '微信 $wechat',
    ];
    return parts.isEmpty ? '未留联系方式' : parts.join(' · ');
  }

  factory GrowthLead.fromJson(Map<String, dynamic> json) => GrowthLead(
    id: json['id'] as String? ?? '',
    contactId: json['contact_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String?,
    wechat: json['wechat'] as String?,
    campaignId: json['campaign_id'] as String?,
    campaignCode: json['campaign_code'] as String?,
    campaignTitle: json['campaign_title'] as String?,
    consultationId: json['consultation_id'] as String?,
    sourceChannel: json['source_channel'] as String? ?? 'public_page',
    landingPath: json['landing_path'] as String?,
    interestHamsterId: json['interest_hamster_id'] as String?,
    interestHamsterName: json['interest_hamster_name'] as String?,
    intentSummary: json['intent_summary'] as String?,
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}
