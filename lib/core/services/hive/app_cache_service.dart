import 'package:chautari_kurakani/core/constants/hive_table_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final appCacheServiceProvider = Provider<AppCacheService>((ref) {
  return AppCacheService();
});

class AppCacheService {
  Box<dynamic> get _box => Hive.box<dynamic>(HiveTableConstant.appCacheTable);

  T? read<T>({
    required String key,
    required T Function(dynamic raw) decoder,
    Duration? maxAge,
  }) {
    final raw = _box.get(key);
    if (raw is! Map) return null;

    final timestampRaw = raw['timestamp'];
    final data = raw['data'];
    final timestamp = timestampRaw is int
        ? timestampRaw
        : int.tryParse(timestampRaw?.toString() ?? '');

    if (maxAge != null && timestamp != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > maxAge.inMilliseconds) {
        return null;
      }
    }

    try {
      return decoder(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> write({required String key, required dynamic data}) async {
    await _box.put(key, {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clearByPrefix(String prefix) async {
    final keys = _box.keys.where((k) => k.toString().startsWith(prefix));
    await _box.deleteAll(keys);
  }
}
