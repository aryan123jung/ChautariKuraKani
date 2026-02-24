import 'dart:io';

import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:chautari_kurakani/features/chautari/presentation/state/chautari_state.dart';
import 'package:chautari_kurakani/features/chautari/presentation/view_model/chautari_view_model.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChautariDetailScreen extends ConsumerStatefulWidget {
  final ChautariEntity community;

  const ChautariDetailScreen({super.key, required this.community});

  @override
  ConsumerState<ChautariDetailScreen> createState() =>
      _ChautariDetailScreenState();
}

class _ChautariDetailScreenState extends ConsumerState<ChautariDetailScreen> {
  late ChautariEntity _community;

  Future<bool> _confirmLeave(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Chautari'),
        content: Text('Do you want to leave "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return confirm == true;
  }

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    Future.microtask(() async {
      await ref
          .read(chautariViewModelProvider.notifier)
          .loadDetails(_community.id);
      await ref
          .read(chautariViewModelProvider.notifier)
          .refreshSelectedMemberCount();
      await ref
          .read(chautariViewModelProvider.notifier)
          .loadPosts(communityId: _community.id, size: 20);
    });
  }

  Future<void> _refresh() async {
    await ref
        .read(chautariViewModelProvider.notifier)
        .loadDetails(_community.id);
    await ref
        .read(chautariViewModelProvider.notifier)
        .refreshSelectedMemberCount();
    await ref
        .read(chautariViewModelProvider.notifier)
        .loadPosts(communityId: _community.id, size: 20);
  }

  Future<void> _showCreatePostSheet() async {
    final textController = TextEditingController();
    File? selectedMedia;
    final picker = ImagePicker();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Post in Chautari',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Write something...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (picked == null) return;
                          setModalState(
                            () => selectedMedia = File(picked.path),
                          );
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Image'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await picker.pickVideo(
                            source: ImageSource.gallery,
                          );
                          if (picked == null) return;
                          setModalState(
                            () => selectedMedia = File(picked.path),
                          );
                        },
                        icon: const Icon(Icons.videocam_outlined),
                        label: const Text('Video'),
                      ),
                    ),
                  ],
                ),
                if (selectedMedia != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Media selected'),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (ok != true) return;

    final success = await ref
        .read(chautariViewModelProvider.notifier)
        .createPost(
          communityId: _community.id,
          caption: textController.text.trim(),
          media: selectedMedia,
        );

    if (!mounted) return;
    if (!success) {
      final err = ref.read(chautariViewModelProvider).errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Failed to create post')));
      return;
    }

    await ref
        .read(chautariViewModelProvider.notifier)
        .loadPosts(communityId: _community.id, size: 20);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post created')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chautariViewModelProvider);
    final auth = ref.watch(authViewModelProvider).authEntity;
    final currentUserId = auth?.authId;

    final selected = state.selected?.id == _community.id
        ? state.selected!
        : _community;
    _community = selected;

    final isCreator = selected.isCreatedBy(currentUserId);
    final isJoined = selected.isJoinedBy(currentUserId);
    final members = state.selectedMemberCount ?? selected.memberCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(selected.name),
        actions: [
          if (isCreator)
            IconButton(
              tooltip: 'Delete Chautari',
              onPressed: () async {
                final messenger = ScaffoldMessenger.maybeOf(context);
                final navigator = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Chautari'),
                    content: const Text(
                      'Are you sure? This will delete all posts in this Chautari.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;

                final ok = await ref
                    .read(chautariViewModelProvider.notifier)
                    .deleteChautari(selected.id);
                if (!mounted) return;
                if (!ok) {
                  final err = ref.read(chautariViewModelProvider).errorMessage;
                  messenger?.showSnackBar(
                    SnackBar(content: Text(err ?? 'Failed to delete Chautari')),
                  );
                  return;
                }
                navigator.pop(true);
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      floatingActionButton: isJoined
          ? FloatingActionButton.extended(
              heroTag: 'chautari_detail_post_fab',
              onPressed: _showCreatePostSheet,
              icon: const Icon(Icons.add),
              label: const Text('Post'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: selected.profileUrl != null
                      ? NetworkImage(selected.profileUrl!)
                      : null,
                  child: selected.profileUrl == null
                      ? Text(
                          selected.name.isEmpty
                              ? 'C'
                              : selected.name.trim()[0].toUpperCase(),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.slug.isNotEmpty
                            ? selected.slug
                            : selected.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected.description.isEmpty
                            ? 'No description'
                            : selected.description,
                      ),
                      const SizedBox(height: 8),
                      Text('$members members'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!isCreator)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: () async {
                    if (isJoined) {
                      final shouldLeave = await _confirmLeave(selected.name);
                      if (!shouldLeave) return;
                    }
                    final ok = isJoined
                        ? await ref
                              .read(chautariViewModelProvider.notifier)
                              .leave(selected.id)
                        : await ref
                              .read(chautariViewModelProvider.notifier)
                              .join(selected.id);
                    if (!mounted || !ok) return;
                    await ref
                        .read(chautariViewModelProvider.notifier)
                        .refreshSelectedMemberCount();
                  },
                  child: Text(isJoined ? 'Leave' : 'Join'),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Posts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (state.status == ChautariUiStatus.loading && state.posts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.posts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No posts in this Chautari yet')),
              )
            else
              ...state.posts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(
                    post: post,
                    currentUserId: currentUserId,
                    currentUserProfileUrl: auth?.profilePicture,
                    currentUserName: [
                      auth?.fName ?? '',
                      auth?.lName ?? '',
                    ].where((e) => e.trim().isNotEmpty).join(' ').trim(),
                    canDeleteOthersPost:
                        selected.isCreatedBy(currentUserId) &&
                        post.authorId != (currentUserId ?? ''),
                    canModerateComments: selected.isCreatedBy(currentUserId),
                    onPostChanged: () async {
                      await ref
                          .read(chautariViewModelProvider.notifier)
                          .loadPosts(communityId: selected.id, size: 20);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
