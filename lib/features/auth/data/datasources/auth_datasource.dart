import 'dart:io';

import 'package:chautari_kurakani/features/auth/data/models/auth_api_model.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  // Future<bool> register(AuthHiveModel model);
  // Future<AuthHiveModel?> login(String email, String password);
  // Future<AuthHiveModel?> getCurrentUser();
  // Future<bool> logout();
  // // Future<AuthHiveModel?> getCurrentUser();
  // Future<bool> clearAllUserData();
  // // Future<AuthHiveModel?> getUserById(String authId);
  // // Future<AuthHiveModel?> getUserByEmail(String email);
  // // get email exists
  // Future<bool> isEmailExists(String email);
  Future<AuthHiveModel?> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel?> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getCurrentUserById(String userId);
  Future<AuthApiModel?> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? bio,
    File? profileImage,
    File? coverImage,
  });
  Future<String> profileImageUpload(File image);
  Future<String> coverImageUpload(File image);

  Future<void> sendResetPasswordEmail(String email);
  Future<void> verifyResetPasswordMobileCode({
    required String email,
    required String code,
  });
  Future<void> resetPassword(String token, String newPassword);
  Future<void> resetPasswordWithMobileCode({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<List<AuthApiModel>> searchUsers({
    String? search,
    int page = 1,
    int size = 10,
  });
}
