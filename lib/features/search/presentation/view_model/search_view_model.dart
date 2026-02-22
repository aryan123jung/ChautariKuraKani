import 'package:chautari_kurakani/features/search/domain/usecases/search_users_usecase.dart';
import 'package:chautari_kurakani/features/search/presentation/state/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(
  SearchViewModel.new,
);

class SearchViewModel extends Notifier<SearchState> {
  late final SearchUsersUsecase _searchUsersUsecase;

  @override
  SearchState build() {
    _searchUsersUsecase = ref.read(searchUsersUsecaseProvider);
    return const SearchState.initial();
  }

  Future<void> searchUsers({
    required String query,
    int page = 1,
    int size = 10,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const SearchState.initial();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading, errorMessage: null);

    final result = await _searchUsersUsecase(
      SearchUsersParams(query: trimmed, page: page, size: size),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
          users: const [],
        );
      },
      (users) {
        state = state.copyWith(
          status: SearchStatus.loaded,
          users: users,
          errorMessage: null,
        );
      },
    );
  }

  void clear() {
    state = const SearchState.initial();
  }
}
