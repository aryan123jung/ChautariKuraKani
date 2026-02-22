import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/friend_request/data/repositories/friend_request_repository.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';
import 'package:chautari_kurakani/features/post/presentation/state/post_state.dart';
import 'package:chautari_kurakani/features/post/presentation/view_model/post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsFeedScreen extends ConsumerStatefulWidget {
  const FriendsFeedScreen({super.key});

  @override
  ConsumerState<FriendsFeedScreen> createState() => _FriendsFeedScreenState();
}

class _FriendsFeedScreenState extends ConsumerState<FriendsFeedScreen> {
  Set<String> _friendAuthorIds = <String>{};
  bool _isResolvingFriends = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFriendFeed);
  }

  Future<void> _loadFriendFeed() async {
    await ref.read(postViewModelProvider.notifier).fetchPosts();
    await _resolveFriendAuthorIds();
  }

  Future<void> _resolveFriendAuthorIds() async {
    final currentUserId = ref.read(authViewModelProvider).authEntity?.authId;
    final posts = ref.read(postViewModelProvider).posts;

    if (currentUserId == null || currentUserId.trim().isEmpty || posts.isEmpty) {
      if (!mounted) return;
      setState(() {
        _friendAuthorIds = <String>{};
        _isResolvingFriends = false;
      });
      return;
    }

    final normalizedCurrent = _normalizeId(currentUserId);
    final uniqueAuthorIds = posts
        .map((post) => _normalizeId(post.authorId))
        .where((id) => id.isNotEmpty && id != normalizedCurrent)
        .toSet();

    if (!mounted) return;
    setState(() {
      _isResolvingFriends = true;
    });

    try {
      final friendRepo = ref.read(friendRequestRepositoryProvider);
      final results = await Future.wait(
        uniqueAuthorIds.map((authorId) async {
          final statusResult = await friendRepo.getStatus(authorId);
          return statusResult.fold(
            (_) => null,
            (status) => status.status == 'FRIEND' ? authorId : null,
          );
        }),
      );

      if (!mounted) return;
      setState(() {
        _friendAuthorIds = results.whereType<String>().toSet();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingFriends = false;
        });
      }
    }
  }

  String _normalizeId(String value) => value.trim().toLowerCase();

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

    final normalizedCurrent = _normalizeId(currentUserId ?? '');
    final friendPosts = postState.posts.where((post) {
      final authorId = _normalizeId(post.authorId);
      if (authorId.isEmpty || authorId == normalizedCurrent) return false;
      return _friendAuthorIds.contains(authorId);
    }).toList();

    final showInitialLoader =
        (postState.status == PostStatus.loading && postState.posts.isEmpty) ||
        _isResolvingFriends;

    if (showInitialLoader && friendPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postState.status == PostStatus.error && postState.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load friend posts.\n${postState.errorMessage ?? "Unknown error"}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadFriendFeed,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (friendPosts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFriendFeed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No posts from friends yet')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFriendFeed,
      child: ListView.builder(
        itemCount: friendPosts.length,
        itemBuilder: (context, index) {
          final post = friendPosts[index];
          return PostCard(
            post: post,
            currentUserId: currentUserId,
            currentUserProfileUrl: currentUserProfile,
            currentUserName: currentUserName.isEmpty ? null : currentUserName,
            onPostChanged: _loadFriendFeed,
          );
        },
      ),
    );
  }
}
