import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

class ChautariEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? profileUrl;
  final String creatorId;
  final List<String> memberIds;
  final DateTime? createdAt;

  const ChautariEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.profileUrl,
    required this.creatorId,
    this.memberIds = const [],
    this.createdAt,
  });

  int get memberCount => memberIds.length;

  bool isJoinedBy(String? userId) {
    final normalized = (userId ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return memberIds.any((id) => id.trim().toLowerCase() == normalized);
  }

  bool isCreatedBy(String? userId) {
    final normalized = (userId ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return creatorId.trim().toLowerCase() == normalized;
  }

  ChautariEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? profileUrl,
    String? creatorId,
    List<String>? memberIds,
    DateTime? createdAt,
  }) {
    return ChautariEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      profileUrl: profileUrl ?? this.profileUrl,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    profileUrl,
    creatorId,
    memberIds,
    createdAt,
  ];
}

class ChautariPostsEntity extends Equatable {
  final List<PostEntity> posts;
  final int page;
  final int size;
  final int total;
  final int totalPages;

  const ChautariPostsEntity({
    this.posts = const [],
    this.page = 1,
    this.size = 10,
    this.total = 0,
    this.totalPages = 0,
  });

  @override
  List<Object?> get props => [posts, page, size, total, totalPages];
}
