import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/review.dart';

class ReviewRepository {
  const ReviewRepository(this._client);

  final SupabaseClient _client;

  Future<Review?> getReviewForRequest(String requestId) async {
    final row = await _client
        .from('reviews')
        .select()
        .eq('request_id', requestId)
        .maybeSingle();
    if (row == null) return null;
    return Review.fromMap(row);
  }

  Future<void> submitReview({
    required String requestId,
    required String providerId,
    required String customerId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'request_id': requestId,
      'provider_id': providerId,
      'customer_id': customerId,
      'rating': rating,
      'comment': comment,
    });
  }
}
