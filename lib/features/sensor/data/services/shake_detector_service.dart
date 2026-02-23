import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// [thresholdG] controls shake sensitivity.
  /// 2.3 - 2.8 is a practical range for phones.
  void start({
    required void Function() onShake,
    double thresholdG = 2.35,
    Duration cooldown = const Duration(milliseconds: 1200),
  }) {
    stop();

    _sub = accelerometerEventStream().listen((event) {
      final gX = event.x / 9.80665;
      final gY = event.y / 9.80665;
      final gZ = event.z / 9.80665;
      final gForce = sqrt((gX * gX) + (gY * gY) + (gZ * gZ));

      if (gForce < thresholdG) return;

      final now = DateTime.now();
      if (now.difference(_lastShakeAt) < cooldown) return;
      _lastShakeAt = now;
      onShake();
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
