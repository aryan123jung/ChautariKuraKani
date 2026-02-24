import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

enum ChautariUiStatus { initial, loading, loaded, submitting, success, error }

class ChautariState extends Equatable {
  final ChautariUiStatus status;
  final List<ChautariEntity> communities;
  final ChautariEntity? selected;
  final List<PostEntity> posts;
  final String searchText;
  final int? selectedMemberCount;
  final String? errorMessage;

  const ChautariState({
    required this.status,
    this.communities = const [],
    this.selected,
    this.posts = const [],
    this.searchText = '',
    this.selectedMemberCount,
    this.errorMessage,
  });

  const ChautariState.initial()
    : status = ChautariUiStatus.initial,
      communities = const [],
      selected = null,
      posts = const [],
      searchText = '',
      selectedMemberCount = null,
      errorMessage = null;

  ChautariState copyWith({
    ChautariUiStatus? status,
    List<ChautariEntity>? communities,
    ChautariEntity? selected,
    bool clearSelected = false,
    List<PostEntity>? posts,
    String? searchText,
    int? selectedMemberCount,
    bool clearMemberCount = false,
    String? errorMessage,
  }) {
    return ChautariState(
      status: status ?? this.status,
      communities: communities ?? this.communities,
      selected: clearSelected ? null : selected ?? this.selected,
      posts: posts ?? this.posts,
      searchText: searchText ?? this.searchText,
      selectedMemberCount: clearMemberCount
          ? null
          : (selectedMemberCount ?? this.selectedMemberCount),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    communities,
    selected,
    posts,
    searchText,
    selectedMemberCount,
    errorMessage,
  ];
}
