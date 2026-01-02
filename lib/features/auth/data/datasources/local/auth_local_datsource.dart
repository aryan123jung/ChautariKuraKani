// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
// import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// //Provider
// final authLocalDatsourceProvider = Provider<AuthLocalDatsource>((ref) {
//   final hiveService = ref.watch(hiveServiceProvider);
//   return AuthLocalDatsource(hiveService: hiveService);
// });

// class AuthLocalDatsource implements IAuthDatasource {
//   final HiveService _hiveService;

//   AuthLocalDatsource({required HiveService hiveService})
//     : _hiveService = hiveService;

//   @override
//   Future<AuthHiveModel> getCurrentUser() {
//     // TODO: implement getCurrentUser
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> isEmailExists(String email) {
//     try{
//       final exists = _hiveService.isEmailExists(email);
//       return Future.value(exists);
//     } catch(e){
//       return Future.value(false);
//     }
//   }

//   @override
//   Future<AuthHiveModel?> login(String email, String password) async {
//     try {
//       final user = await _hiveService.loginUser(email, password);
//       return Future.value(user);
//     } catch (e) {
//       return Future.value(null);
//     }
//   }

//   @override
//   Future<bool> logout() async {
//     try {
//       await _hiveService.logoutUser();
//       return Future.value(true);
//     } catch (e) {
//       return Future.value(false);
//     }
//   }

//   @override
//   Future<bool> register(AuthHiveModel model) async {
//     try {
//       await _hiveService.registerUser(model);
//       return Future.value(true);
//     } catch (e) {
//       return Future.value(false);
//     }
//   }
// }

import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDatsourceProvider = Provider<IAuthDatasource>((ref) {
  return AuthLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      if (_hiveService.isEmailExists(model.email)) {
        throw Exception('Email already exists');
      }

      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return true;
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final users = _hiveService.getAllAuths();
      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<bool> clearAllUserData() async {
    try {
      await _hiveService.deleteAllAuths();
      // yedi chaiyo bhani aaru deta halne
      // await _hiveService.deleteAllPosts();
      // await _hiveService.deleteAllComments();
      return true;
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }
}
