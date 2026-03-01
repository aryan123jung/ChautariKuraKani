import 'dart:io';

import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/create_post_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/create_post_comment_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/delete_post_comment_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/get_my_posts_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/get_post_comments_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/like_post_usecase.dart';
import 'package:chautari_kurakani/features/post/domain/usecases/update_post_usecase.dart';
import 'package:chautari_kurakani/features/post/presentation/state/post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postViewModelProvider = NotifierProvider<PostViewModel, PostState>(
  PostViewModel.new,
);

class PostViewModel extends Notifier<PostState> {
  late final GetPostsUsecase _getPostsUsecase;
  late final GetMyPostsUsecase _getMyPostsUsecase;
  late final CreatePostUsecase _createPostUsecase;
  late final UpdatePostUsecase _updatePostUsecase;
  late final DeletePostUsecase _deletePostUsecase;
  late final LikePostUsecase _likePostUsecase;
  late final GetPostCommentsUsecase _getPostCommentsUsecase;
  late final CreatePostCommentUsecase _createPostCommentUsecase;
  late final DeletePostCommentUsecase _deletePostCommentUsecase;

  @override
  PostState build() {
    _getPostsUsecase = ref.read(getPostsUsecaseProvider);
    _getMyPostsUsecase = ref.read(getMyPostsUsecaseProvider);
    _createPostUsecase = ref.read(createPostUsecaseProvider);
    _updatePostUsecase = ref.read(updatePostUsecaseProvider);
    _deletePostUsecase = ref.read(deletePostUsecaseProvider);
    _likePostUsecase = ref.read(likePostUsecaseProvider);
    _getPostCommentsUsecase = ref.read(getPostCommentsUsecaseProvider);
    _createPostCommentUsecase = ref.read(createPostCommentUsecaseProvider);
    _deletePostCommentUsecase = ref.read(deletePostCommentUsecaseProvider);

    return const PostState.initial();
  }

  Future<void> fetchPosts({
    int page = 1,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh || state.posts.isEmpty) {
      state = state.copyWith(status: PostStatus.loading, errorMessage: null);
    }

    final result = await _getPostsUsecase(
      GetPostsParams(page: page, size: size, bypassCache: forceRefresh),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(
          status: PostStatus.loaded,
          posts: posts,
          errorMessage: null,
        );
      },
    );
  }

  Future<bool> refreshPostsIfChanged({
    int probePage = 1,
    int probeSize = 1,
    int fullPage = 1,
    int fullSize = 20,
  }) async {
    final currentFirstPostId = state.posts.isNotEmpty
        ? state.posts.first.id
        : '';

    final probeResult = await _getPostsUsecase(
      GetPostsParams(page: probePage, size: probeSize, bypassCache: true),
    );

    return probeResult.fold((_) => false, (latestPosts) async {
      final latestFirstPostId = latestPosts.isNotEmpty
          ? latestPosts.first.id
          : '';
      final changed =
          latestFirstPostId.isNotEmpty &&
          latestFirstPostId != currentFirstPostId;
      if (!changed) {
        return false;
      }

      await fetchPosts(page: fullPage, size: fullSize, forceRefresh: true);
      return true;
    });
  }

  Future<void> fetchMyPosts({
    required String authId,
    int page = 1,
    int size = 50,
  }) async {
    state = state.copyWith(status: PostStatus.loading, errorMessage: null);

    final result = await _getMyPostsUsecase(
      GetMyPostsParams(authId: authId, page: page, size: size),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(
          status: PostStatus.loaded,
          myPosts: posts,
          errorMessage: null,
        );
      },
    );
  }

  Future<bool> createPost({String? caption, File? mediaFile}) async {
    state = state.copyWith(status: PostStatus.submitting, errorMessage: null);

    final result = await _createPostUsecase(
      CreatePostParams(caption: caption, mediaFile: mediaFile),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(status: PostStatus.success, errorMessage: null);
        return success;
      },
    );
  }

  Future<PostEntity?> updatePost({
    required String postId,
    String? caption,
    File? mediaFile,
  }) async {
    state = state.copyWith(status: PostStatus.submitting, errorMessage: null);

    final result = await _updatePostUsecase(
      UpdatePostParams(postId: postId, caption: caption, mediaFile: mediaFile),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (updatedPost) {
        _replacePostInState(updatedPost);
        state = state.copyWith(status: PostStatus.success, errorMessage: null);
        return updatedPost;
      },
    );
  }

  Future<bool> deletePost(String postId) async {
    state = state.copyWith(status: PostStatus.submitting, errorMessage: null);

    final result = await _deletePostUsecase(DeletePostParams(postId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        final updatedPosts = state.posts
            .where((post) => post.id != postId)
            .toList();
        final updatedMyPosts = state.myPosts
            .where((post) => post.id != postId)
            .toList();

        state = state.copyWith(
          status: PostStatus.success,
          posts: updatedPosts,
          myPosts: updatedMyPosts,
          errorMessage: null,
        );
        return success;
      },
    );
  }

  Future<PostEntity?> likePost(String postId) async {
    final result = await _likePostUsecase(LikePostParams(postId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (updatedPost) {
        _replacePostInState(updatedPost);
        state = state.copyWith(status: PostStatus.success, errorMessage: null);
        return updatedPost;
      },
    );
  }

  Future<List<PostCommentEntity>> fetchComments(String postId) async {
    final result = await _getPostCommentsUsecase(GetPostCommentsParams(postId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return <PostCommentEntity>[];
      },
      (comments) {
        final updatedComments = Map<String, List<PostCommentEntity>>.from(
          state.commentsByPostId,
        );
        updatedComments[postId] = comments;

        state = state.copyWith(
          status: PostStatus.loaded,
          commentsByPostId: updatedComments,
          errorMessage: null,
        );
        return comments;
      },
    );
  }

  Future<bool> createComment({
    required String postId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: PostStatus.error,
        errorMessage: 'Comment text is required',
      );
      return false;
    }

    final result = await _createPostCommentUsecase(
      CreatePostCommentParams(postId: postId, text: trimmed),
    );

    final isSuccess = result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        return success;
      },
    );

    if (isSuccess) {
      await fetchComments(postId);
      state = state.copyWith(status: PostStatus.success, errorMessage: null);
    }

    return isSuccess;
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final result = await _deletePostCommentUsecase(
      DeletePostCommentParams(postId: postId, commentId: commentId),
    );

    final isSuccess = result.fold(
      (failure) {
        state = state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        return success;
      },
    );

    if (isSuccess) {
      await fetchComments(postId);
      state = state.copyWith(status: PostStatus.success, errorMessage: null);
    }

    return isSuccess;
  }

  void _replacePostInState(PostEntity updatedPost) {
    final updatedPosts = state.posts
        .map((post) => post.id == updatedPost.id ? updatedPost : post)
        .toList();

    final updatedMyPosts = state.myPosts
        .map((post) => post.id == updatedPost.id ? updatedPost : post)
        .toList();

    state = state.copyWith(posts: updatedPosts, myPosts: updatedMyPosts);
  }
}
