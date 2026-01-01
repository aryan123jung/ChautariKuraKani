import 'package:chautari_kurakani/core/constants/hive_table_constant.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  //Initialize hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  // Register all type adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    // if (!Hive.isAdapterRegistered(HiveTableConstant.categoryTypeId)) {
    //   Hive.registerAdapter(AuthHiveModelAdapter());
  }
}

//Open all boxes
Future<void> _openBoxes() async {
  await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

  // await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoryTable);
}

// Delete all auths
Future<void> deleteAllAuths() async {
  await _authBox.clear();

  // await _categoryBox.clear();
}

// Close all boxes
Future<void> close() async {
  await Hive.close();
}

// ==================== Auth Queries ====================

// Get auth box
Box<AuthHiveModel> get _authBox =>
    Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

// Register
Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
  await _authBox.put(model.authId, model);
  return model;
}

//Login
Future<AuthHiveModel?> loginUser(String email, String password) async {
  final users = _authBox.values.where(
    (user) => user.email == email && user.password == password,
  );
  if (users.isNotEmpty) {
    return users.first;
  }
  return null;
}

//Logout
Future<void> logoutUser(String authId) async {
  await _authBox.delete(authId);
}

// Get all auth
List<AuthHiveModel> getAllAuths() {
  return _authBox.values.toList();
}

//Get current user
AuthHiveModel? getCurrentUser(String authId) {
  return _authBox.get(authId);
}

// // Get auth by ID
// AuthHiveModel? getAuthById(String authId) {
//   return _authBox.get(authId);
// }

// // Update a auth
// Future<void> updateAuth(AuthHiveModel auth) async {
//   await _authBox.put(auth.authId, auth);
// }

// // Delete a auth
// Future<void> deleteAuth(String authId) async {
//   await _authBox.delete(authId);
// }
