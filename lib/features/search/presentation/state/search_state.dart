import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<SearchUserEntity> users;
  final String? errorMessage;

  const SearchState({
    required this.status,
    this.users = const [],
    this.errorMessage,
  });

  const SearchState.initial()
    : status = SearchStatus.initial,
      users = const [],
      errorMessage = null;

  SearchState copyWith({
    SearchStatus? status,
    List<SearchUserEntity>? users,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
