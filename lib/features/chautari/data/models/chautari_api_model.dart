import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';

class ChautariApiModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? profileUrl;
  final String creatorId;
  final List<String> memberIds;
  final DateTime? createdAt;

  const ChautariApiModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.profileUrl,
    required this.creatorId,
    this.memberIds = const [],
    this.createdAt,
  });

  factory ChautariApiModel.fromJson(Map<String, dynamic> json) {
    final creatorRaw = json['creatorId'];
    final creatorId = creatorRaw is Map<String, dynamic>
        ? (creatorRaw['_id']?.toString() ?? '')
        : (creatorRaw?.toString() ?? '');

    final membersRaw = json['members'] as List<dynamic>? ?? const [];
    final memberIds = membersRaw
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item['_id']?.toString() ?? '';
          }
          return item?.toString() ?? '';
        })
        .where((id) => id.trim().isNotEmpty)
        .toList(growable: false);

    final profile = json['profileUrl']?.toString();

    return ChautariApiModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      profileUrl: (profile == null || profile.trim().isEmpty)
          ? null
          : _resolveProfileUrl(profile),
      creatorId: creatorId,
      memberIds: memberIds,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  ChautariEntity toEntity() {
    return ChautariEntity(
      id: id,
      name: name,
      slug: slug,
      description: description,
      profileUrl: profileUrl,
      creatorId: creatorId,
      memberIds: memberIds,
      createdAt: createdAt,
    );
  }

  static String _resolveProfileUrl(String raw) {
    if (raw.startsWith('http')) return raw;
    if (raw.contains('/') || raw.contains('\\')) {
      return ApiEndpoints.uploadUrl(raw);
    }
    return ApiEndpoints.uploadUrl('uploads/chautari/profile/$raw');
  }
}
