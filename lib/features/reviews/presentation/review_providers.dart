import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/review_repository.dart';
import '../domain/review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(supabaseClientProvider));
});

final reviewForRequestProvider =
    FutureProvider.family<Review?, String>((ref, requestId) async {
  return ref.watch(reviewRepositoryProvider).getReviewForRequest(requestId);
});
