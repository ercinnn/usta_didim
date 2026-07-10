import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
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
            return const Center(child: Text('Henüz bildirim yok.'));
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                onTap: () => _open(context, ref, notification),
                leading: Icon(
                  Icons.circle,
                  size: 10,
                  color: notification.isRead
                      ? AppColors.ink.withValues(alpha: 0.2)
                      : AppColors.terracotta,
                ),
                title: Text(notification.body),
                subtitle: Text(_formatTimestamp(notification.createdAt)),
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
