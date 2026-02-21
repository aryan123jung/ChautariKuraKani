import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/post/data/repositories/post_repository.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostParams extends Equatable {
  final String? caption;
  final File? mediaFile;

  const CreatePostParams({this.caption, this.mediaFile});

  @override
  List<Object?> get props => [caption, mediaFile?.path];
}

final createPostUsecaseProvider = Provider<CreatePostUsecase>((ref) {
  return CreatePostUsecase(repository: ref.read(postRepositoryProvider));
});

class CreatePostUsecase implements UsecaseWithParams<bool, CreatePostParams> {
  CreatePostUsecase({required IPostRepository repository})
    : _repository = repository;

  final IPostRepository _repository;

  @override
  Future<Either<Failure, bool>> call(CreatePostParams params) {
    return _repository.createPost(
      caption: params.caption,
      mediaFile: params.mediaFile,
    );
  }
}
