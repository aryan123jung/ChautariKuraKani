import 'dart:async';

import 'package:chautari_kurakani/features/friend_request/domain/usecases/get_friend_status_usecase.dart';
import 'package:chautari_kurakani/features/message/data/services/message_socket_service.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:chautari_kurakani/features/message/domain/usecases/message_usecases.dart';
import 'package:chautari_kurakani/features/message/presentation/state/message_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageViewModelProvider =
    NotifierProvider<MessageViewModel, MessageState>(MessageViewModel.new);

class MessageViewModel extends Notifier<MessageState> {
  late final GetOrCreateConversationUsecase _getOrCreateConversationUsecase;
  late final ListConversationsUsecase _listConversationsUsecase;
  late final ListMessagesUsecase _listMessagesUsecase;
  late final SendMessageUsecase _sendMessageUsecase;
  late final MarkConversationReadUsecase _markConversationReadUsecase;
  late final GetFriendStatusUsecase _getFriendStatusUsecase;
  late final MessageSocketService _socketService;

  StreamSubscription<MessageEntity>? _messageSub;
  String _currentUserId = '';
  bool _isRefreshingConversations = false;

  @override
  MessageState build() {
    _getOrCreateConversationUsecase = ref.read(
      getOrCreateConversationUsecaseProvider,
    );
    _listConversationsUsecase = ref.read(listConversationsUsecaseProvider);
    _listMessagesUsecase = ref.read(listMessagesUsecaseProvider);
    _sendMessageUsecase = ref.read(sendMessageUsecaseProvider);
    _markConversationReadUsecase = ref.read(
      markConversationReadUsecaseProvider,
    );
    _getFriendStatusUsecase = ref.read(getFriendStatusUsecaseProvider);
    _socketService = ref.read(messageSocketServiceProvider);

    ref.onDispose(() {
      _messageSub?.cancel();
      _socketService.disconnect();
    });

    return const MessageState.initial();
  }

  Future<void> connectRealtime() async {
    await _socketService.connect();
    await _messageSub?.cancel();

    _messageSub = _socketService.messageStream.listen((incoming) {
      _appendIncomingMessage(incoming);
      _refreshConversationPreviewWithMessage(incoming);
      _trackUnreadForIncoming(incoming);
    });
  }

  void disconnectRealtime() {
    _messageSub?.cancel();
    _messageSub = null;
    _socketService.disconnect();
  }

  void joinConversationRoom(String conversationId) {
    _socketService.joinConversation(conversationId);
  }

  void leaveConversationRoom(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  void setCurrentUserId(String? userId) {
    _currentUserId = (userId ?? '').trim().toLowerCase();
  }

  void clearActiveConversation() {
    state = state.copyWith(clearActiveConversationId: true);
  }

  Future<void> loadConversations({
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh || state.conversations.isEmpty) {
      state = state.copyWith(
        status: MessageStatusUi.loading,
        errorMessage: null,
      );
    }

    final result = await _listConversationsUsecase(
      ListConversationsParams(
        page: page,
        size: size,
        bypassCache: forceRefresh,
      ),
    );

    final maybeItems = result.fold<List<ConversationEntity>?>((failure) {
      state = state.copyWith(
        status: MessageStatusUi.error,
        errorMessage: failure.message,
      );
      return null;
    }, (items) => items);

    if (maybeItems == null) return;

    final filtered = await _sanitizeConversations(maybeItems);
    state = state.copyWith(
      status: MessageStatusUi.loaded,
      conversations: filtered,
      errorMessage: null,
    );
  }

  Future<ConversationEntity?> getOrCreateConversation(
    String otherUserId,
  ) async {
    final result = await _getOrCreateConversationUsecase(
      GetOrCreateConversationParams(otherUserId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: MessageStatusUi.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (conversation) {
        final existingIndex = state.conversations.indexWhere(
          (item) => item.id == conversation.id,
        );

        final updatedList = List<ConversationEntity>.from(state.conversations);
        if (existingIndex >= 0) {
          updatedList[existingIndex] = conversation;
        } else {
          updatedList.insert(0, conversation);
        }

        state = state.copyWith(
          status: MessageStatusUi.loaded,
          conversations: updatedList,
          errorMessage: null,
        );
        return conversation;
      },
    );
  }

  Future<void> loadMessages(
    String conversationId, {
    int page = 1,
    int size = 50,
  }) async {
    state = state.copyWith(
      status: MessageStatusUi.loading,
      activeConversationId: conversationId,
      errorMessage: null,
    );

    final result = await _listMessagesUsecase(
      ListMessagesParams(
        conversationId: conversationId,
        page: page,
        size: size,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: MessageStatusUi.error,
          errorMessage: failure.message,
        );
      },
      (messages) {
        final sorted = List<MessageEntity>.from(messages)
          ..sort((a, b) {
            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
            return aTime.compareTo(bTime);
          });

        final nextMap = Map<String, List<MessageEntity>>.from(
          state.messagesByConversation,
        );
        nextMap[conversationId] = sorted;

        state = state.copyWith(
          status: MessageStatusUi.loaded,
          activeConversationId: conversationId,
          messagesByConversation: nextMap,
          errorMessage: null,
        );
      },
    );
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    state = state.copyWith(status: MessageStatusUi.sending, errorMessage: null);

    final result = await _sendMessageUsecase(
      SendMessageParams(conversationId: conversationId, text: trimmed),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: MessageStatusUi.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (sent) {
        _appendIncomingMessage(sent);
        _refreshConversationPreviewWithMessage(sent);
        state = state.copyWith(
          status: MessageStatusUi.loaded,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<void> markRead(String conversationId) async {
    await _markConversationReadUsecase(MarkReadParams(conversationId));
    markConversationAsReadLocal(conversationId);
  }

  void markConversationAsReadLocal(String conversationId) {
    final id = conversationId.trim();
    if (id.isEmpty) return;

    final nextUnread = Map<String, int>.from(state.unreadByConversation);
    if (!nextUnread.containsKey(id)) return;
    nextUnread.remove(id);
    state = state.copyWith(unreadByConversation: nextUnread);
  }

  void _appendIncomingMessage(MessageEntity message) {
    final conversationId = message.conversationId;
    if (conversationId.trim().isEmpty) return;

    final nextMap = Map<String, List<MessageEntity>>.from(
      state.messagesByConversation,
    );
    final existing = List<MessageEntity>.from(
      nextMap[conversationId] ?? const [],
    );

    final duplicate = existing.any((item) => item.id == message.id);
    if (duplicate) return;

    existing.add(message);
    existing.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return aTime.compareTo(bTime);
    });

    nextMap[conversationId] = existing;

    state = state.copyWith(
      status: MessageStatusUi.loaded,
      messagesByConversation: nextMap,
      errorMessage: null,
    );
  }

  void _refreshConversationPreviewWithMessage(MessageEntity message) {
    final index = state.conversations.indexWhere(
      (item) => item.id == message.conversationId,
    );
    if (index < 0) {
      _insertOptimisticConversationFromMessage(message);
      _refreshConversationsFromServer();
      return;
    }

    final updatedConversation = ConversationEntity(
      id: state.conversations[index].id,
      participants: state.conversations[index].participants,
      lastMessage: message.text,
      lastMessageAt: message.createdAt,
    );

    final next = List<ConversationEntity>.from(state.conversations);
    next.removeAt(index);
    next.insert(0, updatedConversation);

    state = state.copyWith(status: MessageStatusUi.loaded, conversations: next);
  }

  void _insertOptimisticConversationFromMessage(MessageEntity message) {
    final conversationId = message.conversationId.trim();
    if (conversationId.isEmpty) return;
    if (state.conversations.any((item) => item.id == conversationId)) return;

    final sender = message.sender;
    final receiver = message.receiver;
    if (sender == null || receiver == null) return;
    if (sender.id.trim().isEmpty || receiver.id.trim().isEmpty) return;

    final optimistic = ConversationEntity(
      id: conversationId,
      participants: [sender, receiver],
      lastMessage: message.text,
      lastMessageAt: message.createdAt,
    );

    state = state.copyWith(
      status: MessageStatusUi.loaded,
      conversations: [optimistic, ...state.conversations],
    );
  }

  Future<void> _refreshConversationsFromServer() async {
    if (_isRefreshingConversations) return;
    _isRefreshingConversations = true;
    try {
      await loadConversations(forceRefresh: true);
    } finally {
      _isRefreshingConversations = false;
    }
  }

  void _trackUnreadForIncoming(MessageEntity message) {
    final senderId = message.senderId.trim().toLowerCase();
    if (_currentUserId.isEmpty || senderId == _currentUserId) {
      return;
    }

    final conversationId = message.conversationId.trim();
    if (conversationId.isEmpty) return;

    if (state.activeConversationId == conversationId) {
      markConversationAsReadLocal(conversationId);
      return;
    }

    final nextUnread = Map<String, int>.from(state.unreadByConversation);
    nextUnread[conversationId] = (nextUnread[conversationId] ?? 0) + 1;
    state = state.copyWith(unreadByConversation: nextUnread);
  }

  Future<List<ConversationEntity>> _sanitizeConversations(
    List<ConversationEntity> items,
  ) async {
    final currentId = _currentUserId.trim().toLowerCase();
    if (items.isEmpty) return const [];

    final withValidParticipant = <ConversationEntity>[];
    for (final conversation in items) {
      ChatUserEntity? other;
      if (currentId.isNotEmpty) {
        other = conversation.otherParticipant(currentId);
      } else if (conversation.participants.length >= 2) {
        other = conversation.participants.firstWhere(
          (item) => item.id.trim().isNotEmpty,
          orElse: () => const ChatUserEntity(
            id: '',
            firstName: '',
            lastName: '',
            username: '',
          ),
        );
      }

      if (other == null || other.id.trim().isEmpty) {
        continue;
      }
      withValidParticipant.add(conversation);
    }

    if (withValidParticipant.isEmpty) return const [];

    // Keep chats only with active friends.
    final filteredByFriendship = await Future.wait(
      withValidParticipant.map((conversation) async {
        final other = conversation.otherParticipant(currentId);
        final otherId = other?.id.trim() ?? '';
        if (otherId.isEmpty) return null;

        final statusResult = await _getFriendStatusUsecase(
          GetFriendStatusParams(otherId),
        );
        return statusResult.fold(
          (_) => null,
          (status) => status.status == 'FRIEND' ? conversation : null,
        );
      }),
    );

    return filteredByFriendship.whereType<ConversationEntity>().toList();
  }
}
