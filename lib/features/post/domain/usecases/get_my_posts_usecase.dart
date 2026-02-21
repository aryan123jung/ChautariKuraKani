import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetMyPostsParams extends Equatable {
  final String authId;
  final int page;
  final int size;

  const GetMyPostsParams({required this.authId, this.page = 1, this.size = 50});

  @override
  List<Object?> get props => [authId, page, size];
}

final getMyPostsUsecaseProvider = Provider<GetMyPostsUsecase>((ref) {
  return GetMyPostsUsecase(repository: ref.read(postRepositoryProvider));
});

class GetMyPostsUsecase
    implements UsecaseWithParams<List<PostEntity>, GetMyPostsParams> {
  GetMyPostsUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetMyPostsParams params) {
    return _repository.getMyPosts(
      authId: params.authId,
      page: params.page,
      size: params.size,
    );
  }
}
