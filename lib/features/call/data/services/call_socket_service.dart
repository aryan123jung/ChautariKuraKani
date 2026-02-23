import 'dart:async';

import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/services/storage/token_service.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum CallSocketEventType {
  incoming,
  ringing,
  accepted,
  rejected,
  missed,
  ended,
  offer,
  answer,
  iceCandidate,
}

class CallSocketEvent {
  final CallSocketEventType type;
  final String callId;
  final String? callerId;
  final String? calleeId;
  final String? byUserId;
  final CallTypeEntity? callType;
  final Map<String, dynamic> raw;

  const CallSocketEvent({
    required this.type,
    required this.callId,
    this.callerId,
    this.calleeId,
    this.byUserId,
    this.callType,
    this.raw = const {},
  });
}

final callSocketServiceProvider = Provider<CallSocketService>((ref) {
  return CallSocketService(tokenService: ref.read(tokenServiceProvider));
});

class CallSocketService {
  final TokenService _tokenService;

  CallSocketService({required TokenService tokenService})
    : _tokenService = tokenService;

  io.Socket? _socket;
  final _controller = StreamController<CallSocketEvent>.broadcast();
  String? _lastErrorMessage;

  Stream<CallSocketEvent> get stream => _controller.stream;
  String? get lastErrorMessage => _lastErrorMessage;

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

    _socket!.on('call:incoming', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.incoming,
          callId: data['callId']?.toString() ?? '',
          callerId: data['callerId']?.toString(),
          calleeId: data['calleeId']?.toString(),
          callType: _parseCallType(data['callType']?.toString()),
          raw: data,
        ),
      );
    });

    _socket!.on('call:ringing', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.ringing,
          callId: data['callId']?.toString() ?? '',
          callerId: data['callerId']?.toString(),
          calleeId: data['calleeId']?.toString(),
          callType: _parseCallType(data['callType']?.toString()),
          raw: data,
        ),
      );
    });

    _socket!.on('call:accepted', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.accepted,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['by']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.on('call:rejected', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.rejected,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['by']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.on('call:missed', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.missed,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['userId']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.on('call:ended', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.ended,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['by']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.on('call:offer', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.offer,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['fromUserId']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.on('call:answer', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.answer,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['fromUserId']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.on('call:ice-candidate', (payload) {
      final data = _asMap(payload);
      _controller.add(
        CallSocketEvent(
          type: CallSocketEventType.iceCandidate,
          callId: data['callId']?.toString() ?? '',
          byUserId: data['fromUserId']?.toString(),
          raw: data,
        ),
      );
    });

    _socket!.connect();
  }

  Future<String?> initiateCall({
    required String calleeId,
    required CallTypeEntity callType,
  }) async {
    _lastErrorMessage = null;
    await connect();

    if (_socket == null || _socket?.connected != true) {
      _lastErrorMessage = 'Socket not connected. Please try again.';
      return null;
    }

    final response = await _emitWithAck(
      event: 'call:initiate',
      payload: {'calleeId': calleeId, 'callType': _callTypeToRaw(callType)},
    );

    if (response == null) {
      _lastErrorMessage = 'No response from server. Check backend/socket.';
      return null;
    }
    final success = response['success'] == true;
    if (!success) {
      _lastErrorMessage =
          response['message']?.toString() ?? 'Failed to initiate call';
      return null;
    }
    final data = _asMap(response['data']);
    final callId = data['callId']?.toString();
    if (callId == null || callId.trim().isEmpty) {
      _lastErrorMessage = 'Invalid callId from server';
      return null;
    }
    return callId;
  }

  Future<bool> acceptCall(String callId) async {
    final response = await _emitWithAck(
      event: 'call:accept',
      payload: {'callId': callId},
    );
    return response?['success'] == true;
  }

  Future<bool> rejectCall(String callId) async {
    final response = await _emitWithAck(
      event: 'call:reject',
      payload: {'callId': callId},
    );
    return response?['success'] == true;
  }

  Future<bool> endCall(String callId) async {
    final response = await _emitWithAck(
      event: 'call:end',
      payload: {'callId': callId},
    );
    return response?['success'] == true;
  }

  Future<bool> sendOffer({
    required String callId,
    required Map<String, dynamic> offer,
  }) async {
    final response = await _emitWithAck(
      event: 'call:offer',
      payload: {'callId': callId, 'offer': offer},
    );
    return response?['success'] == true;
  }

  Future<bool> sendAnswer({
    required String callId,
    required Map<String, dynamic> answer,
  }) async {
    final response = await _emitWithAck(
      event: 'call:answer',
      payload: {'callId': callId, 'answer': answer},
    );
    return response?['success'] == true;
  }

  Future<bool> sendIceCandidate({
    required String callId,
    required Map<String, dynamic> candidate,
  }) async {
    final response = await _emitWithAck(
      event: 'call:ice-candidate',
      payload: {'callId': callId, 'candidate': candidate},
    );
    return response?['success'] == true;
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

  Future<Map<String, dynamic>?> _emitWithAck({
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    final socket = _socket;
    if (socket == null) return null;

    final completer = Completer<Map<String, dynamic>?>();
    socket.emitWithAck(
      event,
      payload,
      ack: (response) {
        if (response is Map<String, dynamic>) {
          completer.complete(response);
          return;
        }
        if (response is Map) {
          completer.complete(
            response.map((key, value) => MapEntry(key.toString(), value)),
          );
          return;
        }
        completer.complete(null);
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => null,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return {};
  }

  CallTypeEntity _parseCallType(String? raw) {
    return raw == 'video' ? CallTypeEntity.video : CallTypeEntity.audio;
  }

  String _callTypeToRaw(CallTypeEntity value) {
    return value == CallTypeEntity.video ? 'video' : 'audio';
  }
}
