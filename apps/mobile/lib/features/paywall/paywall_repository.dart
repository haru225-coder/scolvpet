import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'paywall_models.dart';

abstract interface class PaywallRepository {
  Future<List<PlanCatalogEntry>> listCatalog();
  Future<EntitlementSnapshot> current();
  Future<EntitlementCheckResult> check({String? feature, String? metric});
  Future<EntitlementSnapshot> sandboxActivate(String planCode);
}

class PaywallRepositoryException implements Exception {
  const PaywallRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String paywallErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '权益请求失败',
  mapLocal: (e) => e is PaywallRepositoryException ? e.message : null,
);

class DefaultApiPaywallRepository implements PaywallRepository {
  DefaultApiPaywallRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'ent-${_uuid.v4()}';

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const PaywallRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> _listData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<List<PlanCatalogEntry>> listCatalog() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/entitlements/catalog',
    );
    final items = _listData(response).map(PlanCatalogEntry.fromJson).toList();
    return items.isEmpty ? defaultPlanCatalog() : items;
  }

  @override
  Future<EntitlementSnapshot> current() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/entitlements/current',
    );
    return EntitlementSnapshot.fromJson(_data(response));
  }

  @override
  Future<EntitlementCheckResult> check({
    String? feature,
    String? metric,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/entitlements/check',
      data: {
        if (feature != null) 'feature': feature,
        if (metric != null) 'metric': metric,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return EntitlementCheckResult.fromJson(_data(response));
  }

  @override
  Future<EntitlementSnapshot> sandboxActivate(String planCode) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/entitlements/sandbox/activate',
      data: {'plan_code': planCode},
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return EntitlementSnapshot.fromJson(_data(response));
  }
}
