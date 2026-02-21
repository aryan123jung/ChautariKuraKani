import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postViewModelProvider.notifier).fetchPosts();
    });
  }

  Future<void> _loadPosts() async {
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

    if (postState.status == PostStatus.loading && postState.posts.isEmpty) {
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
              ElevatedButton(onPressed: _loadPosts, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (postState.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No posts yet')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        itemCount: postState.posts.length,
        itemBuilder: (context, index) => PostCard(
          post: postState.posts[index],
          currentUserId: currentUserId,
          currentUserProfileUrl: currentUserProfile,
          currentUserName: currentUserName.isEmpty ? null : currentUserName,
          onPostChanged: _loadPosts,
        ),
      ),
    );
  }
}
