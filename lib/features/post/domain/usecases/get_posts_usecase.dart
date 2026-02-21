import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetPostsParams extends Equatable {
  final int page;
  final int size;

  const GetPostsParams({this.page = 1, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

final getPostsUsecaseProvider = Provider<GetPostsUsecase>((ref) {
  return GetPostsUsecase(repository: ref.read(postRepositoryProvider));
});

class GetPostsUsecase
    implements UsecaseWithParams<List<PostEntity>, GetPostsParams> {
  GetPostsUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsParams params) {
    return _repository.getPosts(page: params.page, size: params.size);
  }
}
