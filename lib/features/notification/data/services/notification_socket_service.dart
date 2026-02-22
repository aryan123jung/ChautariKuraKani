import 'dart:async';

import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/services/storage/token_service.dart';
import 'package:chautari_kurakani/features/notification/data/models/notification_api_model.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final notificationSocketServiceProvider =
    Provider<NotificationSocketService>((ref) {
      return NotificationSocketService(tokenService: ref.read(tokenServiceProvider));
    });

class NotificationSocketService {
  final TokenService _tokenService;

  NotificationSocketService({required TokenService tokenService})
    : _tokenService = tokenService;

  io.Socket? _socket;
  final _controller = StreamController<NotificationEntity>.broadcast();

  Stream<NotificationEntity> get stream => _controller.stream;

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

    _socket!.on('notification:new', (payload) {
      if (payload is Map<String, dynamic>) {
        final item = NotificationApiModel.fromJson(payload).toEntity();
        _controller.add(item);
        return;
      }

      if (payload is Map) {
        final item = NotificationApiModel.fromJson(
          payload.map((key, value) => MapEntry(key.toString(), value)),
        ).toEntity();
        _controller.add(item);
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
