import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase registerUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);
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

  const params = RegisterUsecaseParams(
    fName: 'Aryan',
    lName: 'Chhetri',
    email: 'aryan@email.com',
    username: 'aryan123',
    password: 'password123',
  );

  const authEntity = AuthEntity(
    fName: 'Aryan',
    lName: 'Chhetri',
    email: 'aryan@email.com',
    username: 'aryan123',
    password: 'password123',
  );

  group('RegisterUsecase', () {
    test('should return AuthEntity when registration is successful', () async {
      when(
        () => mockAuthRepository.register(any()),
      ).thenAnswer((_) async => const Right(authEntity));

      final result = await registerUsecase(params);

      expect(result, const Right(authEntity));

      verify(() => mockAuthRepository.register(any())).called(1);

      // Optional stricter check:
      // verify(() => mockAuthRepository.register(
      //   argThat(
      //     isA<AuthEntity>()
      //         .having((e) => e.fName, 'fName', 'Aryan')
      //         .having((e) => e.lName, 'lName', 'Chhetri')
      //         .having((e) => e.email, 'email', 'aryan@email.com')
      //         .having((e) => e.username, 'username', 'aryan123')
      //         .having((e) => e.password, 'password', 'password123'),
      //   ),
      // )).called(1);

      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when registration fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'User already exists');
      when(
        () => mockAuthRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await registerUsecase(params);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockAuthRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
