import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resetPasswordUsecaseProvider = Provider(
  (ref) => ResetPasswordUsecase(repository: ref.read(authRepositoryProvider)),
);

class ResetPasswordUsecase {
  final IAuthRepository repository;

  ResetPasswordUsecase({required this.repository});

  Future<Either<Failure, bool>> call({
    required String token,
    required String newPassword,
  }) {
    return repository.resetPassword(token: token, newPassword: newPassword);
  }
}
