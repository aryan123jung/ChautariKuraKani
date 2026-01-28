// import 'package:chautari_kurakani/core/constants/hive_table_constant.dart';
// import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';

// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });

// class HiveService {
//   //Initialize hive
//   Future<void> init() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/${HiveTableConstant.dbName}';
//     Hive.init(path);
//     _registerAdapters();
//     await _openBoxes();
//   }

//   // Register all type adapters
//   void _registerAdapters() {
//     if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
//       Hive.registerAdapter(AuthHiveModelAdapter());
//     }
//   }

//   //Open all boxes
//   Future<void> _openBoxes() async {
//     await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
//   }

//   // Delete all auths
//   Future<void> deleteAllAuths() async {
//     await _authBox.clear();
//   }

//   // Close all boxes
//   Future<void> close() async {
//     await Hive.close();
//   }

//   // ==================== Auth Queries ====================

//   // Get auth box
//   Box<AuthHiveModel> get _authBox =>
//       Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

//   // Register
//   Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
//     await _authBox.put(model.authId, model);
//     return model;
//   }

//   //Login
//   Future<AuthHiveModel?> loginUser(String email, String password) async {
//     final users = _authBox.values.where(
//       (user) => user.email == email && user.password == password,
//     );
//     if (users.isNotEmpty) {
//       return users.first;
//     }
//     return null;
//   }

//   //Logout
//   // Future<void> logoutUser() async {
//   //   // Just return, don't clear the database
//   //   // Users should persist after logout
//   //   return;
//   // }

//   // Get all auth
//   List<AuthHiveModel> getAllAuths() {
//     return _authBox.values.toList();
//   }

//   //Get current user
//   AuthHiveModel? getCurrentUser(String authId) {
//     return _authBox.get(authId);
//   }

//   // Is email exists
//   bool isEmailExists(String email) {
//     final users = _authBox.values.where((user) => user.email == email);
//     return users.isNotEmpty;
//   }

//   // // Get auth by ID
//   // AuthHiveModel? getAuthById(String authId) {
//   //   return _authBox.get(authId);
//   // }

//   // // Update a auth
//   // Future<void> updateAuth(AuthHiveModel auth) async {
//   //   await _authBox.put(auth.authId, auth);
//   // }

//   // // Delete a auth
//   // Future<void> deleteAuth(String authId) async {
//   //   await _authBox.delete(authId);
//   // }
// }

// import 'package:chautari_kurakani/core/constants/hive_table_constant.dart';
// import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';

// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });

// class HiveService {
//   //Initialize hive
//   Future<void> init() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/${HiveTableConstant.dbName}';
//     Hive.init(path);
//     _registerAdapters();
//     await _openBoxes();
//   }

//   // Register all type adapters
//   void _registerAdapters() {
//     if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
//       Hive.registerAdapter(AuthHiveModelAdapter());
//     }
//   }

//   //Open all boxes
//   Future<void> _openBoxes() async {
//     await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
//   }

//   // Delete all auths
//   Future<void> deleteAllAuths() async {
//     await _authBox.clear();
//   }

//   // Close all boxes
//   Future<void> close() async {
//     await Hive.close();
//   }

//   // ==================== Auth Queries ====================

//   // Get auth box
//   Box<AuthHiveModel> get _authBox =>
//       Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

//   // Register
//   Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
//     await _authBox.put(model.authId, model);
//     return model;
//   }

//   //Login
//   Future<AuthHiveModel?> loginUser(String email, String password) async {
//     final users = _authBox.values.where(
//       (user) => user.email == email && user.password == password,
//     );
//     if (users.isNotEmpty) {
//       return users.first;
//     }
//     return null;
//   }

//   //Logout
//   Future<void> logoutUser() async {
//     // await _authBox.delete(authId);
//   }

//   // Get all auth
//   List<AuthHiveModel> getAllAuths() {
//     return _authBox.values.toList();
//   }

//   //Get current user
//   AuthHiveModel? getCurrentUser(String authId) {
//     return _authBox.get(authId);
//   }

//   // Is email exists
//   bool isEmailExists(String email) {
//     final users = _authBox.values.where((user) => user.email == email);
//     return users.isNotEmpty;
//   }

//   // // Get auth by ID
//   // AuthHiveModel? getAuthById(String authId) {
//   //   return _authBox.get(authId);
//   // }

//   // // Update a auth
//   // Future<void> updateAuth(AuthHiveModel auth) async {
//   //   await _authBox.put(auth.authId, auth);
//   // }

//   // // Delete a auth
//   // Future<void> deleteAuth(String authId) async {
//   //   await _authBox.delete(authId);
//   // }
// }

import 'package:chautari_kurakani/core/constants/hive_table_constant.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // ==================== Auth Queries ====================

  // Future<AuthHiveModel> register(AuthHiveModel model) async {
  //   // try {
  //   //   await _authBox.put(model.authId, model);
  //   //   return model;
  //   // } catch (e) {
  //   //   throw Exception('Failed to register user: $e');
  //   // }
  //   await _authBox.put(model.authId, model);
  //   return model;
  // }

  // Future<AuthHiveModel?> login(String email, String password) async {
  //   try {
  //     final users = _authBox.values.where(
  //       (user) => user.email == email && user.password == password,
  //     );
  //     if (users.isNotEmpty) {
  //       return users.first;
  //     }
  //     return null;
  //   } catch (e) {
  //     throw Exception('Failed to login: $e');
  //   }
  // }

  //  AuthHiveModel? getUserById(String authId) {
  //   return _authBox.get(authId);
  // }

  // // Future<void> logoutUser() async {
  // //   try {
  // //     await _authBox.clear();
  // //   } catch (e) {
  // //     throw Exception('Logout failed: $e');
  // //   }
  // // }

  // // Future<void> deleteAllAuths() async {
  // //   try {
  // //     await _authBox.clear();
  // //   } catch (e) {
  // //     throw Exception('Failed to delete all auths: $e');
  // //   }
  // // }
  // Future<void> deleteUser(String authId) async {
  //   await _authBox.delete(authId);
  // }

  // List<AuthHiveModel> getAllAuths() {
  //   try {
  //     return _authBox.values.toList();
  //   } catch (e) {
  //     throw Exception('Failed to get all auths: $e');
  //   }
  // }

  // AuthHiveModel? getCurrentUser(String authId) {
  //   try {
  //     return _authBox.get(authId);
  //   } catch (e) {
  //     throw Exception('Failed to get current user: $e');
  //   }
  // }

  // bool isEmailExists(String email) {
  //   try {
  //     final users = _authBox.values.where((user) => user.email == email);
  //     return users.isNotEmpty;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Future<void> close() async {
  //   await Hive.close();
  // }
  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

}
