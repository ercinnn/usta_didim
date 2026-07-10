import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/message.dart';

class MessageRepository {
  const MessageRepository(this._client);

  final SupabaseClient _client;

  Stream<List<Message>> watchMessages(String requestId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId)
        .order('created_at')
        .map((rows) => rows.map(Message.fromMap).toList());
  }

  Future<void> sendMessage({
    required String requestId,
    required String senderId,
    required String body,
  }) async {
    await _client.from('messages').insert({
      'request_id': requestId,
      'sender_id': senderId,
      'body': body,
    });
  }
}
