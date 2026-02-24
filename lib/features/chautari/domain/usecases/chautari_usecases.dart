import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/chautari/data/repositories/chautari_repository.dart';
import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:chautari_kurakani/features/chautari/domain/repositories/chautari_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createChautariUsecaseProvider = Provider<CreateChautariUsecase>((ref) {
  return CreateChautariUsecase(ref.read(chautariRepositoryProvider));
});

final searchChautariUsecaseProvider = Provider<SearchChautariUsecase>((ref) {
  return SearchChautariUsecase(ref.read(chautariRepositoryProvider));
});
final getMyChautariUsecaseProvider = Provider<GetMyChautariUsecase>((ref) {
  return GetMyChautariUsecase(ref.read(chautariRepositoryProvider));
});

final getChautariByIdUsecaseProvider = Provider<GetChautariByIdUsecase>((ref) {
  return GetChautariByIdUsecase(ref.read(chautariRepositoryProvider));
});

final joinChautariUsecaseProvider = Provider<JoinChautariUsecase>((ref) {
  return JoinChautariUsecase(ref.read(chautariRepositoryProvider));
});

final leaveChautariUsecaseProvider = Provider<LeaveChautariUsecase>((ref) {
  return LeaveChautariUsecase(ref.read(chautariRepositoryProvider));
});

final getChautariMemberCountUsecaseProvider =
    Provider<GetChautariMemberCountUsecase>((ref) {
      return GetChautariMemberCountUsecase(
        ref.read(chautariRepositoryProvider),
      );
    });

final createChautariPostUsecaseProvider = Provider<CreateChautariPostUsecase>((
  ref,
) {
  return CreateChautariPostUsecase(ref.read(chautariRepositoryProvider));
});

final getChautariPostsUsecaseProvider = Provider<GetChautariPostsUsecase>((
  ref,
) {
  return GetChautariPostsUsecase(ref.read(chautariRepositoryProvider));
});

final deleteChautariUsecaseProvider = Provider<DeleteChautariUsecase>((ref) {
  return DeleteChautariUsecase(ref.read(chautariRepositoryProvider));
});

class CreateChautariParams extends Equatable {
  final String name;
  final String? description;
  final File? profileImage;

  const CreateChautariParams({
    required this.name,
    this.description,
    this.profileImage,
  });

  @override
  List<Object?> get props => [name, description, profileImage?.path];
}

class SearchChautariParams extends Equatable {
  final String search;
  final int page;
  final int size;

  const SearchChautariParams({
    required this.search,
    this.page = 1,
    this.size = 10,
  });

  @override
  List<Object?> get props => [search, page, size];
}

class MyChautariParams extends Equatable {
  final int page;
  final int size;

  const MyChautariParams({this.page = 1, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

class ChautariByIdParams extends Equatable {
  final String communityId;
  const ChautariByIdParams(this.communityId);

  @override
  List<Object?> get props => [communityId];
}

class ChautariMemberCountParams extends Equatable {
  final String communityId;
  const ChautariMemberCountParams(this.communityId);

  @override
  List<Object?> get props => [communityId];
}

class CreateChautariPostParams extends Equatable {
  final String communityId;
  final String? caption;
  final File? media;

  const CreateChautariPostParams({
    required this.communityId,
    this.caption,
    this.media,
  });

  @override
  List<Object?> get props => [communityId, caption, media?.path];
}

class GetChautariPostsParams extends Equatable {
  final String communityId;
  final int page;
  final int size;

  const GetChautariPostsParams({
    required this.communityId,
    this.page = 1,
    this.size = 10,
  });

  @override
  List<Object?> get props => [communityId, page, size];
}

class CreateChautariUsecase
    implements UsecaseWithParams<ChautariEntity, CreateChautariParams> {
  final IChautariRepository _repository;
  CreateChautariUsecase(this._repository);

  @override
  Future<Either<Failure, ChautariEntity>> call(CreateChautariParams params) {
    return _repository.createChautari(
      name: params.name,
      description: params.description,
      profileImage: params.profileImage,
    );
  }
}

class SearchChautariUsecase
    implements UsecaseWithParams<List<ChautariEntity>, SearchChautariParams> {
  final IChautariRepository _repository;
  SearchChautariUsecase(this._repository);

  @override
  Future<Either<Failure, List<ChautariEntity>>> call(
    SearchChautariParams params,
  ) {
    return _repository.searchChautaris(
      search: params.search,
      page: params.page,
      size: params.size,
    );
  }
}

class GetMyChautariUsecase
    implements UsecaseWithParams<List<ChautariEntity>, MyChautariParams> {
  final IChautariRepository _repository;
  GetMyChautariUsecase(this._repository);

  @override
  Future<Either<Failure, List<ChautariEntity>>> call(MyChautariParams params) {
    return _repository.getMyChautaris(page: params.page, size: params.size);
  }
}

class GetChautariByIdUsecase
    implements UsecaseWithParams<ChautariEntity, ChautariByIdParams> {
  final IChautariRepository _repository;
  GetChautariByIdUsecase(this._repository);

  @override
  Future<Either<Failure, ChautariEntity>> call(ChautariByIdParams params) {
    return _repository.getById(params.communityId);
  }
}

class JoinChautariUsecase
    implements UsecaseWithParams<ChautariEntity, ChautariByIdParams> {
  final IChautariRepository _repository;
  JoinChautariUsecase(this._repository);

  @override
  Future<Either<Failure, ChautariEntity>> call(ChautariByIdParams params) {
    return _repository.join(params.communityId);
  }
}

class LeaveChautariUsecase
    implements UsecaseWithParams<ChautariEntity, ChautariByIdParams> {
  final IChautariRepository _repository;
  LeaveChautariUsecase(this._repository);

  @override
  Future<Either<Failure, ChautariEntity>> call(ChautariByIdParams params) {
    return _repository.leave(params.communityId);
  }
}

class GetChautariMemberCountUsecase
    implements UsecaseWithParams<int, ChautariMemberCountParams> {
  final IChautariRepository _repository;
  GetChautariMemberCountUsecase(this._repository);

  @override
  Future<Either<Failure, int>> call(ChautariMemberCountParams params) {
    return _repository.getMemberCount(params.communityId);
  }
}

class CreateChautariPostUsecase
    implements UsecaseWithParams<bool, CreateChautariPostParams> {
  final IChautariRepository _repository;
  CreateChautariPostUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(CreateChautariPostParams params) {
    return _repository.createPost(
      communityId: params.communityId,
      caption: params.caption,
      media: params.media,
    );
  }
}

class GetChautariPostsUsecase
    implements UsecaseWithParams<ChautariPostsEntity, GetChautariPostsParams> {
  final IChautariRepository _repository;
  GetChautariPostsUsecase(this._repository);

  @override
  Future<Either<Failure, ChautariPostsEntity>> call(
    GetChautariPostsParams params,
  ) {
    return _repository.getPosts(
      communityId: params.communityId,
      page: params.page,
      size: params.size,
    );
  }
}

class DeleteChautariUsecase
    implements UsecaseWithParams<bool, ChautariByIdParams> {
  final IChautariRepository _repository;
  DeleteChautariUsecase(this._repository);

  @override
  Future<Either<Failure, bool>> call(ChautariByIdParams params) {
    return _repository.deleteChautari(params.communityId);
  }
}
