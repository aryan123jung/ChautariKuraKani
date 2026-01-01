import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecaseParams extends Equatable {
  final String fName;
  final String lName;
  final String email;
  final String username;
  final String password;
  // final String profilePicture;

  RegisterUsecaseParams({
    required this.fName,
    required this.lName,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [fName, lName, email, username, password];
}


//provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref){
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      fName: params.fName,
      lName: params.lName,
      email: params.email,
      username: params.username,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}
