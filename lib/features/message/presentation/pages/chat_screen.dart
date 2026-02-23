import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:chautari_kurakani/features/message/presentation/state/message_state.dart';
import 'package:chautari_kurakani/features/message/presentation/view_model/message_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ConversationEntity conversation;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final MessageViewModel _messageNotifier;

  @override
  void initState() {
    super.initState();
    _messageNotifier = ref.read(messageViewModelProvider.notifier);
    Future.microtask(() async {
      _messageNotifier.joinConversationRoom(widget.conversation.id);
      await _messageNotifier.loadMessages(widget.conversation.id);
      await _messageNotifier.markRead(widget.conversation.id);
      _messageNotifier.markConversationAsReadLocal(widget.conversation.id);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageNotifier.leaveConversationRoom(widget.conversation.id);
    _messageNotifier.clearActiveConversation();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    final ok = await _messageNotifier.sendMessage(
      conversationId: widget.conversation.id,
      text: text,
    );

    if (!mounted) return;
    if (!ok) {
      final err = ref.read(messageViewModelProvider).errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Failed to send message')));
      return;
    }

    Future.delayed(const Duration(milliseconds: 80), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageViewModelProvider);
    final other = widget.conversation.otherParticipant(widget.currentUserId);
    final title = other?.fullName ?? 'Chat';
    final messages = state.messagesFor(widget.conversation.id);
    final isSending = state.status == MessageStatusUi.sending;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final mine = message.isMine(widget.currentUserId);
                      return _MessageBubble(message: message, isMine: mine);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isSending ? null : _sendMessage,
                    child: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
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
  final MessageEntity message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? const Color(0XFF76C05D) : const Color(0xFFE9ECEF);
    final fg = isMine ? Colors.white : Colors.black87;
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: TextStyle(color: fg, fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(color: fg.withValues(alpha: 0.78), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final h = dateTime.hour;
    final m = dateTime.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    return '$hh:$m $suffix';
  }
}
