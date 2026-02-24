import 'dart:io';

import 'package:chautari_kurakani/features/chautari/data/models/chautari_api_model.dart';
import 'package:chautari_kurakani/features/post/data/models/post_api_model.dart';

abstract interface class IChautariRemoteDatasource {
  Future<ChautariApiModel> createChautari({
    required String name,
    String? description,
    File? profileImage,
  });

  Future<ChautariApiModel> updateChautari({
    required String communityId,
    String? name,
    String? description,
    File? profileImage,
  });

  Future<List<ChautariApiModel>> searchChautaris({
    required String search,
    int page = 1,
    int size = 10,
  });

  Future<List<ChautariApiModel>> getMyChautaris({int page = 1, int size = 20});

  Future<ChautariApiModel> getById(String communityId);

  Future<ChautariApiModel> join(String communityId);

  Future<ChautariApiModel> leave(String communityId);

  Future<int> getMemberCount(String communityId);
  Future<int> getUserChautariCount(String userId);

  Future<void> createPost({
    required String communityId,
    String? caption,
    File? media,
  });

  Future<List<PostApiModel>> getPosts({
    required String communityId,
    int page = 1,
    int size = 10,
  });

  Future<void> deleteChautari(String communityId);
}
