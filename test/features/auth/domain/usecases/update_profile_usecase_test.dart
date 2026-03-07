import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late UpdateProfileUsecase usecase;

  setUpAll(() {
    registerFallbackValue(File('dummy_profile.png'));
  });

  setUp(() {
    repository = MockAuthRepository();
    usecase = UpdateProfileUsecase(repository: repository);
  });

  group('UpdateProfileUsecase', () {
    test('returns user on success', () async {
      const user = AuthEntity(
        authId: 'u1',
        fName: 'A',
        lName: 'B',
        email: 'a@a.com',
        username: 'ab',
      );
      when(
        () => repository.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          bio: any(named: 'bio'),
          profileImage: any(named: 'profileImage'),
          coverImage: any(named: 'coverImage'),
        ),
      ).thenAnswer((_) async => const Right(user));

      final result = await usecase(
        const UpdateProfileParams(
          firstName: 'A',
          lastName: 'B',
          username: 'ab',
          email: 'a@a.com',
        ),
      );

      expect(result, const Right(user));
    });

    test('returns failure on error', () async {
      const failure = ApiFailure(message: 'update failed');
      when(
        () => repository.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          bio: any(named: 'bio'),
          profileImage: any(named: 'profileImage'),
          coverImage: any(named: 'coverImage'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const UpdateProfileParams(
          firstName: 'A',
          lastName: 'B',
          username: 'ab',
          email: 'a@a.com',
        ),
      );

      expect(result, const Left(failure));
    });

    test('forwards all params to repository', () async {
      final profileFile = File('profile.png');
      final coverFile = File('cover.png');
      when(
        () => repository.updateProfile(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          bio: any(named: 'bio'),
          profileImage: any(named: 'profileImage'),
          coverImage: any(named: 'coverImage'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          AuthEntity(
            authId: 'u1',
            fName: 'A',
            lName: 'B',
            email: 'a@a.com',
            username: 'ab',
          ),
        ),
      );

      await usecase(
        UpdateProfileParams(
          firstName: 'A',
          lastName: 'B',
          username: 'ab',
          email: 'a@a.com',
          bio: 'hello',
          profileImage: profileFile,
          coverImage: coverFile,
        ),
      );

      verify(
        () => repository.updateProfile(
          firstName: 'A',
          lastName: 'B',
          username: 'ab',
          email: 'a@a.com',
          bio: 'hello',
          profileImage: profileFile,
          coverImage: coverFile,
        ),
      ).called(1);
    });
  });
}
