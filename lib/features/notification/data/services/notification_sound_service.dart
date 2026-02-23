import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationSoundServiceProvider = Provider<NotificationSoundService>((
  ref,
) {
  final service = NotificationSoundService();
  ref.onDispose(service.dispose);
  return service;
});

class NotificationSoundService {
  static const String _asset = 'sounds/notification.mp3';

  final AudioPlayer _player = AudioPlayer(playerId: 'notification_sound');
  bool _ready = false;

  Future<void> play() async {
    try {
      if (!_ready) {
        await _player.setPlayerMode(PlayerMode.lowLatency);
        await _player.setReleaseMode(ReleaseMode.stop);
        _ready = true;
      }
      // Restart sound if notifications come quickly.
      await _player.stop();
      await _player.play(AssetSource(_asset), volume: 1.0);
    } catch (_) {
      // Keep silent fallback; UI should not fail on sound errors.
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
