import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/app_role.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/profile_repository.dart';
import '../data/provider_repository.dart';
import '../domain/profile.dart';
import '../domain/provider_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository(ref.watch(supabaseClientProvider));
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final authState = ref.watch(authStateChangesProvider).value;
  final userId = authState?.session?.user.id ??
      ref.read(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

final currentProviderProfileProvider = FutureProvider<ProviderProfile?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null || profile.role != AppRole.provider) return null;
  return ref.watch(providerRepositoryProvider).getProviderProfile(profile.id);
});
