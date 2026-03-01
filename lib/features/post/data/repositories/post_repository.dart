import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/post/data/datasources/post_datasource.dart';
import 'package:chautari_kurakani/features/post/data/datasources/remote/post_remote_datasource.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepositoryProvider = Provider<IPostRepository>((ref) {
  return PostRepository(
    remoteDatasource: ref.read(postRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cacheService: ref.read(appCacheServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class PostRepository implements IPostRepository {
  PostRepository({
    required IPostRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
    required UserSessionService userSessionService,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService,
       _userSessionService = userSessionService;

  final IPostRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;
  final UserSessionService _userSessionService;
  static const _feedTtl = Duration(seconds: 45);

  String _feedKey(int page, int size) {
    final userId = (_userSessionService.getCurrentUserId() ?? '')
        .trim()
        .toLowerCase();
    return 'feed_posts_${userId}_${page}_$size';
  }

  List<PostEntity>? _readPostsCache(int page, int size, {Duration? maxAge}) {
    return _cacheService.read<List<PostEntity>>(
      key: _feedKey(page, size),
      maxAge: maxAge,
      decoder: (raw) {
        final list = (raw as List).cast<dynamic>();
        return list
            .map((item) {
              final map = (item as Map).cast<String, dynamic>();
              return PostEntity(
                id: map['id']?.toString() ?? '',
                authorId: map['authorId']?.toString() ?? '',
                profileUrl: map['profileUrl']?.toString() ?? '',
                name: map['name']?.toString() ?? '',
                hoursAgo: map['hoursAgo']?.toString() ?? '',
                caption: map['caption']?.toString() ?? '',
                communityId: map['communityId']?.toString(),
                imageUrl: map['imageUrl']?.toString(),
                videoUrl: map['videoUrl']?.toString(),
                mediaType: map['mediaType']?.toString(),
                likesCount: (map['likesCount'] is int)
                    ? map['likesCount'] as int
                    : int.tryParse(map['likesCount']?.toString() ?? '0') ?? 0,
                likedUserIds:
                    (map['likedUserIds'] as List<dynamic>? ?? const [])
                        .map((e) => e.toString())
                        .toList(growable: false),
                commentsCount: (map['commentsCount'] is int)
                    ? map['commentsCount'] as int
                    : int.tryParse(map['commentsCount']?.toString() ?? '0') ??
                          0,
              );
            })
            .toList(growable: false);
      },
    );
  }

  Future<void> _writePostsCache(
    List<PostEntity> posts,
    int page,
    int size,
  ) async {
    final payload = posts
        .map(
          (post) => {
            'id': post.id,
            'authorId': post.authorId,
            'profileUrl': post.profileUrl,
            'name': post.name,
            'hoursAgo': post.hoursAgo,
            'caption': post.caption,
            'communityId': post.communityId,
            'imageUrl': post.imageUrl,
            'videoUrl': post.videoUrl,
            'mediaType': post.mediaType,
            'likesCount': post.likesCount,
            'likedUserIds': post.likedUserIds,
            'commentsCount': post.commentsCount,
          },
        )
        .toList(growable: false);
    await _cacheService.write(key: _feedKey(page, size), data: payload);
  }

  Future<List<PostEntity>> _fetchRemotePosts({
    required int page,
    required int size,
  }) async {
    final posts = await _remoteDatasource.getPosts(page: page, size: size);
    final entities = posts.map((post) => post.toEntity()).toList();
    if (page == 1) {
      await _writePostsCache(entities, page, size);
    }
    return entities;
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int size = 20,
    bool bypassCache = false,
  }) async {
    final isFirstPage = page == 1;
    final cached = isFirstPage
        ? _readPostsCache(page, size, maxAge: _feedTtl)
        : null;

    if (!bypassCache && cached != null) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      final stale = !bypassCache && isFirstPage
          ? _readPostsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final entities = await _fetchRemotePosts(page: page, size: size);
      return Right(entities);
    } on DioException catch (e) {
      final stale = !bypassCache && isFirstPage
          ? _readPostsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch posts',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      final stale = !bypassCache && isFirstPage
          ? _readPostsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getMyPosts({
    required String authId,
    int page = 1,
    int size = 50,
  }) async {
    final result = await getPosts(page: page, size: size);
    return result.map(
      (posts) => posts.where((post) => post.authorId == authId).toList(),
    );
  }

  @override
  Future<Either<Failure, bool>> createPost({
    String? caption,
    File? mediaFile,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.createPost(
        caption: caption,
        mediaFile: mediaFile,
      );
      await _cacheService.clearByPrefix('feed_posts_');
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to create post',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost({
    required String postId,
    String? caption,
    File? mediaFile,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final updated = await _remoteDatasource.updatePost(
        postId: postId,
        caption: caption,
        mediaFile: mediaFile,
      );
      await _cacheService.clearByPrefix('feed_posts_');
      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update post',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost(String postId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.deletePost(postId);
      await _cacheService.clearByPrefix('feed_posts_');
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to delete post',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> likePost(String postId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final updated = await _remoteDatasource.likePost(postId);
      await _cacheService.clearByPrefix('feed_posts_');
      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to like post',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostCommentEntity>>> getComments(
    String postId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final comments = await _remoteDatasource.getComments(postId);
      return Right(comments.map((comment) => comment.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch comments',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createComment({
    required String postId,
    required String text,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.createComment(postId: postId, text: text.trim());
      await _cacheService.clearByPrefix('feed_posts_');
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to create comment',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      await _cacheService.clearByPrefix('feed_posts_');
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to delete comment',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
