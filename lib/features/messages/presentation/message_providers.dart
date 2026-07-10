import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/message_repository.dart';
import '../domain/message.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(ref.watch(supabaseClientProvider));
});

final messagesForRequestProvider =
    StreamProvider.family<List<Message>, String>((ref, requestId) {
  return ref.watch(messageRepositoryProvider).watchMessages(requestId);
});
