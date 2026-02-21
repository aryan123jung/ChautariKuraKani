import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeletePostParams extends Equatable {
  final String postId;

  const DeletePostParams(this.postId);

  @override
  List<Object?> get props => [postId];
}

final deletePostUsecaseProvider = Provider<DeletePostUsecase>((ref) {
  return DeletePostUsecase(repository: ref.read(postRepositoryProvider));
});

class DeletePostUsecase implements UsecaseWithParams<bool, DeletePostParams> {
  DeletePostUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, bool>> call(DeletePostParams params) {
    return _repository.deletePost(params.postId);
  }
}
