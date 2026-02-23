import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';

class ChatUserApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const ChatUserApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  factory ChatUserApiModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawProfile = json['profileUrl']?.toString();
      return ChatUserApiModel(
        id: json['_id']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        profileUrl: _resolveProfile(rawProfile),
      );
    }

    final id = json?.toString() ?? '';
    return ChatUserApiModel(
      id: id,
      firstName: '',
      lastName: '',
      username: '',
      profileUrl: null,
    );
  }

  ChatUserEntity toEntity() {
    return ChatUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      profileUrl: profileUrl,
    );
  }

  static String? _resolveProfile(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http')) return value;
    if (value.contains('/') || value.contains('\\')) {
      return ApiEndpoints.uploadUrl(value);
    }
    return ApiEndpoints.profileImageUrl(value);
  }
}

class ConversationApiModel {
  final String id;
  final List<ChatUserApiModel> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ConversationApiModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ConversationApiModel.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];

    return ConversationApiModel(
      id: json['_id']?.toString() ?? '',
      participants: rawParticipants
          .map((item) => ChatUserApiModel.fromJson(item))
          .toList(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      participants: participants.map((item) => item.toEntity()).toList(),
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
    );
  }
}

class MessageApiModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime? createdAt;
  final List<String> readBy;
  final ChatUserApiModel? sender;
  final ChatUserApiModel? receiver;

  const MessageApiModel({
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

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['senderId'];
    final receiverRaw = json['receiverId'];
    final conversationRaw = json['conversationId'];

    final senderId = senderRaw is Map<String, dynamic>
        ? senderRaw['_id']?.toString() ?? ''
        : senderRaw?.toString() ?? '';

    final receiverId = receiverRaw is Map<String, dynamic>
        ? receiverRaw['_id']?.toString() ?? ''
        : receiverRaw?.toString() ?? '';

    final conversationId = conversationRaw is Map<String, dynamic>
        ? conversationRaw['_id']?.toString() ?? ''
        : conversationRaw?.toString() ?? '';

    final readByRaw = json['readBy'] as List<dynamic>? ?? [];
    final readBy = readByRaw
        .map((item) => item is Map<String, dynamic>
            ? item['_id']?.toString() ?? ''
            : item?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return MessageApiModel(
      id: json['_id']?.toString() ?? '',
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      text: json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      readBy: readBy,
      sender: senderRaw is Map<String, dynamic>
          ? ChatUserApiModel.fromJson(senderRaw)
          : null,
      receiver: receiverRaw is Map<String, dynamic>
          ? ChatUserApiModel.fromJson(receiverRaw)
          : null,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: createdAt,
      readBy: readBy,
      sender: sender?.toEntity(),
      receiver: receiver?.toEntity(),
    );
  }
}
