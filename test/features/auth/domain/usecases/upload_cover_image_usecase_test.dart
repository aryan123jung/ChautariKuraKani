import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/upload_cover_image_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late UploadCoverImageUsecase usecase;
  final file = File('cover.png');

  setUpAll(() {
    registerFallbackValue(File('dummy_cover.png'));
  });

  setUp(() {
    repository = MockAuthRepository();
    usecase = UploadCoverImageUsecase(repository: repository);
  });

  test('returns uploaded file name on success', () async {
    when(
      () => repository.coverImageUpload(any()),
    ).thenAnswer((_) async => const Right('cover.png'));

    final result = await usecase(file);
    expect(result, const Right('cover.png'));
    verify(() => repository.coverImageUpload(file)).called(1);
  });

  test('returns failure on upload error', () async {
    const failure = ApiFailure(message: 'upload failed');
    when(
      () => repository.coverImageUpload(any()),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(file);
    expect(result, const Left(failure));
  });
}
