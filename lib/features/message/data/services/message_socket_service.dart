import 'dart:async';

import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/services/storage/token_service.dart';
import 'package:chautari_kurakani/features/message/data/models/message_api_models.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final messageSocketServiceProvider = Provider<MessageSocketService>((ref) {
  return MessageSocketService(tokenService: ref.read(tokenServiceProvider));
});

class MessageSocketService {
  final TokenService _tokenService;

  MessageSocketService({required TokenService tokenService})
    : _tokenService = tokenService;

  io.Socket? _socket;
  final _messageStreamController = StreamController<MessageEntity>.broadcast();

  Stream<MessageEntity> get messageStream => _messageStreamController.stream;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) return;

    _socket = io.io(
      ApiEndpoints.uploadBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.on('message:new', (payload) {
      if (payload is Map<String, dynamic>) {
        _messageStreamController.add(MessageApiModel.fromJson(payload).toEntity());
        return;
      }
      if (payload is Map) {
        final data = payload.map((key, value) => MapEntry(key.toString(), value));
        _messageStreamController.add(MessageApiModel.fromJson(data).toEntity());
      }
    });

    _socket!.connect();
  }

  void joinConversation(String conversationId) {
    final id = conversationId.trim();
    if (id.isEmpty) return;
    _socket?.emit('conversation:join', id);
  }

  void leaveConversation(String conversationId) {
    final id = conversationId.trim();
    if (id.isEmpty) return;
    _socket?.emit('conversation:leave', id);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageStreamController.close();
  }
}
