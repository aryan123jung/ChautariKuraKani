import 'dart:io';

import 'package:chautari_kurakani/features/post/data/models/post_api_model.dart';

abstract interface class IPostRemoteDatasource {
  Future<List<PostApiModel>> getPosts({int page = 1, int size = 20});

  Future<void> createPost({String? caption, File? mediaFile});

  Future<PostApiModel> updatePost({
    required String postId,
    String? caption,
    File? mediaFile,
  });

  Future<void> deletePost(String postId);

  Future<PostApiModel> likePost(String postId);

  Future<List<PostCommentApiModel>> getComments(String postId);

  Future<void> createComment({required String postId, required String text});

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
}
