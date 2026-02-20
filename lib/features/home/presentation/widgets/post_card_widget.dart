import 'package:chautari_kurakani/features/addPost/data/post_remote_service.dart';
import 'package:chautari_kurakani/features/dashboard/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late int _likesCount;
  late int _commentsCount;
  bool _isLiking = false;
  bool _hasLiked = false;

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
          .read(postRemoteServiceProvider)
          .likePost(widget.post.id);
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
      if (!mounted) return;
      setState(() {
        _isLiking = false;
      });
    }
  }

  Future<void> _showCommentsModal() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<PostComment>>(
                    future: ref
                        .read(postRemoteServiceProvider)
                        .getComments(widget.post.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Failed to load comments: ${snapshot.error}'),
                        );
                      }

                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return const Center(child: Text('No comments yet.'));
                      }

                      _commentsCount = comments.length;

                      return ListView.separated(
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person, size: 18),
                            ),
                            title: Text(comment.text),
                            subtitle: Text(
                              '${comment.userId} • ${comment.createdAtText}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    bool isTablet = screenWidth > 600;

    double cardWidth = isTablet
        ? (orientation == Orientation.landscape
              ? screenWidth * 0.5
              : screenWidth * 0.6)
        : screenWidth * 1;

    double cardPadding = isTablet ? 16 : 10;
    double nameFont = isTablet ? 20 : 16.5;
    double captionFont = isTablet ? 18 : 15;
    double timeFont = isTablet ? 14 : 12;
    double avatarRadius = isTablet ? 36 : 28;

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
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: widget.post.profileUrl.isNotEmpty
                          ? NetworkImage(widget.post.profileUrl)
                          : null,
                      child: widget.post.profileUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
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
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {},
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
