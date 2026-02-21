import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikePostParams extends Equatable {
  final String postId;

  const LikePostParams(this.postId);

  @override
  List<Object?> get props => [postId];
}

final likePostUsecaseProvider = Provider<LikePostUsecase>((ref) {
  return LikePostUsecase(repository: ref.read(postRepositoryProvider));
});

class LikePostUsecase implements UsecaseWithParams<PostEntity, LikePostParams> {
  LikePostUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, PostEntity>> call(LikePostParams params) {
    return _repository.likePost(params.postId);
  }
}
