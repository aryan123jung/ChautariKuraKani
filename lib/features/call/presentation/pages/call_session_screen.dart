import 'dart:async';
import 'dart:io';

import 'package:chautari_kurakani/features/call/data/services/call_socket_service.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:chautari_kurakani/features/call/presentation/view_model/call_view_model.dart';
import 'package:chautari_kurakani/features/sensor/data/services/proximity_call_service.dart';
import 'package:chautari_kurakani/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallSessionScreen extends ConsumerStatefulWidget {
  final String callId;
  final String title;
  final String subtitle;
  final CallTypeEntity callType;

  const CallSessionScreen({
    super.key,
    required this.callId,
    required this.title,
    required this.subtitle,
    required this.callType,
  });

  @override
  ConsumerState<CallSessionScreen> createState() => _CallSessionScreenState();
}

class _CallSessionScreenState extends ConsumerState<CallSessionScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peer;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  StreamSubscription<CallSocketEvent>? _signalSub;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _rtcReady = false;
  bool _offerSent = false;
  bool _remoteVideoReady = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isNearEar = false;
  bool _manualNearEarMode = false;
  bool _receivedProximityEvent = false;
  bool _proximitySupported = true;
  bool _didRequestClose = false;
  final ProximityCallService _proximityCallService = ProximityCallService();

  @override
  void initState() {
    super.initState();
    Future.microtask(_initRtc);
    if (widget.callType == CallTypeEntity.audio) {
      Future.microtask(() async {
        final enabled = await _proximityCallService.startForAudioCall(
          onNearEarChanged: (isNearEar) {
            if (!mounted) return;
            setState(() {
              _receivedProximityEvent = true;
              _isNearEar = isNearEar;
            });
          },
        );
        if (!mounted) return;
        setState(() {
          _proximitySupported = enabled;
        });
        if (!enabled || !Platform.isAndroid) return;
        Future.delayed(const Duration(seconds: 5), () {
          if (!mounted) return;
          if (_receivedProximityEvent) return;
          setState(() {
            _proximitySupported = false;
          });
        });
      });
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final call = ref.read(callViewModelProvider).activeCall;
      if (call?.callId != widget.callId) return;
      if (call?.status != CallStatusEntity.accepted) return;
      if (!mounted) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _signalSub?.cancel();
    _timer?.cancel();
    _proximityCallService.stop();
    _disposeRtc();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _initRtc() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    final config = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    final peer = await createPeerConnection(config);
    _peer = peer;

    peer.onIceCandidate = (candidate) {
      if (candidate.candidate == null || candidate.candidate!.isEmpty) return;
      ref
          .read(callViewModelProvider.notifier)
          .sendIceCandidate(
            callId: widget.callId,
            candidate: {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          );
    };

    peer.onTrack = (event) async {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
      } else {
        // Web peers can send onTrack with empty streams.
        _remoteStream ??= await createLocalMediaStream('remote');
        _remoteStream!.addTrack(event.track);
        _remoteRenderer.srcObject = _remoteStream;
      }
      if (!mounted) return;
      setState(() {
        _remoteVideoReady = true;
      });
    };

    final constraints = <String, dynamic>{
      'audio': true,
      'video': widget.callType == CallTypeEntity.video
          ? <String, dynamic>{'facingMode': 'user'}
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    if (_localStream != null) {
      await Helper.setSpeakerphoneOn(_isSpeakerOn);
      for (final track in _localStream!.getTracks()) {
        await peer.addTrack(track, _localStream!);
      }
      if (widget.callType == CallTypeEntity.video) {
        _localRenderer.srcObject = _localStream;
      }
    }

    _signalSub = ref.read(callViewModelProvider.notifier).signalStream.listen((
      event,
    ) async {
      if (event.callId != widget.callId) return;
      await _handleSignalEvent(event);
    });

    final pending = ref
        .read(callViewModelProvider.notifier)
        .drainPendingSignals(widget.callId);
    for (final event in pending) {
      await _handleSignalEvent(event);
    }

    if (!mounted) return;
    setState(() {
      _rtcReady = true;
    });
  }

  Future<void> _handleSignalEvent(CallSocketEvent event) async {
    final peer = _peer;
    if (peer == null) return;

    switch (event.type) {
      case CallSocketEventType.offer:
        final offer = _asMap(event.raw['offer']);
        final sdp = offer['sdp']?.toString();
        final type = offer['type']?.toString() ?? 'offer';
        if (sdp == null || sdp.isEmpty) return;

        await peer.setRemoteDescription(RTCSessionDescription(sdp, type));
        final answer = await peer.createAnswer();
        await peer.setLocalDescription(answer);
        await ref
            .read(callViewModelProvider.notifier)
            .sendAnswer(
              callId: widget.callId,
              answer: {'type': answer.type, 'sdp': answer.sdp},
            );
        break;
      case CallSocketEventType.answer:
        final answer = _asMap(event.raw['answer']);
        final sdp = answer['sdp']?.toString();
        final type = answer['type']?.toString() ?? 'answer';
        if (sdp == null || sdp.isEmpty) return;
        await peer.setRemoteDescription(RTCSessionDescription(sdp, type));
        break;
      case CallSocketEventType.iceCandidate:
        final candidate = _asMap(event.raw['candidate']);
        final c = candidate['candidate']?.toString();
        if (c == null || c.isEmpty) return;
        final mLineIndexRaw = candidate['sdpMLineIndex'];
        final mLineIndex = mLineIndexRaw is int
            ? mLineIndexRaw
            : int.tryParse(mLineIndexRaw?.toString() ?? '');
        await peer.addCandidate(
          RTCIceCandidate(c, candidate['sdpMid']?.toString(), mLineIndex),
        );
        break;
      case CallSocketEventType.incoming:
      case CallSocketEventType.ringing:
      case CallSocketEventType.accepted:
      case CallSocketEventType.rejected:
      case CallSocketEventType.missed:
      case CallSocketEventType.ended:
        break;
    }
  }

  Future<void> _createOfferIfNeeded(ActiveCallEntity? call) async {
    if (!_rtcReady || _offerSent || call == null) return;
    if (call.callId != widget.callId) return;
    if (call.status != CallStatusEntity.accepted) return;
    if (call.isIncoming) return;

    final peer = _peer;
    if (peer == null) return;

    final offer = await peer.createOffer();
    await peer.setLocalDescription(offer);
    final sent = await ref
        .read(callViewModelProvider.notifier)
        .sendOffer(
          callId: widget.callId,
          offer: {'type': offer.type, 'sdp': offer.sdp},
        );
    if (!mounted) return;
    if (sent) {
      setState(() {
        _offerSent = true;
      });
    }
  }

  Future<void> _disposeRtc() async {
    try {
      await _peer?.close();
    } catch (_) {}
    try {
      await _localStream?.dispose();
    } catch (_) {}
    try {
      await _remoteStream?.dispose();
    } catch (_) {}
    _peer = null;
    _localStream = null;
    _remoteStream = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callViewModelProvider);
    final call = state.activeCall;

    if (call == null || call.callId != widget.callId) {
      if (!_didRequestClose) {
        _didRequestClose = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).maybePop();
        });
      }
    } else {
      _didRequestClose = false;
      _createOfferIfNeeded(call);
    }

    final statusText = switch (call?.status) {
      CallStatusEntity.accepted => _formatDuration(_elapsed),
      CallStatusEntity.ringing => 'Ringing...',
      CallStatusEntity.rejected => 'Call rejected',
      CallStatusEntity.missed => 'Missed call',
      CallStatusEntity.ended => 'Call ended',
      null => 'Connecting...',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await ref.read(callViewModelProvider.notifier).endCall(widget.callId);
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E1116),
        body: widget.callType == CallTypeEntity.video
            ? _buildVideoBody(statusText)
            : Stack(
                children: [
                  _buildAudioBody(statusText),
                  if (_isNearEar || _manualNearEarMode)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: false,
                        child: Container(color: Colors.black),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildVideoBody(String statusText) {
    return Stack(
      children: [
        Positioned.fill(
          child: _remoteVideoReady
              ? RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.scale(10),
              context.scale(8),
              context.scale(10),
              context.scale(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await ref
                            .read(callViewModelProvider.notifier)
                            .endCall(widget.callId);
                        if (!mounted) return;
                        navigator.pop();
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: context.scale(32),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scale(8)),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.fs(26),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.scale(4)),
                Text(
                  '${widget.subtitle} • $statusText',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.fs(15),
                  ),
                ),
                const Spacer(),
                if (_remoteVideoReady)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: context.scale(context.isSmallPhone ? 98 : 118),
                      height: context.scale(context.isSmallPhone ? 148 : 178),
                      margin: EdgeInsets.only(
                        right: context.scale(8),
                        bottom: context.scale(14),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.scale(14)),
                        border: Border.all(color: Colors.white, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: context.scale(14),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                SizedBox(height: context.scale(8)),
                _buildControls(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBody(String statusText) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.scale(24),
          context.scale(20),
          context.scale(24),
          context.scale(28),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await ref
                      .read(callViewModelProvider.notifier)
                      .endCall(widget.callId);
                  if (!mounted) return;
                  navigator.pop();
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ),
            // Keep remote renderer mounted so audio-only remote track is rendered.
            SizedBox(
              width: 1,
              height: 1,
              child: Opacity(opacity: 0, child: RTCVideoView(_remoteRenderer)),
            ),
            SizedBox(height: context.scale(36)),
            CircleAvatar(
              radius: context.scale(54),
              backgroundColor: const Color(0XFF76C05D).withValues(alpha: 0.25),
              child: Icon(
                Icons.call,
                size: context.scale(46),
                color: Colors.white,
              ),
            ),
            SizedBox(height: context.scale(24)),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.fs(28),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: context.fs(15)),
            ),
            SizedBox(height: context.scale(12)),
            Text(
              statusText,
              style: TextStyle(
                color: Colors.white70,
                fontSize: context.fs(16),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CallActionButton(
              icon: _isSpeakerOn
                  ? Icons.volume_up_rounded
                  : Icons.hearing_rounded,
              label: _isSpeakerOn ? 'Speaker 🔊' : 'Earpiece 👂',
              color: Colors.white24,
              onTap: () async {
                final next = !_isSpeakerOn;
                await Helper.setSpeakerphoneOn(next);
                if (!mounted) return;
                setState(() {
                  _isSpeakerOn = next;
                });
              },
            ),
            _CallActionButton(
              icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _isMuted ? 'Muted 🤫' : 'Mute 🎤',
              color: Colors.white24,
              onTap: () {
                final stream = _localStream;
                if (stream == null) return;
                final audioTracks = stream.getAudioTracks();
                if (audioTracks.isEmpty) return;
                final track = audioTracks.first;
                track.enabled = !track.enabled;
                if (!mounted) return;
                setState(() {
                  _isMuted = !track.enabled;
                });
              },
            ),
            if (widget.callType == CallTypeEntity.audio && !_proximitySupported)
              _CallActionButton(
                icon: _manualNearEarMode
                    ? Icons.phone_disabled_rounded
                    : Icons.phone_in_talk_rounded,
                label: _manualNearEarMode ? 'Ear Mode On' : 'Ear Mode',
                color: Colors.white24,
                onTap: () {
                  if (!mounted) return;
                  setState(() {
                    _manualNearEarMode = !_manualNearEarMode;
                  });
                },
              ),
          ],
        ),
        SizedBox(height: context.scale(28)),
        _CallActionButton(
          icon: Icons.call_end,
          label: 'End',
          color: Colors.redAccent,
          large: true,
          onTap: () async {
            final navigator = Navigator.of(context);
            await ref
                .read(callViewModelProvider.notifier)
                .endCall(widget.callId);
            if (!mounted) return;
            navigator.pop();
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration value) {
    final m = value.inMinutes.toString().padLeft(2, '0');
    final s = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return {};
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool large;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: context.scale(large ? 72 : 56),
            height: context.scale(large ? 72 : 56),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              icon,
              color: Colors.white,
              size: context.scale(large ? 34 : 24),
            ),
          ),
          SizedBox(height: context.scale(8)),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: context.fs(13)),
          ),
        ],
      ),
    );
  }
}
