import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'stud_models.dart';

abstract interface class StudRepository {
  Future<List<StudListing>> listListings({bool mineOnly = false});
  Future<StudListing> createListing(StudListingDraft draft);
  Future<StudListing> unpublishListing(String id);

  Future<List<StudDeal>> listDeals();
  Future<StudDeal> createDeal(StudDealDraft draft);
  Future<StudDeal> confirm(String id);
  Future<StudDeal> start(String id);
  Future<StudDeal> complete(String id);
  Future<StudDeal> cancel(String id);
}

class StudRepositoryException implements Exception {
  const StudRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String studErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '借配请求失败',
  mapLocal: (e) => e is StudRepositoryException ? e.message : null,
);
class DefaultApiStudRepository implements StudRepository {
  DefaultApiStudRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'stud-${_uuid.v4()}';

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
    if (data is! Map) throw const StudRepositoryException('响应为空');
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<StudListing>> listListings({bool mineOnly = false}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/stud/listings',
      queryParameters: {if (mineOnly) 'mine': '1'},
    );
    return _listData(response).map(StudListing.fromJson).toList();
  }

  @override
  Future<StudListing> createListing(StudListingDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/stud/listings',
      data: {
        'sire_label': draft.sireLabel,
        'title': draft.title,
        'fee_cents': draft.feeCents,
        'currency': draft.currency,
        if (draft.notes != null) 'notes': draft.notes,
        'published': draft.published,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return StudListing.fromJson(_data(response));
  }

  @override
  Future<StudListing> unpublishListing(String id) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/stud/listings/$id/unpublish',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return StudListing.fromJson(_data(response));
  }

  @override
  Future<List<StudDeal>> listDeals() async {
    final response = await client.dio.get<Map<String, dynamic>>('/stud/deals');
    return _listData(response).map(StudDeal.fromJson).toList();
  }

  @override
  Future<StudDeal> createDeal(StudDealDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/stud/deals',
      data: {
        if (draft.listingId != null) 'listing_id': draft.listingId,
        'side': draft.side,
        'partner_cattery_name': draft.partnerCatteryName,
        if (draft.myHamsterLabel != null) 'my_hamster_label': draft.myHamsterLabel,
        if (draft.partnerContact != null) 'partner_contact': draft.partnerContact,
        if (draft.partnerAnimalLabel != null)
          'partner_animal_label': draft.partnerAnimalLabel,
        'fee_cents': draft.feeCents,
        'currency': draft.currency,
        if (draft.notes != null) 'notes': draft.notes,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return StudDeal.fromJson(_data(response));
  }

  Future<StudDeal> _action(String id, String action) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/stud/deals/$id/$action',
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return StudDeal.fromJson(_data(response));
  }

  @override
  Future<StudDeal> confirm(String id) => _action(id, 'confirm');
  @override
  Future<StudDeal> start(String id) => _action(id, 'start');
  @override
  Future<StudDeal> complete(String id) => _action(id, 'complete');
  @override
  Future<StudDeal> cancel(String id) => _action(id, 'cancel');
}
