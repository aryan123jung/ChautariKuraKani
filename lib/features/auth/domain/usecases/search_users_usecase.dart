import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchUsersParams extends Equatable {
  final String? search;
  final int page;
  final int size;

  const SearchUsersParams({this.search, this.page = 1, this.size = 10});

  @override
  List<Object?> get props => [search, page, size];
}

final searchUsersUsecaseProvider = Provider<SearchUsersUsecase>((ref) {
  return SearchUsersUsecase(repository: ref.read(authRepositoryProvider));
});

class SearchUsersUsecase
    implements UsecaseWithParams<List<AuthEntity>, SearchUsersParams> {
  final IAuthRepository _repository;

  SearchUsersUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<AuthEntity>>> call(SearchUsersParams params) {
    return _repository.searchUsers(
      search: params.search,
      page: params.page,
      size: params.size,
    );
  }
}
