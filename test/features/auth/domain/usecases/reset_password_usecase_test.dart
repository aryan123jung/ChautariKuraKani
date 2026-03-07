import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ResetPasswordUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = ResetPasswordUsecase(repository: repository);
  });

  group('ResetPasswordUsecase', () {
    test('token reset success', () async {
      when(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase(token: 'tkn', newPassword: 'password123');
      expect(result, const Right(true));
    });

    test('token reset failure', () async {
      const failure = ApiFailure(message: 'Reset failed');
      when(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(token: 'bad', newPassword: 'password123');
      expect(result, const Left(failure));
    });

    test('mobile code reset success', () async {
      when(
        () => repository.resetPasswordWithMobileCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.mobileCode(
        email: 'a@a.com',
        code: '123456',
        newPassword: 'password123',
      );
      expect(result, const Right(true));
    });

    test('mobile code reset failure', () async {
      const failure = ApiFailure(message: 'Invalid code');
      when(
        () => repository.resetPasswordWithMobileCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase.mobileCode(
        email: 'a@a.com',
        code: '000000',
        newPassword: 'password123',
      );
      expect(result, const Left(failure));
    });
  });
}
