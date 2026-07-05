import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/offer_repository.dart';
import '../domain/offer.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepository(ref.watch(supabaseClientProvider));
});

final offersForRequestProvider =
    FutureProvider.family<List<Offer>, String>((ref, requestId) async {
  return ref.watch(offerRepositoryProvider).getOffersForRequest(requestId);
});

final myOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final providerId = ref.watch(supabaseClientProvider).auth.currentUser!.id;
  return ref.watch(offerRepositoryProvider).getMyOffers(providerId);
});
