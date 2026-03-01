import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
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
    cacheService: ref.read(appCacheServiceProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService;

  static const _profileCacheTtl = Duration(minutes: 10);

  String _profileKey(String userId) =>
      'profile_user_${userId.trim().toLowerCase()}';

  AuthEntity? _readCachedProfile(String userId, {Duration? maxAge}) {
    return _cacheService.read<AuthEntity>(
      key: _profileKey(userId),
      maxAge: maxAge,
      decoder: (raw) {
        final map = (raw as Map).cast<String, dynamic>();
        return AuthEntity(
          authId: map['authId']?.toString(),
          fName: map['fName']?.toString() ?? '',
          lName: map['lName']?.toString() ?? '',
          email: map['email']?.toString() ?? '',
          username: map['username']?.toString() ?? '',
          password: map['password']?.toString(),
          profilePicture: map['profilePicture']?.toString(),
          coverPicture: map['coverPicture']?.toString(),
          bio: map['bio']?.toString(),
        );
      },
    );
  }

  Future<void> _writeCachedProfile(AuthEntity entity) async {
    final userId = (entity.authId ?? '').trim();
    if (userId.isEmpty) return;
    await _cacheService.write(
      key: _profileKey(userId),
      data: {
        'authId': entity.authId,
        'fName': entity.fName,
        'lName': entity.lName,
        'email': entity.email,
        'username': entity.username,
        'password': entity.password,
        'profilePicture': entity.profilePicture,
        'coverPicture': entity.coverPicture,
        'bio': entity.bio,
      },
    );
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUserById(String userId) async {
    final normalizedId = userId.trim();
    final cachedFresh = normalizedId.isEmpty
        ? null
        : _readCachedProfile(normalizedId, maxAge: _profileCacheTtl);

    if (cachedFresh != null) {
      return Right(cachedFresh);
    }

    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDatasource.getCurrentUserById(userId);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          await _writeCachedProfile(entity);
          return Right(entity);
        }
        final cachedAnyAge = normalizedId.isEmpty
            ? null
            : _readCachedProfile(normalizedId);
        if (cachedAnyAge != null) {
          return Right(cachedAnyAge);
        }
        return const Left(ApiFailure(message: 'No user found'));
      } on DioException catch (e) {
        final cachedAnyAge = normalizedId.isEmpty
            ? null
            : _readCachedProfile(normalizedId);
        if (cachedAnyAge != null) {
          return Right(cachedAnyAge);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to get user',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cachedAnyAge = normalizedId.isEmpty
            ? null
            : _readCachedProfile(normalizedId);
        if (cachedAnyAge != null) {
          return Right(cachedAnyAge);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final cachedAnyAge = normalizedId.isEmpty
            ? null
            : _readCachedProfile(normalizedId);
        if (cachedAnyAge != null) {
          return Right(cachedAnyAge);
        }

        final user = normalizedId.isEmpty
            ? await _authDatasource.getCurrentUser()
            : await _authDatasource.getUserById(normalizedId);
        if (user != null) {
          final entity = user.toEntity();
          await _writeCachedProfile(entity);
          return Right(entity);
        }
        return Left(LocalDatabaseFailure(message: 'No user logged in'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? bio,
    File? profileImage,
    File? coverImage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final user = await _authRemoteDatasource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        bio: bio,
        profileImage: profileImage,
        coverImage: coverImage,
      );

      if (user == null) {
        return const Left(ApiFailure(message: "Failed to update profile"));
      }

      final entity = user.toEntity();
      await _writeCachedProfile(entity);
      return Right(entity);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
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
        await _cacheService.clearByPrefix('profile_user_');
        await _cacheService.clearByPrefix('my_chautari_');
        await _cacheService.clearByPrefix('friend_status_');
        await _cacheService.clearByPrefix('friend_count_');
        await _cacheService.clearByPrefix('search_users_');
        await _cacheService.clearByPrefix('chautari_count_');
        await _cacheService.clearByPrefix('feed_posts_');
        await _cacheService.clearByPrefix('conversations_');
        await _cacheService.clearByPrefix('call_history_');
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
  Future<Either<Failure, String>> profileImageUpload(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _authRemoteDatasource.profileImageUpload(image);

        if (fileName.isEmpty) {
          // ✅ only check if empty
          return const Left(
            ApiFailure(message: "Profile upload returned empty filename"),
          );
        }

        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, String>> coverImageUpload(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _authRemoteDatasource.coverImageUpload(image);

        if (fileName.isEmpty) {
          // ✅ only check if empty
          return const Left(
            ApiFailure(message: "Cover upload returned empty filename"),
          );
        }

        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, bool>> sendResetPasswordEmail(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        await _authRemoteDatasource.sendResetPasswordEmail(email);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? "Failed to send reset email",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyResetPasswordMobileCode({
    required String email,
    required String code,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _authRemoteDatasource.verifyResetPasswordMobileCode(
          email: email,
          code: code,
        );
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Invalid or expired code",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _authRemoteDatasource.resetPassword(token, newPassword);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Reset failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPasswordWithMobileCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _authRemoteDatasource.resetPasswordWithMobileCode(
          email: email,
          code: code,
          newPassword: newPassword,
        );
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Reset failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, List<AuthEntity>>> searchUsers({
    String? search,
    int page = 1,
    int size = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final users = await _authRemoteDatasource.searchUsers(
        search: search,
        page: page,
        size: size,
      );
      return Right(users.map((user) => user.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? "Failed to search users",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
