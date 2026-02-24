import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String profileUrl;
  final String name;
  final String hoursAgo;
  final String caption;
  final String? communityId;
  final String? imageUrl;
  final String? videoUrl;
  final String? mediaType;
  final int likesCount;
  final List<String> likedUserIds;
  final int commentsCount;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.profileUrl,
    required this.name,
    required this.hoursAgo,
    required this.caption,
    this.communityId,
    this.imageUrl,
    this.videoUrl,
    this.mediaType,
    this.likesCount = 0,
    this.likedUserIds = const [],
    this.commentsCount = 0,
  });

  PostEntity copyWith({
    String? id,
    String? authorId,
    String? profileUrl,
    String? name,
    String? hoursAgo,
    String? caption,
    String? communityId,
    String? imageUrl,
    String? videoUrl,
    String? mediaType,
    int? likesCount,
    List<String>? likedUserIds,
    int? commentsCount,
  }) {
    return PostEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      profileUrl: profileUrl ?? this.profileUrl,
      name: name ?? this.name,
      hoursAgo: hoursAgo ?? this.hoursAgo,
      caption: caption ?? this.caption,
      communityId: communityId ?? this.communityId,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      mediaType: mediaType ?? this.mediaType,
      likesCount: likesCount ?? this.likesCount,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    authorId,
    profileUrl,
    name,
    hoursAgo,
    caption,
    communityId,
    imageUrl,
    videoUrl,
    mediaType,
    likesCount,
    likedUserIds,
    commentsCount,
  ];
}

class PostCommentEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String text;
  final String createdAtText;

  const PostCommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.text,
    required this.createdAtText,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userProfileUrl,
    text,
    createdAtText,
  ];
}
