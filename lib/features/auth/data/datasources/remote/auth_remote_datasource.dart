import 'dart:io';

import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/services/storage/token_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      //save user session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fName: user.fname,
        lName: user.lname,
        username: user.username,
      );
      final token = response.data['token'];
      await _tokenService.saveToken(token);
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel?> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      data: user.toJson(),
    );

    if (response.data['succcess'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return user;
  }

  @override
  Future<AuthApiModel?> getCurrentUserById(String userId) async {
    final token = await _tokenService.getToken();
    final headers = {
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    // Empty userId means "current authenticated user".
    if (userId.trim().isEmpty) {
      final whoAmIResponse = await _apiClient.get(
        ApiEndpoints.whoAmI,
        options: Options(headers: headers),
      );
      if (whoAmIResponse.data['success'] == true) {
        final data = whoAmIResponse.data['data'] as Map<String, dynamic>;
        return AuthApiModel.fromJson(data);
      }
      return null;
    }

    // Explicit userId means target that user (used by search/profile view).
    final byIdResponse = await _apiClient.get(
      ApiEndpoints.getCurrentUserById(userId),
      options: Options(headers: headers),
    );
    if (byIdResponse.data['success'] == true) {
      final data = byIdResponse.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    final token = await _tokenService.getToken();
    final formData = FormData.fromMap({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim(),
      'email': email.trim(),
      'bio': (bio ?? '').trim(),
      if (profileImage != null)
        'profileUrl': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
      if (coverImage != null)
        'coverUrl': await MultipartFile.fromFile(
          coverImage.path,
          filename: coverImage.path.split('/').last,
        ),
    });

    final response = await _apiClient.put(
      ApiEndpoints.updateProfileImage,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    if (response.data['success'] == true && response.data['data'] != null) {
      return AuthApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }

    return null;
  }

  // @override
  // Future<String> coverImageUpload(File image) async {
  //   final fileName = image.path.split('/').last;
  //   final formData = FormData.fromMap({
  //     'coverUrl': MultipartFile.fromFileSync(image.path, filename: fileName),
  //   });

  //   //token
  //   final token = _tokenService.getToken();

  //   final response = await _apiClient.uploadFile(
  //     ApiEndpoints.coverImageUrl(fileName),
  //     formData: formData,
  //     options: Options(headers: {'Authorization': 'Bearer $token'}),
  //   );
  //   return response.data['success'];
  // }

  // @override
  // Future<String> profileImageUpload(File image) async {
  //   final fileName = image.path.split('/').last;
  //   final formData = FormData.fromMap({
  //     'profileUrl': MultipartFile.fromFileSync(image.path, filename: fileName),
  //   });

  //   final token = _tokenService.getToken();

  //   final response = await _apiClient.put(
  //     ApiEndpoints.profileImageUrl(fileName),
  //     data: formData,
  //     options: Options(
  //       headers: {'Authorization': 'Bearer $token'},
  //       contentType: 'multipart/form-data',
  //     ),
  //     // options: Options(contentType: 'multipart/form-data'),
  //   );
  // return response.data['success'];
  @override
  Future<String> profileImageUpload(File image) async {
    final token = await _tokenService.getToken();
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      'profileUrl': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.put(
      ApiEndpoints.updateProfileImage,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    // read safely from nested data
    final profileUrl = response.data['data']?['profileUrl'] as String?;

    if (profileUrl == null || profileUrl.isEmpty) {
      throw Exception("Profile upload failed or returned empty URL");
    }

    return profileUrl;
  }

  @override
  Future<String> coverImageUpload(File image) async {
    final token = await _tokenService.getToken();
    final fileName = image.path.split('/').last;

    final formData = FormData.fromMap({
      'coverUrl': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final response = await _apiClient.put(
      ApiEndpoints.updateProfileImage,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    // nullable because cover might be null
    final coverUrl = response.data['data']?['coverUrl'] as String?;

    if (coverUrl == null || coverUrl.isEmpty) {
      throw Exception("Cover upload failed or returned empty URL");
    }

    return coverUrl;
  }

  @override
  Future<void> sendResetPasswordEmail(String email) async {
    await _apiClient.post(
      ApiEndpoints.sendResetPasswordEmail,
      data: {"email": email, "platform": "mobile"},
    );
  }

  @override
  Future<void> verifyResetPasswordMobileCode({
    required String email,
    required String code,
  }) async {
    await _apiClient.post(
      ApiEndpoints.verifyResetPasswordMobileCode,
      data: {"email": email, "code": code},
    );
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword(token),
      data: {"newPassword": newPassword},
    );
  }

  @override
  Future<void> resetPasswordWithMobileCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPasswordMobileCode,
      data: {"email": email, "code": code, "newPassword": newPassword},
    );
  }

  @override
  Future<List<AuthApiModel>> searchUsers({
    String? search,
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.authUsers,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final rawUsers = response.data['data'] as List<dynamic>? ?? [];
    return rawUsers
        .map((item) => AuthApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
