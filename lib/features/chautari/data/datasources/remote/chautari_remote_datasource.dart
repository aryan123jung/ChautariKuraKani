import 'dart:io';

import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/chautari/data/datasources/chautari_datasource.dart';
import 'package:chautari_kurakani/features/chautari/data/models/chautari_api_model.dart';
import 'package:chautari_kurakani/features/post/data/models/post_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chautariRemoteDatasourceProvider = Provider<IChautariRemoteDatasource>((
  ref,
) {
  return ChautariRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ChautariRemoteDatasource implements IChautariRemoteDatasource {
  final ApiClient _apiClient;

  ChautariRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ChautariApiModel> createChautari({
    required String name,
    String? description,
    File? profileImage,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('name', name.trim()));
    final cleanDescription = (description ?? '').trim();
    if (cleanDescription.isNotEmpty) {
      formData.fields.add(MapEntry('description', cleanDescription));
    }

    if (profileImage != null) {
      final fileName = profileImage.path.split('/').last;
      formData.files.add(
        MapEntry(
          'communityProfileUrl',
          await MultipartFile.fromFile(profileImage.path, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.chautari,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return ChautariApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ChautariApiModel> updateChautari({
    required String communityId,
    String? name,
    String? description,
    File? profileImage,
  }) async {
    final formData = FormData();
    final cleanName = (name ?? '').trim();
    final cleanDescription = (description ?? '').trim();

    if (cleanName.isNotEmpty) {
      formData.fields.add(MapEntry('name', cleanName));
    }
    if (cleanDescription.isNotEmpty) {
      formData.fields.add(MapEntry('description', cleanDescription));
    }
    if (profileImage != null) {
      final fileName = profileImage.path.split('/').last;
      formData.files.add(
        MapEntry(
          'communityProfileUrl',
          await MultipartFile.fromFile(profileImage.path, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.put(
      ApiEndpoints.chautariById(communityId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return ChautariApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ChautariApiModel>> searchChautaris({
    required String search,
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.searchChautari,
      queryParameters: {'search': search, 'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => ChautariApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChautariApiModel>> getMyChautaris({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myChautari,
      queryParameters: {'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => ChautariApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChautariApiModel> getById(String communityId) async {
    final response = await _apiClient.get(
      ApiEndpoints.chautariById(communityId),
    );
    return ChautariApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ChautariApiModel> join(String communityId) async {
    final response = await _apiClient.post(
      ApiEndpoints.joinChautari(communityId),
    );
    return ChautariApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<ChautariApiModel> leave(String communityId) async {
    final response = await _apiClient.post(
      ApiEndpoints.leaveChautari(communityId),
    );
    return ChautariApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<int> getMemberCount(String communityId) async {
    final response = await _apiClient.get(
      ApiEndpoints.chautariMemberCount(communityId),
    );
    final raw = (response.data['data'] as Map<String, dynamic>? ?? {})['count'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '0') ?? 0;
  }

  @override
  Future<int> getUserChautariCount(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.chautariCountByUser(userId),
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final totalRaw = data['total'];
    final joined = data['joinedCount'];

    final totalCount = totalRaw is int
        ? totalRaw
        : int.tryParse(totalRaw?.toString() ?? '');
    if (totalCount != null) {
      return totalCount;
    }

    final joinedCount = joined is int
        ? joined
        : int.tryParse(joined?.toString() ?? '0') ?? 0;
    return joinedCount;
  }

  @override
  Future<void> createPost({
    required String communityId,
    String? caption,
    File? media,
  }) async {
    final cleanCaption = (caption ?? '').trim();
    if (cleanCaption.isEmpty && media == null) {
      throw Exception('Post must contain either caption or media');
    }

    final formData = FormData();
    if (cleanCaption.isNotEmpty) {
      formData.fields.add(MapEntry('caption', cleanCaption));
    }

    if (media != null) {
      final fileName = media.path.split('/').last;
      formData.files.add(
        MapEntry(
          'media',
          await MultipartFile.fromFile(media.path, filename: fileName),
        ),
      );
    }

    await _apiClient.post(
      ApiEndpoints.chautariPosts(communityId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  @override
  Future<List<PostApiModel>> getPosts({
    required String communityId,
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.chautariPosts(communityId),
      queryParameters: {'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => PostApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deleteChautari(String communityId) async {
    await _apiClient.delete(ApiEndpoints.chautariById(communityId));
  }
}
