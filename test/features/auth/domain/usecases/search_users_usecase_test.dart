import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/search_users_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SearchUsersUsecase usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = SearchUsersUsecase(repository: repository);
  });

  group('SearchUsersUsecase', () {
    test('returns users on success', () async {
      const users = [
        AuthEntity(
          authId: 'u1',
          fName: 'A',
          lName: 'B',
          email: 'a@a.com',
          username: 'ab',
        ),
      ];
      when(
        () => repository.searchUsers(
          search: any(named: 'search'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => const Right(users));

      final result = await usecase(const SearchUsersParams(search: 'a'));
      expect(result, const Right(users));
    });

    test('returns failure on error', () async {
      const failure = ApiFailure(message: 'failed');
      when(
        () => repository.searchUsers(
          search: any(named: 'search'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(const SearchUsersParams(search: 'a'));
      expect(result, const Left(failure));
    });

    test('forwards pagination params', () async {
      when(
        () => repository.searchUsers(
          search: any(named: 'search'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer((_) async => const Right(<AuthEntity>[]));

      await usecase(const SearchUsersParams(search: 'john', page: 2, size: 15));
      verify(
        () => repository.searchUsers(search: 'john', page: 2, size: 15),
      ).called(1);
    });
  });
}
