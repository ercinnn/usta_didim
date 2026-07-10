import 'notification_type.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.requestId,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: NotificationType.fromDb(map['type'] as String),
      requestId: map['request_id'] as String?,
      body: map['body'] as String,
      isRead: map['is_read'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final NotificationType type;
  final String? requestId;
  final String body;
  final bool isRead;
  final DateTime createdAt;
}
