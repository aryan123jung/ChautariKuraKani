import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

enum PostStatus { initial, loading, loaded, submitting, success, error }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostEntity> posts;
  final List<PostEntity> myPosts;
  final Map<String, List<PostCommentEntity>> commentsByPostId;
  final String? errorMessage;

  const PostState({
    required this.status,
    this.posts = const [],
    this.myPosts = const [],
    this.commentsByPostId = const {},
    this.errorMessage,
  });

  const PostState.initial()
    : status = PostStatus.initial,
      posts = const [],
      myPosts = const [],
      commentsByPostId = const {},
      errorMessage = null;

  PostState copyWith({
    PostStatus? status,
    List<PostEntity>? posts,
    List<PostEntity>? myPosts,
    Map<String, List<PostCommentEntity>>? commentsByPostId,
    String? errorMessage,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      commentsByPostId: commentsByPostId ?? this.commentsByPostId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    myPosts,
    commentsByPostId,
    errorMessage,
  ];
}
