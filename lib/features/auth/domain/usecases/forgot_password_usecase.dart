import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordUsecaseProvider = Provider(
  (ref) => ForgotPasswordUsecase(repository: ref.read(authRepositoryProvider)),
);

class ForgotPasswordUsecase {
  final IAuthRepository repository;

  ForgotPasswordUsecase({required this.repository});

  Future<Either<Failure, bool>> call(String email) {
    return repository.sendResetPasswordEmail(email);
  }
}
