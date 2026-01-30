import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/upload_profile_image_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UploadProfileImageUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(File('dummy.png'));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UploadProfileImageUsecase(repository: mockAuthRepository);
  });

  final testFile = File('assets/images/black_half_logo.png');
  const uploadedUrl = 'black_half_logo.png';

  group('UploadProfileImageUsecase', () {
    test(
      'should return uploaded URL when profile image upload succeeds',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.profileImageUpload(any()),
        ).thenAnswer((_) async => const Right(uploadedUrl));

        // Act
        final result = await usecase(testFile);

        // Assert
        expect(result, const Right(uploadedUrl));
        verify(() => mockAuthRepository.profileImageUpload(testFile)).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return ApiFailure when profile image upload fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Upload failed');
      when(
        () => mockAuthRepository.profileImageUpload(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(testFile);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockAuthRepository.profileImageUpload(testFile)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
