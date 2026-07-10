import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../messages/presentation/chat_screen.dart';
import '../../requests/presentation/request_detail_screen.dart';
import '../domain/app_notification.dart';
import '../domain/notification_type.dart';
import 'notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, AppNotification notification) {
    ref.read(notificationRepositoryProvider).markRead(notification.id);
    final requestId = notification.requestId;
    if (requestId == null) return;
    final screen = switch (notification.type) {
      NotificationType.newOffer => RequestDetailScreen(requestId: requestId),
      NotificationType.offerAccepted ||
      NotificationType.newMessage ||
      NotificationType.requestCompleted =>
        ChatScreen(requestId: requestId),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü okundu işaretle',
            onPressed: () {
              final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
              ref.read(notificationRepositoryProvider).markAllRead(userId);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'Henüz bildirim yok.',
                style: TextStyle(color: GlassColors.textSecondary(brightness)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 18,
                onTap: () => _open(context, ref, notification),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: notification.isRead
                          ? GlassColors.neutral
                          : GlassColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.body,
                            style: TextStyle(
                              color: GlassColors.textPrimary(brightness),
                              fontWeight:
                                  notification.isRead ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: GlassColors.textSecondary(brightness),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _formatTimestamp(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${_twoDigits(local.day)}.${_twoDigits(local.month)}.${local.year} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}
