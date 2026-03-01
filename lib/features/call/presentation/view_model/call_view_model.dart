import 'dart:async';

import 'package:chautari_kurakani/features/call/data/services/call_ringtone_service.dart';
import 'package:chautari_kurakani/features/call/data/services/call_socket_service.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:chautari_kurakani/features/call/domain/usecases/call_usecases.dart';
import 'package:chautari_kurakani/features/call/presentation/state/call_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callViewModelProvider = NotifierProvider<CallViewModel, CallState>(
  CallViewModel.new,
);

class CallViewModel extends Notifier<CallState> {
  late final ListMyCallsUsecase _listMyCallsUsecase;
  late final CallSocketService _socketService;
  late final CallRingtoneService _ringtoneService;
  StreamSubscription<CallSocketEvent>? _socketSub;
  final _signalController = StreamController<CallSocketEvent>.broadcast();
  final Map<String, List<CallSocketEvent>> _pendingSignalsByCall = {};
  String _currentUserId = '';

  @override
  CallState build() {
    _listMyCallsUsecase = ref.read(listMyCallsUsecaseProvider);
    _socketService = ref.read(callSocketServiceProvider);
    _ringtoneService = ref.read(callRingtoneServiceProvider);

    ref.onDispose(() {
      _socketSub?.cancel();
      unawaited(_ringtoneService.stopAll());
      _signalController.close();
      _socketService.disconnect();
    });

    return const CallState.initial();
  }

  void setCurrentUserId(String? userId) {
    _currentUserId = (userId ?? '').trim();
  }

  Future<void> connectRealtime() async {
    await _socketService.connect();
    await _socketSub?.cancel();
    _socketSub = _socketService.stream.listen(_onSocketEvent);
  }

  void disconnectRealtime() {
    _socketSub?.cancel();
    _socketSub = null;
    _socketService.disconnect();
  }

  Future<void> loadCallHistory({
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh || state.callHistory.isEmpty) {
      state = state.copyWith(status: CallUiStatus.loading, errorMessage: null);
    }
    final result = await _listMyCallsUsecase(
      ListMyCallsParams(page: page, size: size, bypassCache: forceRefresh),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: CallUiStatus.error,
          errorMessage: failure.message,
        );
      },
      (calls) {
        state = state.copyWith(
          status: CallUiStatus.loaded,
          callHistory: calls,
          errorMessage: null,
        );
      },
    );
  }

  Future<String?> initiateCall({
    required String calleeId,
    required CallTypeEntity callType,
  }) async {
    final normalizedCallee = calleeId.trim();
    if (normalizedCallee.isEmpty) return null;

    if (_currentUserId.isNotEmpty &&
        _currentUserId.toLowerCase() == normalizedCallee.toLowerCase()) {
      state = state.copyWith(
        status: CallUiStatus.error,
        errorMessage: 'You cannot call yourself',
      );
      return null;
    }

    state = state.copyWith(status: CallUiStatus.submitting, errorMessage: null);
    final callId = await _socketService.initiateCall(
      calleeId: calleeId,
      callType: callType,
    );

    if (callId == null || callId.trim().isEmpty) {
      unawaited(_ringtoneService.stopAll());
      state = state.copyWith(
        status: CallUiStatus.error,
        errorMessage:
            _socketService.lastErrorMessage ?? 'Failed to initiate call',
      );
      return null;
    }

    unawaited(_ringtoneService.playOutgoing());
    state = state.copyWith(
      status: CallUiStatus.loaded,
      activeCall: ActiveCallEntity(
        callId: callId,
        callerId: _currentUserId,
        calleeId: normalizedCallee,
        callType: callType,
        status: CallStatusEntity.ringing,
        isIncoming: false,
      ),
      errorMessage: null,
    );
    return callId;
  }

  Future<bool> acceptCall(String callId) async {
    unawaited(_ringtoneService.stopAll());
    final ok = await _socketService.acceptCall(callId);
    if (!ok) {
      state = state.copyWith(
        status: CallUiStatus.error,
        errorMessage: 'Failed to accept call',
      );
      return false;
    }

    if (state.incomingCall?.callId == callId) {
      state = state.copyWith(
        status: CallUiStatus.loaded,
        activeCall: state.incomingCall?.copyWith(
          status: CallStatusEntity.accepted,
        ),
        clearIncomingCall: true,
      );
    }

    return true;
  }

  Future<bool> rejectCall(String callId) async {
    unawaited(_ringtoneService.stopAll());
    final ok = await _socketService.rejectCall(callId);
    if (!ok) {
      state = state.copyWith(
        status: CallUiStatus.error,
        errorMessage: 'Failed to reject call',
      );
      return false;
    }

    if (state.incomingCall?.callId == callId) {
      state = state.copyWith(clearIncomingCall: true, clearActiveCall: true);
    }
    return true;
  }

  Future<bool> endCall(String callId) async {
    unawaited(_ringtoneService.stopAll());
    final ok = await _socketService.endCall(callId);
    if (!ok) {
      state = state.copyWith(
        status: CallUiStatus.error,
        errorMessage: 'Failed to end call',
      );
      return false;
    }

    if (state.activeCall?.callId == callId) {
      state = state.copyWith(clearActiveCall: true);
    }
    return true;
  }

  Stream<CallSocketEvent> get signalStream => _signalController.stream;

  List<CallSocketEvent> drainPendingSignals(String callId) {
    final key = callId.trim();
    if (key.isEmpty) return const [];
    final events = _pendingSignalsByCall[key] ?? const [];
    _pendingSignalsByCall.remove(key);
    return List<CallSocketEvent>.from(events);
  }

  Future<bool> sendOffer({
    required String callId,
    required Map<String, dynamic> offer,
  }) {
    return _socketService.sendOffer(callId: callId, offer: offer);
  }

  Future<bool> sendAnswer({
    required String callId,
    required Map<String, dynamic> answer,
  }) {
    return _socketService.sendAnswer(callId: callId, answer: answer);
  }

  Future<bool> sendIceCandidate({
    required String callId,
    required Map<String, dynamic> candidate,
  }) {
    return _socketService.sendIceCandidate(
      callId: callId,
      candidate: candidate,
    );
  }

  void clearIncomingCall() {
    state = state.copyWith(clearIncomingCall: true);
  }

  void _onSocketEvent(CallSocketEvent event) {
    final callId = event.callId.trim();
    if (callId.isEmpty) return;

    switch (event.type) {
      case CallSocketEventType.incoming:
        unawaited(_ringtoneService.playIncoming());
        final call = ActiveCallEntity(
          callId: callId,
          callerId: (event.callerId ?? '').trim().toLowerCase(),
          calleeId: (event.calleeId ?? '').trim().toLowerCase(),
          callType: event.callType ?? CallTypeEntity.audio,
          status: CallStatusEntity.ringing,
          isIncoming: true,
        );
        state = state.copyWith(
          status: CallUiStatus.loaded,
          incomingCall: call,
          activeCall: call,
          errorMessage: null,
        );
        break;
      case CallSocketEventType.ringing:
        if (state.activeCall?.callId == callId &&
            state.activeCall?.isIncoming == false) {
          unawaited(_ringtoneService.playOutgoing());
        }
        if (state.activeCall?.callId == callId) {
          state = state.copyWith(
            status: CallUiStatus.loaded,
            activeCall: state.activeCall?.copyWith(
              status: CallStatusEntity.ringing,
            ),
            errorMessage: null,
          );
        }
        break;
      case CallSocketEventType.accepted:
        unawaited(_ringtoneService.stopAll());
        if (state.activeCall?.callId == callId) {
          state = state.copyWith(
            status: CallUiStatus.loaded,
            activeCall: state.activeCall?.copyWith(
              status: CallStatusEntity.accepted,
            ),
            clearIncomingCall: true,
            errorMessage: null,
          );
        }
        break;
      case CallSocketEventType.rejected:
        unawaited(_ringtoneService.stopAll());
        if (_matchesCurrentCall(callId)) {
          state = state.copyWith(
            status: CallUiStatus.loaded,
            clearIncomingCall: true,
            clearActiveCall: true,
            errorMessage: null,
          );
        }
        break;
      case CallSocketEventType.missed:
        unawaited(_ringtoneService.stopAll());
        if (_matchesCurrentCall(callId)) {
          state = state.copyWith(
            status: CallUiStatus.loaded,
            clearIncomingCall: true,
            clearActiveCall: true,
            errorMessage: null,
          );
        }
        break;
      case CallSocketEventType.ended:
        unawaited(_ringtoneService.stopAll());
        if (_matchesCurrentCall(callId)) {
          state = state.copyWith(
            status: CallUiStatus.loaded,
            clearIncomingCall: true,
            clearActiveCall: true,
            errorMessage: null,
          );
        }
        break;
      case CallSocketEventType.offer:
      case CallSocketEventType.answer:
      case CallSocketEventType.iceCandidate:
        final key = event.callId.trim();
        if (key.isNotEmpty) {
          final list = _pendingSignalsByCall[key] ?? <CallSocketEvent>[];
          list.add(event);
          _pendingSignalsByCall[key] = list;
        }
        _signalController.add(event);
        break;
    }
  }

  bool _matchesCurrentCall(String callId) {
    return state.activeCall?.callId == callId ||
        state.incomingCall?.callId == callId;
  }
}
