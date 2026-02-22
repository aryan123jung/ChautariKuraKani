import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';
import 'package:chautari_kurakani/features/post/presentation/state/post_state.dart';
import 'package:chautari_kurakani/features/post/presentation/view_model/post_view_model.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchedUserProfileScreen extends ConsumerStatefulWidget {
  final SearchUserEntity user;

  const SearchedUserProfileScreen({super.key, required this.user});

  @override
  ConsumerState<SearchedUserProfileScreen> createState() =>
      _SearchedUserProfileScreenState();
}

class _SearchedUserProfileScreenState
    extends ConsumerState<SearchedUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postViewModelProvider.notifier).fetchPosts();
    });
  }

  Future<void> _reload() async {
    await ref.read(postViewModelProvider.notifier).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final postState = ref.watch(postViewModelProvider);

    final currentUserId = authState.authEntity?.authId;
    final currentUserProfile = authState.authEntity?.profilePicture;
    final currentUserName = [
      authState.authEntity?.fName ?? '',
      authState.authEntity?.lName ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();

    final targetId = widget.user.id.trim().toLowerCase();
    final userPosts = postState.posts
        .where((post) => post.authorId.trim().toLowerCase() == targetId)
        .toList();

    final isLoading =
        postState.status == PostStatus.loading && postState.posts.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.fullName.isEmpty ? 'Profile' : widget.user.fullName,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                children: [
                  _ProfileHeader(user: widget.user),
                  const SizedBox(height: 14),
                  Text(
                    'Posts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (userPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Center(child: Text('No posts available')),
                    )
                  else
                    ...userPosts.map(
                      (post) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PostCard(
                          post: post,
                          currentUserId: currentUserId,
                          currentUserProfileUrl: currentUserProfile,
                          currentUserName: currentUserName.isEmpty
                              ? null
                              : currentUserName,
                          onPostChanged: _reload,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final SearchUserEntity user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveProfile(user.profileUrl);
    final fullName = user.fullName.isEmpty ? 'User' : user.fullName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    fullName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text('@${user.username}'),
                const SizedBox(height: 2),
                Text(user.email, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveProfile(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http')) return value;
    if (value.contains('/') || value.contains('\\')) {
      return ApiEndpoints.uploadUrl(value);
    }
    return ApiEndpoints.profileImageUrl(value);
  }
}
