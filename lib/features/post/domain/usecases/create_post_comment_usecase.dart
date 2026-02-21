import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostCommentParams extends Equatable {
  final String postId;
  final String text;

  const CreatePostCommentParams({required this.postId, required this.text});

  @override
  List<Object?> get props => [postId, text];
}

final createPostCommentUsecaseProvider = Provider<CreatePostCommentUsecase>((
  ref,
) {
  return CreatePostCommentUsecase(repository: ref.read(postRepositoryProvider));
});

class CreatePostCommentUsecase
    implements UsecaseWithParams<bool, CreatePostCommentParams> {
  CreatePostCommentUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, bool>> call(CreatePostCommentParams params) {
    return _repository.createComment(postId: params.postId, text: params.text);
  }
}
