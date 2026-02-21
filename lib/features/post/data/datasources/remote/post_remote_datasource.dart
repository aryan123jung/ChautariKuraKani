import 'dart:io';

import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/post/data/datasources/post_datasource.dart';
import 'package:chautari_kurakani/features/post/data/models/post_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRemoteDatasourceProvider = Provider<IPostRemoteDatasource>((ref) {
  return PostRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class PostRemoteDatasource implements IPostRemoteDatasource {
  PostRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<PostApiModel>> getPosts({int page = 1, int size = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.posts,
      queryParameters: {'page': page, 'size': size},
    );

    final List<dynamic> rawPosts =
        response.data['data'] as List<dynamic>? ?? [];
    return rawPosts
        .map((item) => PostApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createPost({String? caption, File? mediaFile}) async {
    final String cleanedCaption = (caption ?? '').trim();
    if (cleanedCaption.isEmpty && mediaFile == null) {
      throw Exception('Post must contain either caption or media');
    }

    final formData = FormData();
    if (cleanedCaption.isNotEmpty) {
      formData.fields.add(MapEntry('caption', cleanedCaption));
    }

    if (mediaFile != null) {
      final fileName = mediaFile.path.split('/').last;
      formData.files.add(
        MapEntry(
          'media',
          await MultipartFile.fromFile(mediaFile.path, filename: fileName),
        ),
      );
    }

    await _apiClient.post(
      ApiEndpoints.posts,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  @override
  Future<PostApiModel> updatePost({
    required String postId,
    String? caption,
    File? mediaFile,
  }) async {
    final String cleanedCaption = (caption ?? '').trim();
    if (cleanedCaption.isEmpty && mediaFile == null) {
      throw Exception('Post must contain either caption or media');
    }

    final formData = FormData();
    formData.fields.add(MapEntry('caption', cleanedCaption));

    if (mediaFile != null) {
      final fileName = mediaFile.path.split('/').last;
      formData.files.add(
        MapEntry(
          'media',
          await MultipartFile.fromFile(mediaFile.path, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.put(
      '${ApiEndpoints.posts}/$postId',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final rawPost = response.data['data'] as Map<String, dynamic>;
    return PostApiModel.fromJson(rawPost);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _apiClient.delete('${ApiEndpoints.posts}/$postId');
  }

  @override
  Future<PostApiModel> likePost(String postId) async {
    final response = await _apiClient.post(ApiEndpoints.likePost(postId));
    final rawPost = response.data['data'] as Map<String, dynamic>;
    return PostApiModel.fromJson(rawPost);
  }

  @override
  Future<List<PostCommentApiModel>> getComments(String postId) async {
    final response = await _apiClient.get(ApiEndpoints.postComments(postId));
    final List<dynamic> rawComments =
        response.data['data'] as List<dynamic>? ?? [];

    return rawComments
        .map(
          (item) => PostCommentApiModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> createComment({
    required String postId,
    required String text,
  }) async {
    await _apiClient.post(
      ApiEndpoints.postComments(postId),
      data: {'text': text},
    );
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _apiClient.delete(ApiEndpoints.deletePostComment(postId, commentId));
  }
}
