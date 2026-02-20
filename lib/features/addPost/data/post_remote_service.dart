import 'dart:io';

import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/dashboard/data/models/post_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRemoteServiceProvider = Provider<PostRemoteService>((ref) {
  return PostRemoteService(apiClient: ref.read(apiClientProvider));
});

class PostRemoteService {
  PostRemoteService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<PostModel>> getPosts({int page = 1, int size = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.posts,
      queryParameters: {'page': page, 'size': size},
    );

    final List<dynamic> rawPosts = response.data['data'] as List<dynamic>? ?? [];
    return rawPosts
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PostModel>> getMyPosts({
    required String authId,
    int page = 1,
    int size = 50,
  }) async {
    final posts = await getPosts(page: page, size: size);
    return posts.where((post) => post.authorId == authId).toList();
  }

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
      final String fileName = mediaFile.path.split('/').last;
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

  Future<PostModel> likePost(String postId) async {
    final response = await _apiClient.post(ApiEndpoints.likePost(postId));
    final Map<String, dynamic> rawPost =
        response.data['data'] as Map<String, dynamic>;
    return PostModel.fromJson(rawPost);
  }

  Future<List<PostComment>> getComments(String postId) async {
    final response = await _apiClient.get(ApiEndpoints.postComments(postId));
    final List<dynamic> rawComments =
        response.data['data'] as List<dynamic>? ?? [];

    return rawComments
        .map((item) => PostComment.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
