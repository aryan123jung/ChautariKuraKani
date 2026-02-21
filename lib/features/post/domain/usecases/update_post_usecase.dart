import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdatePostParams extends Equatable {
  final String postId;
  final String? caption;
  final File? mediaFile;

  const UpdatePostParams({required this.postId, this.caption, this.mediaFile});

  @override
  List<Object?> get props => [postId, caption, mediaFile?.path];
}

final updatePostUsecaseProvider = Provider<UpdatePostUsecase>((ref) {
  return UpdatePostUsecase(repository: ref.read(postRepositoryProvider));
});

class UpdatePostUsecase
    implements UsecaseWithParams<PostEntity, UpdatePostParams> {
  UpdatePostUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, PostEntity>> call(UpdatePostParams params) {
    return _repository.updatePost(
      postId: params.postId,
      caption: params.caption,
      mediaFile: params.mediaFile,
    );
  }
}
