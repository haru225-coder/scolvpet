import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'crm_models.dart';

abstract interface class CrmRepository {
  Future<List<CrmContact>> listContacts();
  Future<CrmContact> createContact(CrmContactDraft draft);

  Future<List<CrmReservation>> listReservations();
  Future<CrmReservation> createReservation(CrmReservationDraft draft);
  Future<CrmReservation> confirmReservation(String id, int version);
  Future<CrmReservation> cancelReservation(String id, int version);

  Future<List<CrmHandover>> listHandovers();
  Future<CrmHandover> createHandover(CrmHandoverDraft draft);
  Future<CrmHandover> completeHandover(String id, int version);
}

class CrmRepositoryException implements Exception {
  const CrmRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String crmErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '客户/交付请求失败',
  nonDioFallback: '客户记录暂时未完成，请稍后重试',
  mapLocal: (e) => e is CrmRepositoryException ? e.message : null,
);

class DefaultApiCrmRepository implements CrmRepository {
  DefaultApiCrmRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'crm-${_uuid.v4()}';

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

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) throw const CrmRepositoryException('响应为空');
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<CrmContact>> listContacts() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/crm/contacts',
    );
    return _listData(response).map(CrmContact.fromJson).toList();
  }

  @override
  Future<CrmContact> createContact(CrmContactDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/crm/contacts',
      data: {
        'name': draft.name,
        if (draft.phone != null) 'phone': draft.phone,
        if (draft.wechat != null) 'wechat': draft.wechat,
        if (draft.notes != null) 'notes': draft.notes,
        'status': draft.status,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return CrmContact.fromJson(_data(response));
  }

  @override
  Future<List<CrmReservation>> listReservations() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/crm/reservations',
    );
    return _listData(response).map(CrmReservation.fromJson).toList();
  }

  @override
  Future<CrmReservation> createReservation(CrmReservationDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/crm/reservations',
      data: {
        'contact_id': draft.contactId,
        'title': draft.title,
        if (draft.hamsterId != null) 'hamster_id': draft.hamsterId,
        if (draft.notes != null) 'notes': draft.notes,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return CrmReservation.fromJson(_data(response));
  }

  @override
  Future<CrmReservation> confirmReservation(String id, int version) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/crm/reservations/$id/confirm',
      options: Options(
        headers: {'Idempotency-Key': _key(), 'If-Match': '"$version"'},
      ),
    );
    return CrmReservation.fromJson(_data(response));
  }

  @override
  Future<CrmReservation> cancelReservation(String id, int version) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/crm/reservations/$id/cancel',
      options: Options(
        headers: {'Idempotency-Key': _key(), 'If-Match': '"$version"'},
      ),
    );
    return CrmReservation.fromJson(_data(response));
  }

  @override
  Future<List<CrmHandover>> listHandovers() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/crm/handovers',
    );
    return _listData(response).map(CrmHandover.fromJson).toList();
  }

  @override
  Future<CrmHandover> createHandover(CrmHandoverDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/crm/handovers',
      data: {
        'contact_id': draft.contactId,
        if (draft.reservationId != null) 'reservation_id': draft.reservationId,
        if (draft.hamsterId != null) 'hamster_id': draft.hamsterId,
        if (draft.notes != null) 'notes': draft.notes,
        if (draft.scheduledAt != null)
          'scheduled_at': draft.scheduledAt!.toUtc().toIso8601String(),
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return CrmHandover.fromJson(_data(response));
  }

  @override
  Future<CrmHandover> completeHandover(String id, int version) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/crm/handovers/$id/complete',
      options: Options(
        headers: {'Idempotency-Key': _key(), 'If-Match': '"$version"'},
      ),
    );
    return CrmHandover.fromJson(_data(response));
  }
}
