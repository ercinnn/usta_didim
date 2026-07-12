import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/service_request.dart';

class ServiceRequestRepository {
  const ServiceRequestRepository(this._client);

  final SupabaseClient _client;

  Future<void> createRequest({
    required String id,
    required String customerId,
    required String category,
    required String title,
    required String neighborhood,
    String? description,
    DateTime? preferredDate,
    List<String> photoUrls = const [],
  }) async {
    await _client.from('service_requests').insert({
      'id': id,
      'customer_id': customerId,
      'category': category,
      'title': title,
      'description': description,
      'neighborhood': neighborhood,
      'preferred_date': preferredDate?.toIso8601String(),
      'photo_urls': photoUrls,
    });
  }

  Future<List<ServiceRequest>> getMyRequests(String customerId) async {
    final rows = await _client
        .from('service_requests')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return rows.map(ServiceRequest.fromMap).toList();
  }

  Future<ServiceRequest?> getRequestById(String id) async {
    final row = await _client
        .from('service_requests')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return ServiceRequest.fromMap(row);
  }

  Future<void> markCompleted(String id) async {
    await _client
        .from('service_requests')
        .update({'status': 'completed'}).eq('id', id);
  }

  Future<List<ServiceRequest>> getOpenRequestsForCategory(String category) async {
    final rows = await _client
        .from('service_requests')
        .select()
        .eq('status', 'open')
        .eq('category', category)
        .order('created_at', ascending: false);
    return rows.map(ServiceRequest.fromMap).toList();
  }
}
