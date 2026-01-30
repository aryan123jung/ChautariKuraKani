import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase loginUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        fName: 'fake',
        lName: 'fake',
        email: 'fake@email.com',
        username: 'fakeuser',
        password: 'fakepassword',
      ),
    );
  });

  const params = LoginUsecaseParams(
    email: 'aryan@email.com',
    password: 'password123',
  );

  const authEntity = AuthEntity(
    fName: 'Aryan',
    lName: 'Chhetri',
    email: 'aryan@email.com',
    username: 'aryan123',
    password: 'password123',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => const Right(authEntity));

      // Act
      final result = await loginUsecase(params);

      // Assert
      expect(result, const Right(authEntity));

      verify(
        () => mockAuthRepository.login(params.email, params.password),
      ).called(1);

      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when login fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await loginUsecase(params);

      // Assert
      expect(result, const Left(failure));

      verify(
        () => mockAuthRepository.login(params.email, params.password),
      ).called(1);

      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
