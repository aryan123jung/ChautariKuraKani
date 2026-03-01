import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callRingtoneServiceProvider = Provider<CallRingtoneService>((ref) {
  final service = CallRingtoneService();
  ref.onDispose(service.dispose);
  return service;
});

class CallRingtoneService {
  static const String _incomingAsset = 'sounds/incoming-call.mp3';
  static const String _outgoingAsset = 'sounds/outgoing-call.mp3';

  final AudioPlayer _incomingPlayer = AudioPlayer(
    playerId: 'call_ringtone_incoming',
  );
  final AudioPlayer _outgoingPlayer = AudioPlayer(
    playerId: 'call_ringtone_outgoing',
  );

  bool _incomingPlaying = false;
  bool _outgoingPlaying = false;

  Future<void> playIncoming() async {
    if (_incomingPlaying) return;
    try {
      await stopOutgoing();
      await _incomingPlayer.setReleaseMode(ReleaseMode.loop);
      await _incomingPlayer
          .play(AssetSource(_incomingAsset))
          .timeout(const Duration(seconds: 4));
      _incomingPlaying = true;
    } catch (_) {
      _incomingPlaying = false;
    }
  }

  Future<void> playOutgoing() async {
    if (_outgoingPlaying) return;
    try {
      await stopIncoming();
      await _outgoingPlayer.setReleaseMode(ReleaseMode.loop);
      await _outgoingPlayer
          .play(AssetSource(_outgoingAsset))
          .timeout(const Duration(seconds: 4));
      _outgoingPlaying = true;
    } catch (_) {
      _outgoingPlaying = false;
    }
  }

  Future<void> stopIncoming() async {
    if (!_incomingPlaying) return;
    try {
      await _incomingPlayer.stop();
    } catch (_) {}
    _incomingPlaying = false;
  }

  Future<void> stopOutgoing() async {
    if (!_outgoingPlaying) return;
    try {
      await _outgoingPlayer.stop();
    } catch (_) {}
    _outgoingPlaying = false;
  }

  Future<void> stopAll() async {
    await stopIncoming();
    await stopOutgoing();
  }

  void dispose() {
    _incomingPlayer.dispose();
    _outgoingPlayer.dispose();
  }
}
