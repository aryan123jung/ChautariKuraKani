import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';

class PostApiModel {
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

  PostApiModel({
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

  factory PostApiModel.fromJson(Map<String, dynamic> json) {
    final dynamic author = json['authorId'];
    final bool hasAuthorMap = author is Map<String, dynamic>;

    final String rawAuthorId = hasAuthorMap
        ? (author['_id']?.toString() ?? '')
        : (author?.toString() ?? '');

    final String firstName = hasAuthorMap
        ? (author['firstName']?.toString() ?? '')
        : '';
    final String lastName = hasAuthorMap
        ? (author['lastName']?.toString() ?? '')
        : '';

    final String displayName = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();

    final String rawProfile = hasAuthorMap
        ? ((author['profileImage'] ??
                      author['profileUrl'] ??
                      author['profilePicture'])
                  ?.toString() ??
              '')
        : '';

    final String mediaType = json['mediaType']?.toString() ?? '';
    final String rawMedia = json['mediaUrl']?.toString() ?? '';
    final dynamic rawCommunity = json['communityId'];
    final String? communityId = rawCommunity == null
        ? null
        : (rawCommunity is Map<String, dynamic>
              ? rawCommunity['_id']?.toString()
              : rawCommunity.toString());
    final List<dynamic> likesRaw = (json['likes'] as List<dynamic>? ?? []);
    final List<String> likedUserIds = likesRaw
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item['_id']?.toString() ?? '';
          }
          return item?.toString() ?? '';
        })
        .where((id) => id.trim().isNotEmpty)
        .toList(growable: false);
    final int likesCount = likedUserIds.length;
    final int commentsCount = json['commentsCount'] is int
        ? json['commentsCount'] as int
        : int.tryParse(json['commentsCount']?.toString() ?? '') ?? 0;

    final String? resolvedImageUrl = mediaType == 'image' && rawMedia.isNotEmpty
        ? ApiEndpoints.postMediaUrl(rawMedia, 'image')
        : null;

    final String? resolvedVideoUrl = mediaType == 'video' && rawMedia.isNotEmpty
        ? ApiEndpoints.postMediaUrl(rawMedia, 'video')
        : null;

    final DateTime? createdAt = DateTime.tryParse(
      json['createdAt']?.toString() ?? '',
    );

    return PostApiModel(
      id: json['_id']?.toString() ?? '',
      authorId: rawAuthorId,
      profileUrl: rawProfile.isNotEmpty ? _resolveProfileUrl(rawProfile) : '',
      name: displayName.isNotEmpty ? displayName : 'Unknown User',
      hoursAgo: _formatRelativeTime(createdAt),
      caption: json['caption']?.toString() ?? '',
      communityId: (communityId == null || communityId.trim().isEmpty)
          ? null
          : communityId.trim(),
      imageUrl: resolvedImageUrl,
      videoUrl: resolvedVideoUrl,
      mediaType: mediaType.isNotEmpty ? mediaType : null,
      likesCount: likesCount,
      likedUserIds: likedUserIds,
      commentsCount: commentsCount,
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      authorId: authorId,
      profileUrl: profileUrl,
      name: name,
      hoursAgo: hoursAgo,
      caption: caption,
      communityId: communityId,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      mediaType: mediaType,
      likesCount: likesCount,
      likedUserIds: likedUserIds,
      commentsCount: commentsCount,
    );
  }

  static String _formatRelativeTime(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';

    final Duration difference = DateTime.now().difference(createdAt);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${(difference.inDays / 7).floor()}w';
  }

  static String _resolveProfileUrl(String rawProfile) {
    if (rawProfile.startsWith('http')) {
      final uri = Uri.tryParse(rawProfile);
      if (uri != null && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        final path = uri.path.startsWith('/')
            ? uri.path.substring(1)
            : uri.path;
        return ApiEndpoints.uploadUrl(path);
      }
      return rawProfile;
    }
    if (rawProfile.contains('/') || rawProfile.contains('\\')) {
      return ApiEndpoints.uploadUrl(rawProfile);
    }
    return ApiEndpoints.profileImageUrl(rawProfile);
  }
}

class PostCommentApiModel {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final String text;
  final String createdAtText;

  PostCommentApiModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.text,
    required this.createdAtText,
  });

  factory PostCommentApiModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawUser = json['userId'];
    final bool hasUserMap = rawUser is Map<String, dynamic>;
    final String parsedUserId = hasUserMap
        ? (rawUser['_id']?.toString() ?? '')
        : (rawUser?.toString() ?? '');

    final String firstName = hasUserMap
        ? (rawUser['firstName']?.toString() ?? '')
        : '';
    final String lastName = hasUserMap
        ? (rawUser['lastName']?.toString() ?? '')
        : '';
    final String fullName = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();

    final String rawProfile = hasUserMap
        ? ((rawUser['profileImage'] ??
                      rawUser['profileUrl'] ??
                      rawUser['profilePicture'])
                  ?.toString() ??
              '')
        : '';

    final DateTime? createdAt = DateTime.tryParse(
      json['createdAt']?.toString() ?? '',
    );

    return PostCommentApiModel(
      id: json['_id']?.toString() ?? '',
      userId: parsedUserId.isNotEmpty ? parsedUserId : 'unknown',
      userName: fullName.isNotEmpty ? fullName : 'User',
      userProfileUrl: rawProfile.isNotEmpty
          ? PostApiModel._resolveProfileUrl(rawProfile)
          : null,
      text: json['text']?.toString() ?? '',
      createdAtText: PostApiModel._formatRelativeTime(createdAt),
    );
  }

  PostCommentEntity toEntity() {
    return PostCommentEntity(
      id: id,
      userId: userId,
      userName: userName,
      userProfileUrl: userProfileUrl,
      text: text,
      createdAtText: createdAtText,
    );
  }
}
