import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  // Future<AuthHiveModel?> getCurrentUser();
  Future<bool> clearAllUserData();
  // get email exists
  Future<bool> isEmailExists(String email);
}
