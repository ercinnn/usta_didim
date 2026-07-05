import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/service_request_repository.dart';
import '../domain/service_request.dart';

final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((ref) {
  return ServiceRequestRepository(ref.watch(supabaseClientProvider));
});

final myRequestsProvider = FutureProvider<List<ServiceRequest>>((ref) async {
  final customerId = ref.watch(supabaseClientProvider).auth.currentUser!.id;
  return ref.watch(serviceRequestRepositoryProvider).getMyRequests(customerId);
});

final requestByIdProvider =
    FutureProvider.family<ServiceRequest?, String>((ref, requestId) async {
  return ref.watch(serviceRequestRepositoryProvider).getRequestById(requestId);
});

final jobPoolProvider = FutureProvider<List<ServiceRequest>>((ref) async {
  final providerProfile = await ref.watch(currentProviderProfileProvider.future);
  if (providerProfile == null) return [];
  return ref
      .watch(serviceRequestRepositoryProvider)
      .getOpenRequestsForCategory(providerProfile.category);
});
