import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IPostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int size = 20,
  });

  Future<Either<Failure, List<PostEntity>>> getMyPosts({
    required String authId,
    int page = 1,
    int size = 50,
  });

  Future<Either<Failure, bool>> createPost({String? caption, File? mediaFile});

  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    String? caption,
    File? mediaFile,
  });

  Future<Either<Failure, bool>> deletePost(String postId);

  Future<Either<Failure, PostEntity>> likePost(String postId);

  Future<Either<Failure, List<PostCommentEntity>>> getComments(String postId);
}
