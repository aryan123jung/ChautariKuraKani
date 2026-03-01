import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUserById(String userId);
  Future<Either<Failure, AuthEntity>> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? bio,
    File? profileImage,
    File? coverImage,
  });
  Future<Either<Failure, bool>> logout();
  //image
  Future<Either<Failure, String>> profileImageUpload(File image);
  Future<Either<Failure, String>> coverImageUpload(File image);

  //FORGET PASSWORD
  Future<Either<Failure, bool>> sendResetPasswordEmail(String email);
  Future<Either<Failure, bool>> verifyResetPasswordMobileCode({
    required String email,
    required String code,
  });
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<Either<Failure, bool>> resetPasswordWithMobileCode({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, List<AuthEntity>>> searchUsers({
    String? search,
    int page = 1,
    int size = 10,
  });
}
