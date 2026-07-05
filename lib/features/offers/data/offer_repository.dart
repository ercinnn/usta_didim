import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/offer.dart';

class OfferRepository {
  const OfferRepository(this._client);

  final SupabaseClient _client;

  Future<List<Offer>> getOffersForRequest(String requestId) async {
    final rows = await _client
        .from('offers')
        .select('*, providers(business_name, rating)')
        .eq('request_id', requestId)
        .order('created_at', ascending: true);
    return rows.map(Offer.fromMap).toList();
  }

  Future<void> acceptOffer({
    required String offerId,
    required String requestId,
  }) async {
    await _client.from('offers').update({'status': 'accepted'}).eq('id', offerId);
    await _client
        .from('service_requests')
        .update({'status': 'pending'}).eq('id', requestId);
  }

  Future<void> createOffer({
    required String requestId,
    required String providerId,
    required num price,
    String? note,
  }) async {
    await _client.from('offers').insert({
      'request_id': requestId,
      'provider_id': providerId,
      'price': price,
      'note': note,
    });
  }

  Future<List<Offer>> getMyOffers(String providerId) async {
    final rows = await _client
        .from('offers')
        .select('*, service_requests(title, category, neighborhood)')
        .eq('provider_id', providerId)
        .order('created_at', ascending: false);
    return rows.map(Offer.fromMap).toList();
  }
}
