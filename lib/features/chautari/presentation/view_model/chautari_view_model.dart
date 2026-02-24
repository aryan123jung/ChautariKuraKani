import 'dart:io';

import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:chautari_kurakani/features/chautari/domain/usecases/chautari_usecases.dart';
import 'package:chautari_kurakani/features/chautari/presentation/state/chautari_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chautariViewModelProvider =
    NotifierProvider<ChautariViewModel, ChautariState>(ChautariViewModel.new);
final homeChautariViewModelProvider =
    NotifierProvider<ChautariViewModel, ChautariState>(ChautariViewModel.new);

class ChautariViewModel extends Notifier<ChautariState> {
  late final CreateChautariUsecase _createUsecase;
  late final SearchChautariUsecase _searchUsecase;
  late final UpdateChautariUsecase _updateUsecase;
  late final GetMyChautariUsecase _getMyUsecase;
  late final GetChautariByIdUsecase _detailUsecase;
  late final JoinChautariUsecase _joinUsecase;
  late final LeaveChautariUsecase _leaveUsecase;
  late final GetChautariMemberCountUsecase _memberCountUsecase;
  late final CreateChautariPostUsecase _createPostUsecase;
  late final GetChautariPostsUsecase _getPostsUsecase;
  late final DeleteChautariUsecase _deleteUsecase;

  @override
  ChautariState build() {
    _createUsecase = ref.read(createChautariUsecaseProvider);
    _searchUsecase = ref.read(searchChautariUsecaseProvider);
    _updateUsecase = ref.read(updateChautariUsecaseProvider);
    _getMyUsecase = ref.read(getMyChautariUsecaseProvider);
    _detailUsecase = ref.read(getChautariByIdUsecaseProvider);
    _joinUsecase = ref.read(joinChautariUsecaseProvider);
    _leaveUsecase = ref.read(leaveChautariUsecaseProvider);
    _memberCountUsecase = ref.read(getChautariMemberCountUsecaseProvider);
    _createPostUsecase = ref.read(createChautariPostUsecaseProvider);
    _getPostsUsecase = ref.read(getChautariPostsUsecaseProvider);
    _deleteUsecase = ref.read(deleteChautariUsecaseProvider);
    return const ChautariState.initial();
  }

  Future<void> search({
    required String rawQuery,
    int page = 1,
    int size = 10,
  }) async {
    final query = rawQuery.trim();
    state = state.copyWith(
      status: ChautariUiStatus.loading,
      searchText: query,
      errorMessage: null,
    );

    if (query.isEmpty) {
      state = state.copyWith(
        status: ChautariUiStatus.loaded,
        communities: const [],
        errorMessage: null,
      );
      return;
    }

    final normalized = query.toLowerCase();
    if (!normalized.startsWith('c/')) {
      state = state.copyWith(
        status: ChautariUiStatus.error,
        communities: const [],
        errorMessage: 'Search must start with c/',
      );
      return;
    }

    final result = await _searchUsecase(
      SearchChautariParams(search: query, page: page, size: size),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          communities: const [],
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          status: ChautariUiStatus.loaded,
          communities: items,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> loadMy({int page = 1, int size = 20}) async {
    state = state.copyWith(
      status: ChautariUiStatus.loading,
      errorMessage: null,
      searchText: '',
    );

    final result = await _getMyUsecase(
      MyChautariParams(page: page, size: size),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          communities: const [],
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          status: ChautariUiStatus.loaded,
          communities: items,
          errorMessage: null,
        );
      },
    );
  }

  Future<bool> create({
    required String name,
    String? description,
    File? profileImage,
  }) async {
    state = state.copyWith(
      status: ChautariUiStatus.submitting,
      errorMessage: null,
    );

    final result = await _createUsecase(
      CreateChautariParams(
        name: name.trim(),
        description: description,
        profileImage: profileImage,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (created) {
        final next = [created, ...state.communities];
        state = state.copyWith(
          status: ChautariUiStatus.success,
          communities: next,
          selected: created,
          selectedMemberCount: created.memberCount,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> update({
    required String communityId,
    String? name,
    String? description,
    File? profileImage,
  }) async {
    state = state.copyWith(
      status: ChautariUiStatus.submitting,
      errorMessage: null,
    );

    final result = await _updateUsecase(
      UpdateChautariParams(
        communityId: communityId,
        name: name,
        description: description,
        profileImage: profileImage,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updated) {
        _replaceInList(updated);
        state = state.copyWith(
          status: ChautariUiStatus.success,
          selected: state.selected?.id == updated.id ? updated : state.selected,
          selectedMemberCount: updated.memberCount,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> loadDetails(String communityId) async {
    state = state.copyWith(
      status: ChautariUiStatus.loading,
      errorMessage: null,
    );
    final result = await _detailUsecase(ChautariByIdParams(communityId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (item) {
        state = state.copyWith(
          status: ChautariUiStatus.loaded,
          selected: item,
          selectedMemberCount: item.memberCount,
          errorMessage: null,
        );
        _replaceInList(item);
        return true;
      },
    );
  }

  Future<void> refreshSelectedMemberCount() async {
    final selected = state.selected;
    if (selected == null) return;

    final result = await _memberCountUsecase(
      ChautariMemberCountParams(selected.id),
    );

    result.fold((_) {}, (count) {
      state = state.copyWith(selectedMemberCount: count);
    });
  }

  Future<bool> join(String communityId) async {
    state = state.copyWith(
      status: ChautariUiStatus.submitting,
      errorMessage: null,
    );
    final result = await _joinUsecase(ChautariByIdParams(communityId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updated) {
        _replaceInList(updated);
        state = state.copyWith(
          status: ChautariUiStatus.success,
          selected: state.selected?.id == updated.id ? updated : state.selected,
          selectedMemberCount: updated.memberCount,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> leave(String communityId) async {
    state = state.copyWith(
      status: ChautariUiStatus.submitting,
      errorMessage: null,
    );
    final result = await _leaveUsecase(ChautariByIdParams(communityId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updated) {
        _replaceInList(updated);
        state = state.copyWith(
          status: ChautariUiStatus.success,
          selected: state.selected?.id == updated.id ? updated : state.selected,
          selectedMemberCount: updated.memberCount,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> loadPosts({
    required String communityId,
    int page = 1,
    int size = 10,
  }) async {
    state = state.copyWith(
      status: ChautariUiStatus.loading,
      errorMessage: null,
    );
    final result = await _getPostsUsecase(
      GetChautariPostsParams(communityId: communityId, page: page, size: size),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          posts: const [],
          errorMessage: failure.message,
        );
        return false;
      },
      (payload) {
        state = state.copyWith(
          status: ChautariUiStatus.loaded,
          posts: payload.posts,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> createPost({
    required String communityId,
    String? caption,
    File? media,
  }) async {
    state = state.copyWith(
      status: ChautariUiStatus.submitting,
      errorMessage: null,
    );

    final result = await _createPostUsecase(
      CreateChautariPostParams(
        communityId: communityId,
        caption: caption,
        media: media,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: ChautariUiStatus.success,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> deleteChautari(String communityId) async {
    state = state.copyWith(
      status: ChautariUiStatus.submitting,
      errorMessage: null,
    );
    final result = await _deleteUsecase(ChautariByIdParams(communityId));

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ChautariUiStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final next = state.communities
            .where((e) => e.id != communityId)
            .toList();
        state = state.copyWith(
          status: ChautariUiStatus.success,
          communities: next,
          clearSelected: true,
          clearMemberCount: true,
          posts: const [],
          errorMessage: null,
        );
        return true;
      },
    );
  }

  void _replaceInList(ChautariEntity item) {
    final index = state.communities.indexWhere((e) => e.id == item.id);
    if (index < 0) return;
    final next = List<ChautariEntity>.from(state.communities);
    next[index] = item;
    state = state.copyWith(communities: next);
  }
}
