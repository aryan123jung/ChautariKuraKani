import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/message/data/repositories/message_repository.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:chautari_kurakani/features/message/domain/repositories/message_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetOrCreateConversationParams extends Equatable {
  final String otherUserId;
  const GetOrCreateConversationParams(this.otherUserId);
  @override
  List<Object?> get props => [otherUserId];
}

class ListConversationsParams extends Equatable {
  final int page;
  final int size;
  const ListConversationsParams({this.page = 1, this.size = 20});
  @override
  List<Object?> get props => [page, size];
}

class ListMessagesParams extends Equatable {
  final String conversationId;
  final int page;
  final int size;

  const ListMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.size = 50,
  });

  @override
  List<Object?> get props => [conversationId, page, size];
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String text;

  const SendMessageParams({required this.conversationId, required this.text});

  @override
  List<Object?> get props => [conversationId, text];
}

class MarkReadParams extends Equatable {
  final String conversationId;
  const MarkReadParams(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

final getOrCreateConversationUsecaseProvider =
    Provider<GetOrCreateConversationUsecase>((ref) {
      return GetOrCreateConversationUsecase(
        repository: ref.read(messageRepositoryProvider),
      );
    });

final listConversationsUsecaseProvider = Provider<ListConversationsUsecase>((
  ref,
) {
  return ListConversationsUsecase(repository: ref.read(messageRepositoryProvider));
});

final listMessagesUsecaseProvider = Provider<ListMessagesUsecase>((ref) {
  return ListMessagesUsecase(repository: ref.read(messageRepositoryProvider));
});

final sendMessageUsecaseProvider = Provider<SendMessageUsecase>((ref) {
  return SendMessageUsecase(repository: ref.read(messageRepositoryProvider));
});

final markConversationReadUsecaseProvider = Provider<MarkConversationReadUsecase>((
  ref,
) {
  return MarkConversationReadUsecase(
    repository: ref.read(messageRepositoryProvider),
  );
});

class GetOrCreateConversationUsecase
    implements
        UsecaseWithParams<ConversationEntity, GetOrCreateConversationParams> {
  final IMessageRepository _repository;

  GetOrCreateConversationUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ConversationEntity>> call(
    GetOrCreateConversationParams params,
  ) {
    return _repository.getOrCreateConversation(params.otherUserId);
  }
}

class ListConversationsUsecase
    implements UsecaseWithParams<List<ConversationEntity>, ListConversationsParams> {
  final IMessageRepository _repository;

  ListConversationsUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(
    ListConversationsParams params,
  ) {
    return _repository.listConversations(page: params.page, size: params.size);
  }
}

class ListMessagesUsecase
    implements UsecaseWithParams<List<MessageEntity>, ListMessagesParams> {
  final IMessageRepository _repository;

  ListMessagesUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(ListMessagesParams params) {
    return _repository.listMessages(
      conversationId: params.conversationId,
      page: params.page,
      size: params.size,
    );
  }
}

class SendMessageUsecase
    implements UsecaseWithParams<MessageEntity, SendMessageParams> {
  final IMessageRepository _repository;

  SendMessageUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return _repository.sendMessage(
      conversationId: params.conversationId,
      text: params.text,
    );
  }
}

class MarkConversationReadUsecase
    implements UsecaseWithParams<bool, MarkReadParams> {
  final IMessageRepository _repository;

  MarkConversationReadUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(MarkReadParams params) {
    return _repository.markConversationRead(params.conversationId);
  }
}
