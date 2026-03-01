import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:dartz/dartz.dart';

abstract class IMessageRepository {
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
    String otherUserId,
  );

  Future<Either<Failure, List<ConversationEntity>>> listConversations({
    int page = 1,
    int size = 20,
    bool bypassCache = false,
  });

  Future<Either<Failure, List<MessageEntity>>> listMessages({
    required String conversationId,
    int page = 1,
    int size = 50,
  });

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String text,
  });

  Future<Either<Failure, bool>> markConversationRead(String conversationId);
}
