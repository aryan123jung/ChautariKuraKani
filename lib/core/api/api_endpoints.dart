// class ApiEndpoints {
//   ApiEndpoints._();

//   // Base URL
//   static const String baseUrl = 'http://10.0.2.2:3000/api'; //andriod emulator
//   // static const String baseUrl = 'http://localhost:6060/api'; //ios simulator

//   static const Duration connectionTimeout = Duration(seconds: 30);
//   static const Duration receiveTimeout = Duration(seconds: 30);

//   static const String auth = '/auth';
//   static const String authLogin = '/auth/login';
//   static const String authRegister = '/auth/register';
// }
import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:6060/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:6060/api';
    }
    return 'http://localhost:6060/api';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String whoAmI = '/auth/whoami';
  static String getCurrentUserById(String userId) => "/auth/user/$userId";
}
