import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FaceIdAuthResult {
  final bool success;
  final String? message;

  const FaceIdAuthResult({required this.success, this.message});
}

class FaceIdAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<String?> getUnavailableReason() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    if (!canCheck || !isSupported) {
      return 'Biometric authentication not available';
    }

    final available = await _localAuth.getAvailableBiometrics();
    if (available.isEmpty) {
      return 'No biometrics enrolled. Add Face ID/Fingerprint in device settings.';
    }

    if (!available.contains(BiometricType.face)) {
      return 'Face ID is not available/enrolled on this iPhone.';
    }

    return null;
  }

  Future<FaceIdAuthResult> authenticateForLogin() async {
    try {
      final unavailable = await getUnavailableReason();
      if (unavailable != null) {
        return FaceIdAuthResult(success: false, message: unavailable);
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Use Face ID to login to ChautariKuraKani',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!authenticated) {
        return const FaceIdAuthResult(success: false);
      }

      return const FaceIdAuthResult(success: true);
    } on PlatformException catch (e) {
      return FaceIdAuthResult(
        success: false,
        message: _mapPlatformError(e.code),
      );
    } catch (_) {
      return const FaceIdAuthResult(
        success: false,
        message: 'Biometric login failed',
      );
    }
  }

  String _mapPlatformError(String code) {
    switch (code) {
      case 'NotAvailable':
        return 'Biometric hardware not available on this device';
      case 'NotEnrolled':
        return 'No biometrics enrolled. Please setup Face ID/Fingerprint';
      case 'LockedOut':
        return 'Biometric is temporarily locked. Try device passcode';
      case 'PermanentlyLockedOut':
        return 'Biometric locked. Unlock with device passcode in settings';
      default:
        return 'Biometric login failed';
    }
  }
}
