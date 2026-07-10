import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/message.dart';
import 'message_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.requestId, super.key});

  final String requestId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final senderId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      await ref.read(messageRepositoryProvider).sendMessage(
            requestId: widget.requestId,
            senderId: senderId,
            body: body,
          );
      _bodyController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesForRequestProvider(widget.requestId));
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser!.id;
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Mesajlar')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz mesaj yok.',
                      style: TextStyle(color: GlassColors.textSecondary(brightness)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == currentUserId;
                    return _MessageBubble(message: message, isMine: isMine);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Hata: $error')),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GlassTextField(
                      controller: _bodyController,
                      minLines: 1,
                      maxLines: 4,
                      hintText: 'Mesaj yaz...',
                      onFieldSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [GlassColors.primary, GlassColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : _send,
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isMine
              ? const LinearGradient(
                  colors: [GlassColors.primary, GlassColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMine ? null : GlassColors.glassFill(brightness),
          border: isMine ? null : Border.all(color: GlassColors.glassBorder(brightness)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body,
              style: TextStyle(
                color: isMine ? Colors.white : GlassColors.textPrimary(brightness),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.75)
                    : GlassColors.textSecondary(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
