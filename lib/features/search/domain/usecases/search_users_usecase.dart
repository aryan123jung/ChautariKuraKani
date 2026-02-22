import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/search/data/repositories/search_repository.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:chautari_kurakani/features/search/domain/repositories/search_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchUsersParams extends Equatable {
  final String query;
  final int page;
  final int size;

  const SearchUsersParams({required this.query, this.page = 1, this.size = 10});

  @override
  List<Object?> get props => [query, page, size];
}

final searchUsersUsecaseProvider = Provider<SearchUsersUsecase>((ref) {
  return SearchUsersUsecase(repository: ref.read(searchRepositoryProvider));
});

class SearchUsersUsecase
    implements UsecaseWithParams<List<SearchUserEntity>, SearchUsersParams> {
  final ISearchRepository _repository;

  SearchUsersUsecase({required ISearchRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<SearchUserEntity>>> call(
    SearchUsersParams params,
  ) {
    return _repository.searchUsers(
      query: params.query,
      page: params.page,
      size: params.size,
    );
  }
}
