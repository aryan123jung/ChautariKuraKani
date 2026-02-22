import 'dart:io';

import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/post/domain/entities/post_entity.dart';
import 'package:chautari_kurakani/features/post/presentation/view_model/post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostEntity post;
  final String? currentUserId;
  final String? currentUserProfileUrl;
  final String? currentUserName;
  final String? postAuthorProfileUrl;
  final Future<void> Function()? onPostChanged;

  const PostCard({
    super.key,
    required this.post,
    this.currentUserId,
    this.currentUserProfileUrl,
    this.currentUserName,
    this.postAuthorProfileUrl,
    this.onPostChanged,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late int _likesCount;
  late int _commentsCount;
  bool _isLiking = false;
  bool _hasLiked = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _commentsCount = widget.post.commentsCount;
  }

  Future<void> _likePost() async {
    if (_isLiking || _hasLiked) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final updatedPost = await ref
          .read(postViewModelProvider.notifier)
          .likePost(widget.post.id);

      if (updatedPost == null) {
        throw Exception(
          ref.read(postViewModelProvider).errorMessage ?? 'Failed to like post',
        );
      }

      if (!mounted) return;
      setState(() {
        _likesCount = updatedPost.likesCount;
        _hasLiked = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to like post: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  Future<void> _showCommentsModal() async {
    List<PostCommentEntity> comments = await ref
        .read(postViewModelProvider.notifier)
        .fetchComments(widget.post.id);
    final commentController = TextEditingController();
    bool isSubmitting = false;

    if (!mounted) return;

    setState(() {
      _commentsCount = comments.length;
    });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> refreshComments() async {
              comments = await ref
                  .read(postViewModelProvider.notifier)
                  .fetchComments(widget.post.id);
              if (!mounted) return;
              setState(() {
                _commentsCount = comments.length;
              });
              setModalState(() {});
            }

            Future<void> onAddComment() async {
              final text = commentController.text.trim();
              if (text.isEmpty || isSubmitting) return;
              setModalState(() => isSubmitting = true);

              final success = await ref
                  .read(postViewModelProvider.notifier)
                  .createComment(postId: widget.post.id, text: text);

              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(postViewModelProvider).errorMessage ??
                          'Failed to add comment',
                    ),
                  ),
                );
              } else {
                commentController.clear();
                await refreshComments();
              }
              if (!context.mounted) return;
              setModalState(() => isSubmitting = false);
            }

            Future<void> onDeleteComment(String commentId) async {
              if (isSubmitting) return;
              setModalState(() => isSubmitting = true);

              final success = await ref
                  .read(postViewModelProvider.notifier)
                  .deleteComment(postId: widget.post.id, commentId: commentId);

              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(postViewModelProvider).errorMessage ??
                          'Failed to delete comment',
                    ),
                  ),
                );
              } else {
                await refreshComments();
              }
              if (!context.mounted) return;
              setModalState(() => isSubmitting = false);
            }

            final currentUserId = (widget.currentUserId ?? '')
                .trim()
                .toLowerCase();

            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Expanded(
                      child: comments.isEmpty
                          ? const Center(child: Text('No comments yet.'))
                          : ListView.separated(
                              itemCount: comments.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                final canDelete =
                                    currentUserId.isNotEmpty &&
                                    comment.userId.trim().toLowerCase() ==
                                        currentUserId;
                                final displayName = canDelete
                                    ? (widget.currentUserName ?? 'You')
                                    : comment.userName;
                                final avatarUrl = canDelete
                                    ? _resolveProfileInput(
                                        widget.currentUserProfileUrl,
                                      )
                                    : comment.userProfileUrl;

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage: avatarUrl != null
                                            ? NetworkImage(avatarUrl)
                                            : null,
                                        child: avatarUrl == null
                                            ? Text(
                                                (displayName.trim().isEmpty
                                                        ? 'U'
                                                        : displayName.trim()[0])
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            10,
                                            12,
                                            10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F5F7),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      displayName.trim().isEmpty
                                                          ? 'User'
                                                          : displayName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    comment.createdAtText,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                comment.text,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (canDelete) ...[
                                        const SizedBox(width: 6),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: isSubmitting
                                              ? null
                                              : () =>
                                                    onDeleteComment(comment.id),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: isSubmitting ? null : onAddComment,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    commentController.dispose();
  }

  Future<void> _deletePost() async {
    if (_isBusy) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isBusy = true);
    try {
      final isDeleted = await ref
          .read(postViewModelProvider.notifier)
          .deletePost(widget.post.id);

      if (!isDeleted) {
        throw Exception(
          ref.read(postViewModelProvider).errorMessage ??
              'Failed to delete post',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post deleted')));
      await widget.onPostChanged?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _showEditPostModal() async {
    final captionController = TextEditingController(text: widget.post.caption);
    final imagePicker = ImagePicker();
    File? selectedMedia;
    String? selectedMediaType;

    Future<void> pickImage(StateSetter setModalState) async {
      final XFile? picked = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1500,
      );
      if (picked == null) return;
      setModalState(() {
        selectedMedia = File(picked.path);
        selectedMediaType = 'image';
      });
    }

    Future<void> pickVideo(StateSetter setModalState) async {
      final XFile? picked = await imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      if (picked == null) return;
      setModalState(() {
        selectedMedia = File(picked.path);
        selectedMediaType = 'video';
      });
    }

    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Post',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Caption',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickImage(setModalState),
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Image'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickVideo(setModalState),
                            icon: const Icon(Icons.video_library_outlined),
                            label: const Text('Video'),
                          ),
                        ),
                      ],
                    ),
                    if (selectedMedia != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        selectedMediaType == 'video'
                            ? 'New video selected'
                            : 'New image selected',
                      ),
                    ],
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
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (shouldSave != true) return;

    final updatedCaption = captionController.text.trim();

    if (updatedCaption.isEmpty && selectedMedia == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post must contain either caption or media'),
        ),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final updated = await ref
          .read(postViewModelProvider.notifier)
          .updatePost(
            postId: widget.post.id,
            caption: updatedCaption,
            mediaFile: selectedMedia,
          );

      if (updated == null) {
        throw Exception(
          ref.read(postViewModelProvider).errorMessage ??
              'Failed to update post',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post updated')));
      await widget.onPostChanged?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update post: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    final isTablet = screenWidth > 600;

    final cardWidth = isTablet
        ? (orientation == Orientation.landscape
              ? screenWidth * 0.5
              : screenWidth * 0.6)
        : screenWidth;

    final cardPadding = isTablet ? 16.0 : 10.0;
    final nameFont = isTablet ? 20.0 : 16.5;
    final captionFont = isTablet ? 18.0 : 15.0;
    final timeFont = isTablet ? 14.0 : 12.0;
    final avatarRadius = isTablet ? 36.0 : 28.0;

    final isMyPost =
        widget.currentUserId != null &&
        widget.currentUserId!.isNotEmpty &&
        widget.post.authorId == widget.currentUserId;

    final fallbackProfileUrl = isMyPost
        ? _resolveProfileInput(widget.currentUserProfileUrl)
        : null;
    final authorFallbackProfileUrl = _resolveProfileInput(
      widget.postAuthorProfileUrl,
    );

    final displayProfileUrl = widget.post.profileUrl.isNotEmpty
        ? widget.post.profileUrl
        : (fallbackProfileUrl ?? authorFallbackProfileUrl ?? '');

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
            side: const BorderSide(color: Color(0xFFDBDBDB), width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: avatarRadius * 2,
                      width: avatarRadius * 2,
                      child: ClipOval(
                        child: displayProfileUrl.isNotEmpty
                            ? Image.network(
                                displayProfileUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.person),
                                ),
                              )
                            : Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.person),
                              ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.name,
                          style: TextStyle(
                            fontSize: nameFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.post.hoursAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: timeFont,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isMyPost)
                      PopupMenuButton<String>(
                        enabled: !_isBusy,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditPostModal();
                          } else if (value == 'delete') {
                            _deletePost();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.more_horiz),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (widget.post.caption.trim().isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: Text(
                      widget.post.caption,
                      style: TextStyle(
                        fontSize: captionFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                ],
                if (widget.post.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.72,
                      ),
                      child: Image.network(
                        widget.post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 220,
                          child: Center(child: Text('Failed to load image')),
                        ),
                      ),
                    ),
                  ),
                if (widget.post.videoUrl != null)
                  _PostVideoPlayer(url: widget.post.videoUrl!),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: _likePost,
                      icon: Icon(
                        _hasLiked ? Icons.favorite : Icons.favorite_border,
                        color: _hasLiked ? Colors.red : null,
                      ),
                      label: Text('$_likesCount'),
                    ),
                    TextButton.icon(
                      onPressed: _showCommentsModal,
                      icon: const Icon(Icons.comment_outlined),
                      label: Text('$_commentsCount'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _resolveProfileInput(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http')) return value;
    if (value.contains('/') || value.contains('\\')) {
      return ApiEndpoints.uploadUrl(value);
    }
    return ApiEndpoints.profileImageUrl(value);
  }
}

class _PostVideoPlayer extends StatefulWidget {
  final String url;

  const _PostVideoPlayer({required this.url});

  @override
  State<_PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<_PostVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isReady = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.72;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: !_isReady
            ? const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio == 0
                      ? 9 / 16
                      : _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
