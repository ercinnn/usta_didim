import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/domain/app_role.dart';
import '../domain/profile.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<void> createProfile({
    required String id,
    required String fullName,
    required String phone,
    required AppRole role,
  }) async {
    await _client.from('profiles').insert({
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
    });
  }

  Future<Profile?> getProfile(String id) async {
    final row =
        await _client.from('profiles').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return Profile.fromMap(row);
  }
}
