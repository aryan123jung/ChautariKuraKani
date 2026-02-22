import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const int port = 6060;

  static const String computerIpAddress = "192.168.1.86";

  // static String get baseUrl {
  //   if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //     return "http://$computerIpAddress:$port/api";
  //   }

  //   // if (kIsWeb) {
  //   //   return "http://localhost:$port/api";
  //   // }

  //   if (Platform.isAndroid) {
  //     return "http://10.0.2.2:$port/api";
  //   }

  //   if (Platform.isIOS) {
  //     return "http://localhost:$port/api";
  //   }

  //   return "http://localhost:$port/api";
  // }
  static String get baseUrl {
    // Web
    if (kIsWeb) {
      return "http://localhost:$port/api";
    }

    // Android Emulator
    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port/api";
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://localhost:$port/api";
      // return "http://$computerIpAddress:$port/api";
    }

    // Physical device fallback
    return "http://$computerIpAddress:$port/api";
  }

  static String get uploadBaseUrl {
    if (kIsWeb) {
      return "http://localhost:$port";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:$port";
    }
    if (Platform.isIOS) {
      return "http://localhost:$port";
    }
    return "http://$computerIpAddress:$port";
  }

  static String uploadUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    final normalized = relativePath.replaceAll('\\', '/').trim();
    final cleaned = normalized.startsWith('/')
        ? normalized.substring(1)
        : normalized;
    return "$uploadBaseUrl/$cleaned";
  }

  /// Profile image URL
  static String profileImageUrl(String fileName) {
    if (fileName.startsWith('http')) return fileName;
    if (fileName.contains('/') || fileName.contains('\\')) {
      return uploadUrl(fileName);
    }

    // if (isPhysicalDevice) {
    //   return "http://$computerIpAddress:$port/uploads/profile/$fileName";
    // }

    return uploadUrl("uploads/profile/$fileName");
  }

  /// Cover image URL
  static String coverImageUrl(String fileName) {
    if (fileName.startsWith('http')) return fileName;
    if (fileName.contains('/') || fileName.contains('\\')) {
      return uploadUrl(fileName);
    }

    // if (isPhysicalDevice) {
    //   return "http://$computerIpAddress:$port/uploads/cover/$fileName";
    // }

    return uploadUrl("uploads/cover/$fileName");
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authUsers = '/auth/users';
  static const String whoAmI = '/auth/whoami';
  static String getCurrentUserById(String userId) => '/auth/user/$userId';

  static const String sendResetPasswordEmail =
      "/auth/send-reset-password-email";

  static String resetPassword(String token) => "/auth/reset-password/$token";

  // Profile picture upload
  static const String updateProfileImage = '/auth/update-profile';

  // Cover picture upload
  static const String updateCoverImage = '/auth/update-cover';

  // Posts
  static const String posts = '/post';
  static String likePost(String id) => '/post/$id/like';
  static String postComments(String id) => '/post/$id/comments';
  static String deletePostComment(String postId, String commentId) =>
      '/post/$postId/comments/$commentId';

  static String postMediaUrl(String fileName, String mediaType) {
    if (fileName.startsWith('http')) return fileName;
    if (fileName.contains('/') || fileName.contains('\\')) {
      return uploadUrl(fileName);
    }

    final String folder = mediaType == 'video' ? 'videos' : 'images';
    return uploadUrl("uploads/posts/$folder/$fileName");
  }
}
