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

// import 'dart:io';

// class ApiEndpoints {
//   ApiEndpoints._();

//   static String get baseUrl {
//     if (Platform.isAndroid) {
//       return 'http://10.0.2.2:6060/api';
//     } else if (Platform.isIOS) {
//       return 'http://localhost:6060/api';
//     }
//     return 'http://localhost:6060/api';
//   }

//   static const Duration connectionTimeout = Duration(seconds: 30);
//   static const Duration receiveTimeout = Duration(seconds: 30);

//   static const String authLogin = '/auth/login';
//   static const String authRegister = '/auth/register';
//   static const String whoAmI = '/auth/whoami';
//   static String getCurrentUserById(String userId) => "/auth/user/$userId";
//   // static const String profileImage = '/auth/user/update-profile';
//   static const String profileImage = '/auth/update-profile';
//   // static const String coverImage = '/auth/user/update-profile';
//   static const String coverImage = '/auth/update-profile';
// }

import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const int port = 6060;

  static const String computerIpAddress = "192.168.1.66";

  static String get baseUrl {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return "http://$computerIpAddress:$port/api";
    }

    // if (kIsWeb) {
    //   return "http://localhost:$port/api";
    // }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port/api";
    }

    if (Platform.isIOS) {
      return "http://localhost:$port/api";
    }

    return "http://localhost:$port/api";
  }

  /// Profile image URL
  static String profileImageUrl(String fileName) {
    if (fileName.startsWith('http')) return fileName;

    // if (isPhysicalDevice) {
    //   return "http://$computerIpAddress:$port/uploads/profile/$fileName";
    // }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port/uploads/profile/$fileName";
    }

    return "http://localhost:$port/uploads/profile/$fileName";
  }

  /// Cover image URL
  static String coverImageUrl(String fileName) {
    if (fileName.startsWith('http')) return fileName;

    // if (isPhysicalDevice) {
    //   return "http://$computerIpAddress:$port/uploads/cover/$fileName";
    // }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port/uploads/cover/$fileName";
    }

    return "http://localhost:$port/uploads/cover/$fileName";
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String whoAmI = '/auth/whoami';
  static String getCurrentUserById(String userId) => '/auth/user/$userId';

  // Profile picture upload
  static const String updateProfileImage = '/auth/update-profile';

  // Cover picture upload
  static const String updateCoverImage = '/auth/update-cover';
}
