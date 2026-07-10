import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/notification_repository.dart';
import '../data/push_token_repository.dart';
import '../domain/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(supabaseClientProvider));
});

final pushTokenRepositoryProvider = Provider<PushTokenRepository>((ref) {
  return PushTokenRepository(ref.watch(supabaseClientProvider));
});

final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser!.id;
  return ref.watch(notificationRepositoryProvider).watchNotifications(userId);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(myNotificationsProvider).value;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});
