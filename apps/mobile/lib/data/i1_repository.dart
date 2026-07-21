import 'package:flutter/foundation.dart';
import 'package:scolvpet_api/scolvpet_api.dart';
import 'package:uuid/uuid.dart';

import '../core/api_client.dart';
import '../core/session_store.dart';

abstract interface class I1Repository {
  Future<String> requestCode(String phone);

  Future<SessionResponseData> login({
    required String phone,
    required String verificationId,
    required String code,
  });

  Future<CurrentAccountResponseData> getCurrentAccount();

  Future<SessionResponseData> refresh(String refreshToken);

  Future<Organization> updateOrganization({
    required String name,
    required int version,
  });

  Future<List<SpeciesRuleVersion>> listSystemRules();

  Future<List<SpeciesRuleVersion>> listOwnerRules();

  Future<SpeciesRuleVersion> copyRule(SpeciesRuleVersion template);

  Future<void> logout();
}

class ApiI1Repository implements I1Repository {
  ApiI1Repository({
    required ApiClient client,
    required SessionStorePort sessionStore,
  }) : _client = client,
       _sessionStore = sessionStore;

  final ApiClient _client;
  final SessionStorePort _sessionStore;
  final Uuid _uuid = const Uuid();

  @override
  Future<String> requestCode(String phone) async {
    final response = await _client.api.sendVerificationCode(
      idempotencyKey: _uuid.v4(),
      sendVerificationCodeRequest: SendVerificationCodeRequest(
        phone: phone,
        purpose: SendVerificationCodeRequestPurposeEnum.login,
      ),
    );
    return response.data!.data.verificationId;
  }

  @override
  Future<SessionResponseData> login({
    required String phone,
    required String verificationId,
    required String code,
  }) async {
    final response = await _client.api.createSession(
      idempotencyKey: _uuid.v4(),
      phoneCodeLoginRequest: PhoneCodeLoginRequest(
        phone: phone,
        verificationId: verificationId,
        code: code,
        device: DeviceInfo(platform: _devicePlatform, appVersion: '0.0.3'),
      ),
    );
    final session = response.data!.data;
    await _sessionStore.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }

  @override
  Future<CurrentAccountResponseData> getCurrentAccount() async {
    final response = await _client.api.getCurrentAccount();
    return response.data!.data;
  }

  @override
  Future<SessionResponseData> refresh(String refreshToken) async {
    final response = await _client.api.refreshSession(
      idempotencyKey: _uuid.v4(),
      refreshSessionRequest: RefreshSessionRequest(refreshToken: refreshToken),
    );
    final session = response.data!.data;
    await _sessionStore.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }

  DeviceInfoPlatformEnum get _devicePlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DeviceInfoPlatformEnum.android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return DeviceInfoPlatformEnum.ios;
    }
  }

  @override
  Future<Organization> updateOrganization({
    required String name,
    required int version,
  }) async {
    final response = await _client.api.updateCurrentOrganization(
      idempotencyKey: _uuid.v4(),
      ifMatch: '"$version"',
      organizationUpdateRequest: OrganizationUpdateRequest(
        name: name,
        mode: OrganizationUpdateRequestModeEnum.personal,
        timezone: 'Asia/Shanghai',
      ),
    );
    return response.data!.data;
  }

  @override
  Future<List<SpeciesRuleVersion>> listSystemRules() async {
    final response = await _client.api.listSpeciesRuleTemplates();
    return response.data!.data;
  }

  @override
  Future<List<SpeciesRuleVersion>> listOwnerRules() async {
    final response = await _client.api.listSpeciesRuleVersions();
    return response.data!.data;
  }

  @override
  Future<SpeciesRuleVersion> copyRule(SpeciesRuleVersion template) async {
    final response = await _client.api.createSpeciesRuleVersion(
      idempotencyKey: _uuid.v4(),
      speciesRuleVersionCreateRequest: SpeciesRuleVersionCreateRequest(
        sourceTemplateId: template.id,
        speciesCode: template.speciesCode,
        varietyScope: template.varietyScope,
        gestationMinDays: template.gestationMinDays,
        gestationMaxDays: template.gestationMaxDays,
        pairingMaxMinutes: template.pairingMaxMinutes,
        weaningTargetDays: template.weaningTargetDays,
        sexingTargetDays: template.sexingTargetDays,
        separationTargetDays: template.separationTargetDays,
        postBreedingRestDays: template.postBreedingRestDays,
        profileCreationDeadlineDays: template.profileCreationDeadlineDays,
        weightReference: template.weightReference,
        sourceNote: '复制自系统模板：${template.sourceNote}',
        effectiveAt: DateTime.now().toUtc(),
      ),
    );
    return response.data!.data;
  }

  @override
  Future<void> logout() async {
    try {
      await _client.api.deleteCurrentSession(idempotencyKey: _uuid.v4());
    } finally {
      await _sessionStore.clear();
    }
  }
}
