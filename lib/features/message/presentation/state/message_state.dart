import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:equatable/equatable.dart';

enum MessageStatusUi { initial, loading, loaded, sending, error }

class MessageState extends Equatable {
  final MessageStatusUi status;
  final List<ConversationEntity> conversations;
  final String? activeConversationId;
  final Map<String, List<MessageEntity>> messagesByConversation;
  final Map<String, int> unreadByConversation;
  final String? errorMessage;

  const MessageState({
    required this.status,
    this.conversations = const [],
    this.activeConversationId,
    this.messagesByConversation = const {},
    this.unreadByConversation = const {},
    this.errorMessage,
  });

  const MessageState.initial()
    : status = MessageStatusUi.initial,
      conversations = const [],
      activeConversationId = null,
      messagesByConversation = const {},
      unreadByConversation = const {},
      errorMessage = null;

  MessageState copyWith({
    MessageStatusUi? status,
    List<ConversationEntity>? conversations,
    String? activeConversationId,
    bool clearActiveConversationId = false,
    Map<String, List<MessageEntity>>? messagesByConversation,
    Map<String, int>? unreadByConversation,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      activeConversationId: clearActiveConversationId
          ? null
          : activeConversationId ?? this.activeConversationId,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      unreadByConversation: unreadByConversation ?? this.unreadByConversation,
      errorMessage: errorMessage,
    );
  }

  List<MessageEntity> messagesFor(String conversationId) {
    return messagesByConversation[conversationId] ?? const [];
  }

  int unreadFor(String conversationId) {
    return unreadByConversation[conversationId] ?? 0;
  }

  int get totalUnread {
    if (unreadByConversation.isEmpty) return 0;
    return unreadByConversation.values.fold(0, (sum, item) => sum + item);
  }

  @override
  List<Object?> get props => [
    status,
    conversations,
    activeConversationId,
    messagesByConversation,
    unreadByConversation,
    errorMessage,
  ];
}
