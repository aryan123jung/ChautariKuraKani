import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: mockAuthRepository);
  });

  group('LogoutUsecase', () {
    test('should return true when logout is successful', () async {
      // Arrange
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when logout fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Logout failed');
      when(
        () => mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
