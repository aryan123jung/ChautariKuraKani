import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/features/message/data/datasources/message_datasource.dart';
import 'package:chautari_kurakani/features/message/data/datasources/remote/message_remote_datasource.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:chautari_kurakani/features/message/domain/repositories/message_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageRepositoryProvider = Provider<IMessageRepository>((ref) {
  return MessageRepository(
    remoteDatasource: ref.read(messageRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class MessageRepository implements IMessageRepository {
  final IMessageRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  MessageRepository({
    required IMessageRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation(
    String otherUserId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final conversation = await _remoteDatasource.getOrCreateConversation(
        otherUserId,
      );
      return Right(conversation.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to open conversation',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> listConversations({
    int page = 1,
    int size = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final items = await _remoteDatasource.listConversations(
        page: page,
        size: size,
      );
      return Right(items.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch conversations',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> listMessages({
    required String conversationId,
    int page = 1,
    int size = 50,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final items = await _remoteDatasource.listMessages(
        conversationId: conversationId,
        page: page,
        size: size,
      );
      return Right(items.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch messages',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final message = await _remoteDatasource.sendMessage(
        conversationId: conversationId,
        text: text,
      );
      return Right(message.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to send message',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markConversationRead(String conversationId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.markRead(conversationId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to mark conversation read',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
