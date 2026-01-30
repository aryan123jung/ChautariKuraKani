import 'package:chautari_kurakani/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase getCurrentUserUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUsecase = GetCurrentUserUsecase(
      authRepository: mockAuthRepository,
    );
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

  const params = GetCurrentUsecaseParams(userId: 'user123');

  const authEntity = AuthEntity(
    fName: 'Aryan',
    lName: 'Chhetri',
    email: 'aryan@email.com',
    username: 'aryan123',
    password: 'password123',
  );

  group('GetCurrentUserUsecase', () {
    test(
      'should return AuthEntity when fetching current user is successful',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.getCurrentUserById(any()),
        ).thenAnswer((_) async => const Right(authEntity));

        // Act
        final result = await getCurrentUserUsecase(params);

        // Assert
        expect(result, const Right(authEntity));
        verify(
          () => mockAuthRepository.getCurrentUserById(params.userId),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return ApiFailure when fetching current user fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'User not found');
      when(
        () => mockAuthRepository.getCurrentUserById(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await getCurrentUserUsecase(params);

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockAuthRepository.getCurrentUserById(params.userId),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
