import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetPostCommentsParams extends Equatable {
  final String postId;

  const GetPostCommentsParams(this.postId);

  @override
  List<Object?> get props => [postId];
}

final getPostCommentsUsecaseProvider = Provider<GetPostCommentsUsecase>((ref) {
  return GetPostCommentsUsecase(repository: ref.read(postRepositoryProvider));
});

class GetPostCommentsUsecase
    implements
        UsecaseWithParams<List<PostCommentEntity>, GetPostCommentsParams> {
  GetPostCommentsUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, List<PostCommentEntity>>> call(
    GetPostCommentsParams params,
  ) {
    return _repository.getComments(params.postId);
  }
}
