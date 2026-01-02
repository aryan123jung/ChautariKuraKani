// import 'package:chautari_kurakani/core/error/failures.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
// import 'package:chautari_kurakani/features/auth/data/datasources/local/auth_local_datsource.dart';
// import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// //Provider
// final authRepositoryProvider = Provider<IAuthRepository>((ref) {
//   return AuthRepository(authDatasource: ref.read(authLocalDatsourceProvider));
// });

// class AuthRepository implements IAuthRepository {
//   final IAuthDatasource _authDatasource;

//   AuthRepository({required IAuthDatasource authDatasource})
//     : _authDatasource = authDatasource;

//   @override
//   Future<Either<Failure, AuthEntity>> getCurrentUser() async {
//     try {
//       final user = await _authDatasource.getCurrentUser();
//       if (user != null) {
//         final entity = user.toEntity();
//         return Right(entity);
//       }
//       return Left(LocalDatabaseFailure(message: 'No user logged in'));
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, AuthEntity>> login(
//     String email,
//     String password,
//   ) async {
//     try {
//       final user = await _authDatasource.login(email, password);
//       if (user != null) {
//         final entity = user.toEntity();
//         return Right(entity);
//       }
//       return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, bool>> logout() async {
//     try {
//       final result = await _authDatasource.logout();
//       if (result) {
//         return Right(true);
//       }
//       return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, bool>> register(AuthEntity entity) async {
//     try {
//       final model = AuthHiveModel.fromEntity(entity);
//       final result = await _authDatasource.register(model);
//       if (result) {
//         return Right(true);
//       }
//       return Left(LocalDatabaseFailure(message: 'Failed to register user'));
//     } catch (e) {
//       return Left(LocalDatabaseFailure(message: e.toString()));
//     }
//   }
  
//   @override
//   Future<Either<Failure, bool>> clearAllUserData() {
//     throw UnimplementedError();
//   }
// }

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/auth_datasource.dart';
import 'package:chautari_kurakani/features/auth/data/datasources/local/auth_local_datsource.dart';
import 'package:chautari_kurakani/features/auth/data/models/auth_hive_model.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authDatasource: ref.read(authLocalDatsourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;
  
  AuthRepository({required IAuthDatasource authDatasource})
      : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
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

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
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
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> clearAllUserData() async {
    try {
      final result = await _authDatasource.clearAllUserData();
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to clear user data'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}