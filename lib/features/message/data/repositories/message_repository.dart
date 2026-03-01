import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
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
    cacheService: ref.read(appCacheServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class MessageRepository implements IMessageRepository {
  final IMessageRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;
  final UserSessionService _userSessionService;
  static const _conversationTtl = Duration(seconds: 30);

  MessageRepository({
    required IMessageRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
    required UserSessionService userSessionService,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService,
       _userSessionService = userSessionService;

  String _conversationsKey(int page, int size) {
    final userId = (_userSessionService.getCurrentUserId() ?? '')
        .trim()
        .toLowerCase();
    return 'conversations_${userId}_${page}_$size';
  }

  List<ConversationEntity>? _readConversationsCache(
    int page,
    int size, {
    Duration? maxAge,
  }) {
    return _cacheService.read<List<ConversationEntity>>(
      key: _conversationsKey(page, size),
      maxAge: maxAge,
      decoder: (raw) {
        final list = (raw as List).cast<dynamic>();
        return list
            .map((item) {
              final map = (item as Map).cast<String, dynamic>();
              final participantsRaw =
                  (map['participants'] as List<dynamic>? ?? const []);
              final participants = participantsRaw
                  .map((userRaw) {
                    final user = (userRaw as Map).cast<String, dynamic>();
                    return ChatUserEntity(
                      id: user['id']?.toString() ?? '',
                      firstName: user['firstName']?.toString() ?? '',
                      lastName: user['lastName']?.toString() ?? '',
                      username: user['username']?.toString() ?? '',
                      profileUrl: user['profileUrl']?.toString(),
                    );
                  })
                  .toList(growable: false);

              return ConversationEntity(
                id: map['id']?.toString() ?? '',
                participants: participants,
                lastMessage: map['lastMessage']?.toString(),
                lastMessageAt: DateTime.tryParse(
                  map['lastMessageAt']?.toString() ?? '',
                ),
              );
            })
            .toList(growable: false);
      },
    );
  }

  Future<void> _writeConversationsCache(
    List<ConversationEntity> items,
    int page,
    int size,
  ) async {
    final payload = items
        .map(
          (conversation) => {
            'id': conversation.id,
            'participants': conversation.participants
                .map(
                  (user) => {
                    'id': user.id,
                    'firstName': user.firstName,
                    'lastName': user.lastName,
                    'username': user.username,
                    'profileUrl': user.profileUrl,
                  },
                )
                .toList(growable: false),
            'lastMessage': conversation.lastMessage,
            'lastMessageAt': conversation.lastMessageAt?.toIso8601String(),
          },
        )
        .toList(growable: false);
    await _cacheService.write(
      key: _conversationsKey(page, size),
      data: payload,
    );
  }

  Future<List<ConversationEntity>> _fetchRemoteConversations({
    required int page,
    required int size,
  }) async {
    final items = await _remoteDatasource.listConversations(
      page: page,
      size: size,
    );
    final entities = items.map((item) => item.toEntity()).toList();
    if (page == 1) {
      await _writeConversationsCache(entities, page, size);
    }
    return entities;
  }

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
      await _cacheService.clearByPrefix('conversations_');
      return Right(conversation.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to open conversation',
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
    bool bypassCache = false,
  }) async {
    final isFirstPage = page == 1;
    final cached = isFirstPage
        ? _readConversationsCache(page, size, maxAge: _conversationTtl)
        : null;
    if (!bypassCache && cached != null) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      final stale = !bypassCache && isFirstPage
          ? _readConversationsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final entities = await _fetchRemoteConversations(page: page, size: size);
      return Right(entities);
    } on DioException catch (e) {
      final stale = !bypassCache && isFirstPage
          ? _readConversationsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch conversations',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      final stale = !bypassCache && isFirstPage
          ? _readConversationsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
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
      await _cacheService.clearByPrefix('conversations_');
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
  Future<Either<Failure, bool>> markConversationRead(
    String conversationId,
  ) async {
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
