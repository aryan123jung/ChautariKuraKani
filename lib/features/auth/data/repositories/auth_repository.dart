import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/local/auth_local_datsource.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_api_model.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  // return AuthRepository(authDatasource: ref.read(authLocalDatsourceProvider));
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authLocalDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUserById(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDatasource.getCurrentUserById(userId);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return Left(ApiFailure(message: 'No user found'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to get user',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authDatasource.getCurrentUser();
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return Left(LocalDatabaseFailure(message: 'No user logged in'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDatasource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: 'Invalid email or password'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authDatasource.login(email, password);
        if (user != null) {
          final entity = user.toEntity();
          return Right(entity);
        }
        return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        final result = await _authRemoteDatasource.register(apiModel);
        if (result == null) {
          return const Left(ApiFailure(message: 'Registration failed'));
        }
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingUser = await _authDatasource.getUserByEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: 'Email already exists'),
          );
        }

        final authModel = AuthHiveModel(
          fName: user.fName,
          lName: user.lName,
          email: user.email,
          username: user.username,
          password: user.password,
          profilePicture: user.profilePicture,
          coverPicture: user.coverPicture,
          bio: user.bio,
        );
        final result = await _authDatasource.register(authModel);
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(message: 'Registration failed'),
          );
        }
        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> coverImageUpload(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _authRemoteDatasource.coverImageUpload(image);
        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, String>> profileImageUpload(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _authRemoteDatasource.profileImageUpload(image);
        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: "No internet connection"));
    }
  }

  // @override
  // Future<Either<Failure, bool>> clearAllUserData() async {
  //   try {
  //     final result = await _authDatasource.clearAllUserData();
  //     if (result) {
  //       return const Right(true);
  //     }
  //     return Left(LocalDatabaseFailure(message: 'Failed to clear user data'));
  //   } catch (e) {
  //     return Left(LocalDatabaseFailure(message: e.toString()));
  //   }
  // }
}

// import 'package:chautari_kurakani/core/error/failures.dart';
// import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
// import 'package:chautari_kurakani/core/services/storage/token_service.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/local/auth_local_datsource.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/remote/auth_remote_datasource.dart';
// import 'package:chautari_kurakani/features/auth/data/models/auth_api_model.dart';
// // import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Provider
// final authRepositoryProvider = Provider<IAuthRepository>((ref) {
//   return AuthRepository(
//     authLocalDatasource: ref.read(authLocalDatasourceProvider),
//     authRemoteDatasource: ref.read(authRemoteDatasourceProvider),
//     networkInfo: ref.read(networkInfoProvider),
//     tokenService: ref.read(tokenServiceProvider),
//   );
// });

// class AuthRepository implements IAuthRepository {
//   final IAuthLocalDatasource _authLocalDatasource;
//   final IAuthRemoteDatasource _authRemoteDatasource;
//   final NetworkInfo _networkInfo;
//   final TokenService _tokenService;

//   AuthRepository({
//     required IAuthLocalDatasource authLocalDatasource,
//     required IAuthRemoteDatasource authRemoteDatasource,
//     required NetworkInfo networkInfo,
//     required TokenService tokenService,
//   }) : _authLocalDatasource = authLocalDatasource,
//        _authRemoteDatasource = authRemoteDatasource,
//        _networkInfo = networkInfo,
//        _tokenService = tokenService;

//   // ✅ AUTO LOGIN
//   @override
//   Future<Either<Failure, AuthEntity>> getCurrentUser() async {
//     try {
//       final token = await _tokenService.getToken();

//       if (token == null || token.isEmpty) {
//         return Left(LocalDatabaseFailure(message: 'No token found'));
//       }

//       final user = await _authLocalDatasource.getCurrentUser();

//       if (user == null) {
//         return Left(LocalDatabaseFailure(message: 'No local user found'));
//       }

//       return Right(user.toEntity().copyWith(token: token));
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }

//   // ✅ LOGIN
//   @override
//   Future<Either<Failure, AuthEntity>> login(
//     String email,
//     String password,
//   ) async {
//     if (await _networkInfo.isConnected) {
//       try {
//         final apiModel = await _authRemoteDatasource.login(email, password);

//         if (apiModel == null) {
//           return const Left(ApiFailure(message: 'Invalid credentials'));
//         }

//         // 🔥 SAVE TOKEN
//         await _tokenService.saveToken(apiModel.token);

//         // 🔥 SAVE USER LOCALLY
//         // final hiveModel = AuthHiveModel.fromApiModel(apiModel);
//         // await _authLocalDatasource.saveCurrentUser(hiveModel);

//         return Right(apiModel.toEntity().copyWith(token: apiModel.token));
//       } on DioException catch (e) {
//         return Left(
//           ApiFailure(
//             message: e.response?.data['message'] ?? 'Login failed',
//             statusCode: e.response?.statusCode,
//           ),
//         );
//       } catch (e) {
//         return Left(ApiFailure(message: e.toString()));
//       }
//     } else {
//       return Left(ApiFailure(message: 'No internet connection'));
//     }
//   }

//   // ✅ LOGOUT
//   @override
//   Future<Either<Failure, bool>> logout() async {
//     try {
//       await _tokenService.removeToken();
//       await _authLocalDatasource.clearAllUserData();
//       return const Right(true);
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }

//   // ✅ REGISTER
//   @override
//   Future<Either<Failure, bool>> register(AuthEntity user) async {
//     if (await _networkInfo.isConnected) {
//       try {
//         final apiModel = AuthApiModel.fromEntity(user);
//         await _authRemoteDatasource.register(apiModel);
//         return const Right(true);
//       } on DioException catch (e) {
//         return Left(
//           ApiFailure(
//             message: e.response?.data['message'] ?? 'Registration failed',
//             statusCode: e.response?.statusCode,
//           ),
//         );
//       } catch (e) {
//         return Left(ApiFailure(message: e.toString()));
//       }
//     } else {
//       return Left(ApiFailure(message: 'No internet connection'));
//     }
//   }

//   @override
//   Future<Either<Failure, bool>> clearAllUserData() async {
//     try {
//       await _tokenService.removeToken();
//       await _authLocalDatasource.clearAllUserData();
//       return const Right(true);
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }
// }
