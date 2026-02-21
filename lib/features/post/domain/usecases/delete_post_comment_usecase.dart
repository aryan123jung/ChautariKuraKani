import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeletePostCommentParams extends Equatable {
  final String postId;
  final String commentId;

  const DeletePostCommentParams({
    required this.postId,
    required this.commentId,
  });

  @override
  List<Object?> get props => [postId, commentId];
}

final deletePostCommentUsecaseProvider = Provider<DeletePostCommentUsecase>((
  ref,
) {
  return DeletePostCommentUsecase(repository: ref.read(postRepositoryProvider));
});

class DeletePostCommentUsecase
    implements UsecaseWithParams<bool, DeletePostCommentParams> {
  DeletePostCommentUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, bool>> call(DeletePostCommentParams params) {
    return _repository.deleteComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}
