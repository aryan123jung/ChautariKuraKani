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
  late final CallViewModel _callNotifier;

  @override
  void initState() {
    super.initState();
    _messageNotifier = ref.read(messageViewModelProvider.notifier);
    _callNotifier = ref.read(callViewModelProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _messageNotifier.joinConversationRoom(widget.conversation.id);
      await _messageNotifier.loadMessages(widget.conversation.id);
      if (!mounted) return;
      await _messageNotifier.markRead(widget.conversation.id);
      _messageNotifier.markConversationAsReadLocal(widget.conversation.id);
      await _callNotifier.loadCallHistory();
      if (!mounted) return;
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageNotifier.leaveConversationRoom(widget.conversation.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageNotifier.clearActiveConversation();
    });
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

    final callId = await _callNotifier.initiateCall(
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
    if (!mounted) return;
    await _callNotifier.loadCallHistory();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageViewModelProvider);
    final callState = ref.watch(callViewModelProvider);
    final other = widget.conversation.otherParticipant(widget.currentUserId);
    final title = other?.fullName ?? 'Unknown user';
    final messages = state.messagesFor(widget.conversation.id);
    final timelineItems = _buildTimelineItems(
      messages: messages,
      callHistory: callState.callHistory,
      otherUserId: other?.id ?? '',
    );
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
            child: timelineItems.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      context.scale(12),
                      context.scale(12),
                      context.scale(12),
                      context.scale(12),
                    ),
                    itemCount: timelineItems.length,
                    itemBuilder: (context, index) {
                      final item = timelineItems[index];
                      if (item.message != null) {
                        final message = item.message!;
                        final mine = message.isMine(widget.currentUserId);
                        return _MessageBubble(message: message, isMine: mine);
                      }

                      final call = item.call!;
                      return _CallTimelineBubble(
                        call: call,
                        currentUserId: widget.currentUserId,
                      );
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

  List<_ChatTimelineItem> _buildTimelineItems({
    required List<MessageEntity> messages,
    required List<CallLogEntity> callHistory,
    required String otherUserId,
  }) {
    final normalizedMe = widget.currentUserId.trim().toLowerCase();
    final normalizedOther = otherUserId.trim().toLowerCase();

    final callItems = callHistory
        .where((call) {
          final caller = call.callerId.trim().toLowerCase();
          final callee = call.calleeId.trim().toLowerCase();
          if (normalizedMe.isEmpty || normalizedOther.isEmpty) return false;
          final direct = caller == normalizedMe && callee == normalizedOther;
          final reverse = caller == normalizedOther && callee == normalizedMe;
          return direct || reverse;
        })
        .map(_ChatTimelineItem.call)
        .toList();

    final messageItems = messages.map(_ChatTimelineItem.message).toList();
    final all = [...messageItems, ...callItems];
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return all;
  }
}

class _ChatTimelineItem {
  final MessageEntity? message;
  final CallLogEntity? call;
  final DateTime timestamp;

  const _ChatTimelineItem._({
    required this.message,
    required this.call,
    required this.timestamp,
  });

  factory _ChatTimelineItem.message(MessageEntity message) {
    return _ChatTimelineItem._(
      message: message,
      call: null,
      timestamp: message.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory _ChatTimelineItem.call(CallLogEntity call) {
    return _ChatTimelineItem._(
      message: null,
      call: call,
      timestamp:
          call.startedAt ??
          call.createdAt ??
          call.endedAt ??
          DateTime.fromMillisecondsSinceEpoch(0),
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

class _CallTimelineBubble extends StatelessWidget {
  final CallLogEntity call;
  final String currentUserId;

  const _CallTimelineBubble({required this.call, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final mine =
        call.callerId.trim().toLowerCase() ==
        currentUserId.trim().toLowerCase();
    final icon = _iconFor(call.callType);
    final peerName = _peerName(call, mine);
    final title = _titleFor(call, mine, peerName);
    final subtitle = _subtitleFor(call);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.scale(6),
        horizontal: context.scale(8),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scale(12),
            vertical: context.scale(10),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E5EA)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: context.scale(16), color: Colors.black54),
              SizedBox(width: context.scale(8)),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: context.fs(12.5),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: context.scale(2)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: context.fs(11.5),
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(CallTypeEntity type) {
    return type == CallTypeEntity.video
        ? Icons.videocam_rounded
        : Icons.call_rounded;
  }

  String _titleFor(CallLogEntity call, bool mine, String peerName) {
    switch (call.status) {
      case CallStatusEntity.accepted:
      case CallStatusEntity.ended:
        return mine ? 'You called $peerName' : '$peerName called you';
      case CallStatusEntity.rejected:
        return mine
            ? '$peerName declined your call'
            : 'You declined $peerName\'s call';
      case CallStatusEntity.missed:
        return mine ? '$peerName did not answer' : 'Missed call from $peerName';
      case CallStatusEntity.ringing:
        return mine ? 'You canceled the call' : '$peerName canceled the call';
    }
  }

  String _subtitleFor(CallLogEntity call) {
    final when = _formatTime(call.startedAt ?? call.createdAt ?? call.endedAt);
    final typeLabel = call.callType == CallTypeEntity.video
        ? 'Video call'
        : 'Voice call';
    final duration = call.durationSeconds ?? 0;
    if (duration <= 0) return '$typeLabel • $when';

    final mins = duration ~/ 60;
    final secs = duration % 60;
    final text = mins > 0
        ? '${mins}m ${secs.toString().padLeft(2, '0')}s'
        : '${secs}s';
    return '$typeLabel • $when • $text';
  }

  String _peerName(CallLogEntity call, bool mine) {
    if (mine) {
      final name = call.callee?.fullName ?? '';
      if (name.trim().isNotEmpty) return name;
      return 'User';
    }
    final name = call.caller?.fullName ?? '';
    if (name.trim().isNotEmpty) return name;
    return 'User';
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
