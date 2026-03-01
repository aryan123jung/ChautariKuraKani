import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(prefs: ref.read(sharedPreferencesProvider));
});

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _biometricTokenKey = 'auth_token_biometric';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserIdKey = 'biometric_user_id';
  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  //Save token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> saveBiometricToken(String token) async {
    await _prefs.setString(_biometricTokenKey, token);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> saveBiometricUserId(String userId) async {
    await _prefs.setString(_biometricUserIdKey, userId);
  }

  Future<String?> getBiometricUserId() async {
    return _prefs.getString(_biometricUserIdKey);
  }

  //Get Token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<String?> getBiometricToken() async {
    return _prefs.getString(_biometricTokenKey);
  }

  //Remove token (for logout)
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> removeBiometricToken() async {
    await _prefs.remove(_biometricTokenKey);
    await _prefs.remove(_biometricUserIdKey);
  }
}
