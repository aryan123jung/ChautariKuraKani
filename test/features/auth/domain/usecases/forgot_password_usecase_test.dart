import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ForgotPasswordUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = ForgotPasswordUsecase(repository: repository);
  });

  group('ForgotPasswordUsecase', () {
    test('send reset email success', () async {
      when(
        () => repository.sendResetPasswordEmail(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase('a@a.com');
      expect(result, const Right(true));
      verify(() => repository.sendResetPasswordEmail('a@a.com')).called(1);
    });

    test('send reset email failure', () async {
      const failure = ApiFailure(message: 'failed');
      when(
        () => repository.sendResetPasswordEmail(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase('a@a.com');
      expect(result, const Left(failure));
    });

    test('verify code success', () async {
      when(
        () => repository.verifyResetPasswordMobileCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.verifyCode(email: 'a@a.com', code: '123456');
      expect(result, const Right(true));
      verify(
        () => repository.verifyResetPasswordMobileCode(
          email: 'a@a.com',
          code: '123456',
        ),
      ).called(1);
    });

    test('verify code failure', () async {
      const failure = ApiFailure(message: 'Invalid or expired code');
      when(
        () => repository.verifyResetPasswordMobileCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase.verifyCode(email: 'a@a.com', code: '000000');
      expect(result, const Left(failure));
    });
  });
}
