import 'package:chautari_kurakani/features/message/data/models/message_api_models.dart';

abstract class IMessageRemoteDatasource {
  Future<ConversationApiModel> getOrCreateConversation(String otherUserId);
  Future<List<ConversationApiModel>> listConversations({
    int page = 1,
    int size = 20,
  });
  Future<List<MessageApiModel>> listMessages({
    required String conversationId,
    int page = 1,
    int size = 50,
  });
  Future<MessageApiModel> sendMessage({
    required String conversationId,
    required String text,
  });
  Future<void> markRead(String conversationId);
}
