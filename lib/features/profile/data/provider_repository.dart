import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/provider_profile.dart';

class ProviderRepository {
  const ProviderRepository(this._client);

  final SupabaseClient _client;

  Future<void> createProviderProfile({
    required String id,
    required String businessName,
    required String category,
    required String neighborhood,
    String? description,
  }) async {
    await _client.from('providers').insert({
      'id': id,
      'business_name': businessName,
      'category': category,
      'neighborhood': neighborhood,
      'description': description,
    });
  }

  Future<void> updateProviderProfile({
    required String id,
    required String businessName,
    required String category,
    required String neighborhood,
    String? description,
  }) async {
    await _client.from('providers').update({
      'business_name': businessName,
      'category': category,
      'neighborhood': neighborhood,
      'description': description,
    }).eq('id', id);
  }

  Future<ProviderProfile?> getProviderProfile(String id) async {
    final row =
        await _client.from('providers').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return ProviderProfile.fromMap(row);
  }
}
