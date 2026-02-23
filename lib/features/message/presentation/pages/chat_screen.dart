import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:chautari_kurakani/features/call/presentation/pages/call_session_screen.dart';
import 'package:chautari_kurakani/features/call/presentation/view_model/call_view_model.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:chautari_kurakani/features/message/presentation/state/message_state.dart';
import 'package:chautari_kurakani/features/message/presentation/view_model/message_view_model.dart';
import 'package:chautari_kurakani/core/utils/responsive.dart';
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

  Future<void> _startCall(CallTypeEntity type) async {
    final currentId = widget.currentUserId.trim();
    String otherId = '';
    ChatUserEntity? other;
    for (final participant in widget.conversation.participants) {
      final id = participant.id.trim();
      if (id.isEmpty) continue;
      if (id.toLowerCase() == currentId.toLowerCase()) continue;
      other = participant;
      otherId = id;
      break;
    }
    if (otherId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find call recipient')),
      );
      return;
    }

    final callNotifier = ref.read(callViewModelProvider.notifier);
    final callId = await callNotifier.initiateCall(
      calleeId: otherId,
      callType: type,
    );
    if (!mounted) return;

    if (callId == null) {
      final err = ref.read(callViewModelProvider).errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Failed to start call')));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallSessionScreen(
          callId: callId,
          title: other?.fullName ?? 'Calling...',
          subtitle: type == CallTypeEntity.video ? 'Video call' : 'Audio call',
          callType: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageViewModelProvider);
    final other = widget.conversation.otherParticipant(widget.currentUserId);
    final title = other?.fullName ?? 'Chat';
    final messages = state.messagesFor(widget.conversation.id);
    final isSending = state.status == MessageStatusUi.sending;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Audio Call',
            onPressed: () => _startCall(CallTypeEntity.audio),
            icon: const Icon(Icons.call_outlined),
          ),
          IconButton(
            tooltip: 'Video Call',
            onPressed: () => _startCall(CallTypeEntity.video),
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      context.scale(12),
                      context.scale(12),
                      context.scale(12),
                      context.scale(12),
                    ),
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
              padding: EdgeInsets.fromLTRB(
                context.scale(10),
                context.scale(8),
                context.scale(10),
                context.scale(10),
              ),
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
                  SizedBox(width: context.scale(8)),
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
        margin: EdgeInsets.symmetric(vertical: context.scale(4)),
        padding: EdgeInsets.symmetric(
          horizontal: context.scale(12),
          vertical: context.scale(9),
        ),
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
            Text(
              message.text,
              style: TextStyle(color: fg, fontSize: context.fs(15)),
            ),
            SizedBox(height: context.scale(3)),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: fg.withValues(alpha: 0.78),
                fontSize: context.fs(11),
              ),
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
