class Message {
  const Message({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      requestId: map['request_id'] as String,
      senderId: map['sender_id'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  final String id;
  final String requestId;
  final String senderId;
  final String body;
  final DateTime createdAt;
}
