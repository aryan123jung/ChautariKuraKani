import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IChautariRepository {
  Future<Either<Failure, ChautariEntity>> createChautari({
    required String name,
    String? description,
    File? profileImage,
  });

  Future<Either<Failure, ChautariEntity>> updateChautari({
    required String communityId,
    String? name,
    String? description,
    File? profileImage,
  });

  Future<Either<Failure, List<ChautariEntity>>> searchChautaris({
    required String search,
    int page = 1,
    int size = 10,
  });

  Future<Either<Failure, List<ChautariEntity>>> getMyChautaris({
    int page = 1,
    int size = 20,
  });

  Future<Either<Failure, ChautariEntity>> getById(String communityId);

  Future<Either<Failure, ChautariEntity>> join(String communityId);

  Future<Either<Failure, ChautariEntity>> leave(String communityId);

  Future<Either<Failure, int>> getMemberCount(String communityId);
  Future<Either<Failure, int>> getUserChautariCount(String userId);

  Future<Either<Failure, bool>> createPost({
    required String communityId,
    String? caption,
    File? media,
  });

  Future<Either<Failure, ChautariPostsEntity>> getPosts({
    required String communityId,
    int page = 1,
    int size = 10,
  });

  Future<Either<Failure, bool>> deleteChautari(String communityId);
}
