import 'package:chautari_kurakani/core/api/api_endpoints.dart';

class PostModel {
  final String id;
  final String authorId;
  final String profileUrl;
  final String name;
  final String hoursAgo;
  final String caption;
  final String? imageUrl;
  final String? videoUrl;
  final String? mediaType;
  final int likesCount;
  final int commentsCount;
  final bool isPoll;

  PostModel({
    required this.id,
    required this.authorId,
    required this.profileUrl,
    required this.name,
    required this.hoursAgo,
    required this.caption,
    this.imageUrl,
    this.videoUrl,
    this.mediaType,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPoll = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
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
    final int likesCount = (json['likes'] as List<dynamic>? ?? []).length;
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

    return PostModel(
      id: json['_id']?.toString() ?? '',
      authorId: rawAuthorId,
      profileUrl: rawProfile.isNotEmpty ? _resolveProfileUrl(rawProfile) : '',
      name: displayName.isNotEmpty ? displayName : 'Unknown User',
      hoursAgo: _formatRelativeTime(createdAt),
      caption: json['caption']?.toString() ?? '',
      imageUrl: resolvedImageUrl,
      videoUrl: resolvedVideoUrl,
      mediaType: mediaType.isNotEmpty ? mediaType : null,
      likesCount: likesCount,
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
    if (rawProfile.startsWith('http')) return rawProfile;
    if (rawProfile.contains('/')) return ApiEndpoints.uploadUrl(rawProfile);
    return ApiEndpoints.profileImageUrl(rawProfile);
  }
}

class PostComment {
  final String id;
  final String userId;
  final String text;
  final String createdAtText;

  PostComment({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAtText,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final dynamic rawUser = json['userId'];
    final String parsedUserId = rawUser is Map<String, dynamic>
        ? (rawUser['_id']?.toString() ?? 'Unknown user')
        : (rawUser?.toString() ?? 'Unknown user');

    final DateTime? createdAt = DateTime.tryParse(
      json['createdAt']?.toString() ?? '',
    );

    return PostComment(
      id: json['_id']?.toString() ?? '',
      userId: parsedUserId,
      text: json['text']?.toString() ?? '',
      createdAtText: PostModel._formatRelativeTime(createdAt),
    );
  }
}
