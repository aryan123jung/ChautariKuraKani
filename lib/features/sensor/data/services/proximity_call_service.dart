import 'dart:async';
import 'dart:io';

import 'package:proximity_sensor/proximity_sensor.dart';

class ProximityCallService {
  StreamSubscription<dynamic>? _proximitySub;

  Future<bool> startForAudioCall({
    required void Function(bool isNearEar) onNearEarChanged,
    void Function(String message)? onDebug,
  }) async {
    stop();
    bool available = false;
    try {
      available = await ProximitySensor.isProximitySensorAvailable();
    } catch (_) {
      available = false;
    }
    onDebug?.call(
      'availability=$available platform=${Platform.operatingSystem}',
    );

    if (Platform.isAndroid) {
      // Recommended by plugin docs for Android screen-off behavior.
      try {
        await ProximitySensor.setProximityScreenOff(true);
        onDebug?.call('android screenOff enabled');
      } catch (_) {
        onDebug?.call('android screenOff enable failed');
      }
    } else if (!available) {
      // iOS: if unavailable, fail fast.
      onNearEarChanged(false);
      return false;
    }

    _proximitySub = ProximitySensor.events.listen(
      (event) {
        final isNearEar = _toNear(event);
        onDebug?.call('raw=$event near=$isNearEar');
        onNearEarChanged(isNearEar);
      },
      onError: (_) {
        onDebug?.call('stream error');
        onNearEarChanged(false);
      },
      cancelOnError: false,
    );
    onDebug?.call('listening started');
    // For Android, continue even when explicit availability check says false.
    return available || Platform.isAndroid;
  }

  void stop() {
    if (Platform.isAndroid) {
      ProximitySensor.setProximityScreenOff(false);
    }
    _proximitySub?.cancel();
    _proximitySub = null;
  }

  bool _toNear(dynamic event) {
    if (event is bool) return event;
    if (event is int) return event != 0;
    if (event is double) {
      // Some OEM/plugin combinations may emit distance values.
      if (event == 0) return true;
      if (event == 1) return true;
      return event <= 1.0;
    }
    final raw = event.toString().trim().toLowerCase();
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    final asNum = double.tryParse(raw);
    if (asNum == null) return false;
    if (asNum == 0) return true;
    if (asNum == 1) return true;
    return asNum <= 1.0;
  }
}
