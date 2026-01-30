import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
//   return LogoutUsecase(repository: ref.read(authRepositoryProvider));
// });

// class LogoutUsecase {
//   final IAuthRepository _repository;

//   LogoutUsecase({required IAuthRepository repository})
//       : _repository = repository;

//   Future<Either<Failure, bool>> call() async {
//     return await _repository.logout();
//   }
// }

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() async{
    return await _authRepository.logout();
  }
}
