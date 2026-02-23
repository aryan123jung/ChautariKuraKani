import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/friend_request/data/repositories/friend_request_repository.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';
import 'package:chautari_kurakani/features/post/presentation/state/post_state.dart';
import 'package:chautari_kurakani/features/post/presentation/view_model/post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  Set<String> _friendAuthorIds = <String>{};
  bool _isResolvingFriends = false;
  bool _friendFilterReady = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadPosts(forceFetchPosts: false));
  }

  Future<void> _loadPosts({bool forceFetchPosts = true}) async {
    if (mounted) {
      setState(() {
        _isResolvingFriends = true;
        _friendFilterReady = false;
      });
    }
    final postState = ref.read(postViewModelProvider);
    final hasPosts = postState.posts.isNotEmpty;
    if (forceFetchPosts || !hasPosts) {
      await ref.read(postViewModelProvider.notifier).fetchPosts();
    }
    await _resolveFriendAuthorIds();
  }

  String _normalizeId(String value) => value.trim().toLowerCase();

  Future<void> _resolveFriendAuthorIds() async {
    final currentUserId = ref.read(authViewModelProvider).authEntity?.authId;
    final posts = ref.read(postViewModelProvider).posts;

    if (currentUserId == null ||
        currentUserId.trim().isEmpty ||
        posts.isEmpty) {
      if (!mounted) return;
      setState(() {
        _friendAuthorIds = <String>{};
        _isResolvingFriends = false;
        _friendFilterReady = true;
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
        _friendFilterReady = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingFriends = false;
        });
      }
    }
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
    final normalizedCurrentUserId = _normalizeId(currentUserId ?? '');
    final feedPosts = postState.posts.where((post) {
      final authorId = _normalizeId(post.authorId);
      if (authorId.isEmpty) return false;
      if (normalizedCurrentUserId.isNotEmpty &&
          authorId == normalizedCurrentUserId) {
        return false;
      }
      return !_friendAuthorIds.contains(authorId);
    }).toList();

    final showInitialLoader =
        (postState.status == PostStatus.loading && postState.posts.isEmpty) ||
        _isResolvingFriends;
    final waitForFriendFilter =
        postState.posts.isNotEmpty &&
        normalizedCurrentUserId.isNotEmpty &&
        !_friendFilterReady;

    if ((showInitialLoader && feedPosts.isEmpty) || waitForFriendFilter) {
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
                'Failed to load posts.\n${postState.errorMessage ?? "Unknown error"}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _loadPosts(forceFetchPosts: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (feedPosts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadPosts(forceFetchPosts: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No posts from non-friends yet')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPosts(forceFetchPosts: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 18),
        itemCount: feedPosts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => PostCard(
          post: feedPosts[index],
          currentUserId: currentUserId,
          currentUserProfileUrl: currentUserProfile,
          currentUserName: currentUserName.isEmpty ? null : currentUserName,
          onPostChanged: () => _loadPosts(forceFetchPosts: true),
        ),
      ),
    );
  }
}
