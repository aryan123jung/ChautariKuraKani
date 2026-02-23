import 'package:equatable/equatable.dart';

class ChatUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const ChatUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  String get fullName {
    final name = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
    if (name.isNotEmpty) return name;
    if (username.trim().isNotEmpty) return username;
    return 'User';
  }

  @override
  List<Object?> get props => [id, firstName, lastName, username, profileUrl];
}

class ConversationEntity extends Equatable {
  final String id;
  final List<ChatUserEntity> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ConversationEntity({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
  });

  ChatUserEntity? otherParticipant(String currentUserId) {
    final normalized = currentUserId.trim().toLowerCase();
    for (final user in participants) {
      if (user.id.trim().toLowerCase() != normalized) return user;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, participants, lastMessage, lastMessageAt];
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime? createdAt;
  final List<String> readBy;
  final ChatUserEntity? sender;
  final ChatUserEntity? receiver;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.createdAt,
    this.readBy = const [],
    this.sender,
    this.receiver,
  });

  bool isMine(String currentUserId) {
    return senderId.trim().toLowerCase() == currentUserId.trim().toLowerCase();
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    receiverId,
    text,
    createdAt,
    readBy,
    sender,
    receiver,
  ];
}
