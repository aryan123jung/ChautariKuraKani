import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/message/data/datasources/message_datasource.dart';
import 'package:chautari_kurakani/features/message/data/models/message_api_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageRemoteDatasourceProvider = Provider<IMessageRemoteDatasource>((ref) {
  return MessageRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class MessageRemoteDatasource implements IMessageRemoteDatasource {
  final ApiClient _apiClient;

  MessageRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ConversationApiModel> getOrCreateConversation(String otherUserId) async {
    final response = await _apiClient.post(
      ApiEndpoints.getOrCreateConversation(otherUserId),
    );
    return ConversationApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ConversationApiModel>> listConversations({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.conversations,
      queryParameters: {'page': page, 'size': size},
    );
    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => ConversationApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MessageApiModel>> listMessages({
    required String conversationId,
    int page = 1,
    int size = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.messages(conversationId),
      queryParameters: {'page': page, 'size': size},
    );
    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => MessageApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageApiModel> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.messages(conversationId),
      data: {'text': text},
    );

    return MessageApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> markRead(String conversationId) async {
    await _apiClient.patch(ApiEndpoints.markConversationRead(conversationId));
  }
}
