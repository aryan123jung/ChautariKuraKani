import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_api_model.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

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
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
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
}
