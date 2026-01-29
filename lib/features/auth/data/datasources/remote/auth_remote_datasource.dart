// import 'package:chautari_kurakani/core/api/api_client.dart';
// import 'package:chautari_kurakani/core/api/api_endpoints.dart';
// import 'package:chautari_kurakani/core/services/storage/token_service.dart';
// import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
// import 'package:chautari_kurakani/features/auth/data/models/auth_api_model.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // provider
// final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
//   return AuthRemoteDatasource(
//     apiClient: ref.read(apiClientProvider),
//     userSessionService: ref.read(userSessionServiceProvider),
//     tokenService: ref.read(tokenServiceProvider),
//   );
// });

// class AuthRemoteDatasource implements IAuthRemoteDatasource {
//   final ApiClient _apiClient;
//   final UserSessionService _userSessionService;
//   final TokenService _tokenService;

//   AuthRemoteDatasource({
//     required ApiClient apiClient,
//     required UserSessionService userSessionService,
//     required TokenService tokenService,
//   }) : _apiClient = apiClient,
//        _userSessionService = userSessionService,
//        _tokenService = tokenService;

//   @override
//   Future<AuthApiModel?> login(String email, String password) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.authLogin,
//       data: {'email': email, 'password': password},
//     );

//     if (response.data['success'] == true) {
//       final data = response.data['data'] as Map<String, dynamic>;
//       final user = AuthApiModel.fromJson(data);

//       //save user session
//       await _userSessionService.saveUserSession(
//         userId: user.id!,
//         email: user.email,
//         fName: user.fname,
//         lName: user.lname,
//         username: user.username,
//       );
//       final token = response.data['token'];
//       await _tokenService.saveToken(token);
//       return user;
//     }
//     return null;
//   }

//   @override
//   Future<AuthApiModel?> register(AuthApiModel user) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.authRegister,
//       data: user.toJson(),
//     );

//     if (response.data['succcess'] == true) {
//       final data = response.data['data'] as Map<String, dynamic>;
//       final registeredUser = AuthApiModel.fromJson(data);
//       return registeredUser;
//     }
//     return user;
//   }

//   @override
//   Future<AuthApiModel?> getCurrentUserById(String userId) async {
//     final token = await _tokenService.getToken();
//     final response = await _apiClient.get(
//       ApiEndpoints.getCurrentUserById(userId),
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );
//     if (response.data['success'] == true) {
//       final data = response.data['data'] as Map<String, dynamic>;
//       return AuthApiModel.fromJson(data);
//     }
//     return null;
//   }
// }
import 'dart:io';
import 'dart:ui';

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
    final response = await _apiClient.get(
      ApiEndpoints.getCurrentUserById(userId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
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
    return response.data['coverUrl'];
  }

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

    // Use backend response
    return response.data['profileUrl'];
  }
}
