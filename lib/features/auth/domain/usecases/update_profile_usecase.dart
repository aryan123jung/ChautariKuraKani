import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateProfileParams extends Equatable {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? bio;
  final File? profileImage;
  final File? coverImage;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.bio,
    this.profileImage,
    this.coverImage,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    username,
    email,
    bio,
    profileImage?.path,
    coverImage?.path,
  ];
}

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(repository: repository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, UpdateProfileParams> {
  final IAuthRepository _repository;

  UpdateProfileUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      username: params.username,
      email: params.email,
      bio: params.bio,
      profileImage: params.profileImage,
      coverImage: params.coverImage,
    );
  }
}
