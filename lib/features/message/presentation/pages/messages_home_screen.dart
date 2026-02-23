import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/search_users_usecase.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/friend_request/data/repositories/friend_request_repository.dart';
import 'package:chautari_kurakani/features/message/presentation/pages/chat_screen.dart';
import 'package:chautari_kurakani/features/message/presentation/state/message_state.dart';
import 'package:chautari_kurakani/features/message/presentation/view_model/message_view_model.dart';
import 'package:chautari_kurakani/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesHomeScreen extends ConsumerStatefulWidget {
  const MessagesHomeScreen({super.key});

  @override
  ConsumerState<MessagesHomeScreen> createState() => _MessagesHomeScreenState();
}

class _MessagesHomeScreenState extends ConsumerState<MessagesHomeScreen> {
  late final MessageViewModel _messageNotifier;

  @override
  void initState() {
    super.initState();
    _messageNotifier = ref.read(messageViewModelProvider.notifier);
    Future.microtask(() async {
      await _messageNotifier.loadConversations();
    });
  }

  Future<void> _refresh() async {
    await _messageNotifier.loadConversations();
  }

  Future<void> _startConversationWithFriend() async {
    final authState = ref.read(authViewModelProvider);
    final currentId = authState.authEntity?.authId;
    if (currentId == null || currentId.trim().isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _FriendPickerSheet(
          currentUserId: currentId,
          onPick: (friend) async {
            Navigator.of(sheetContext).pop();

            final conversation = await _messageNotifier.getOrCreateConversation(
              friend.authId ?? '',
            );
            if (!mounted) return;

            if (conversation == null) {
              final err = ref.read(messageViewModelProvider).errorMessage;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err ?? 'Failed to start conversation')),
              );
              return;
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conversation: conversation,
                  currentUserId: currentId,
                ),
              ),
            );

            if (!mounted) return;
            await _refresh();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final currentUserId = authState.authEntity?.authId;
    final state = ref.watch(messageViewModelProvider);

    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return const Center(child: Text('Please login again'));
    }

    final conversations = state.conversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: _startConversationWithFriend,
            icon: const Icon(Icons.create_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (context) {
            if (state.status == MessageStatusUi.loading &&
                conversations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (state.status == MessageStatusUi.error &&
                conversations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: context.scale(140)),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(16),
                      ),
                      child: Text(
                        state.errorMessage ?? 'Failed to load conversations',
                      ),
                    ),
                  ),
                ],
              );
            }

            if (conversations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: context.scale(140)),
                  Center(
                    child: Text(
                      'No conversations yet',
                      style: TextStyle(fontSize: context.fs(15)),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                context.scale(10),
                context.scale(10),
                context.scale(10),
                context.scale(16),
              ),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => SizedBox(height: context.scale(6)),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final other = conversation.otherParticipant(currentUserId);
                final name = other?.fullName ?? 'Chat';
                final subtitle = (conversation.lastMessage ?? '').trim();
                final profile = _resolveProfile(other?.profileUrl);
                final unreadCount = state.unreadFor(conversation.id);
                final hasUnread = unreadCount > 0;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      _messageNotifier.markConversationAsReadLocal(
                        conversation.id,
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversation: conversation,
                            currentUserId: currentUserId,
                          ),
                        ),
                      );
                      if (!mounted) return;
                      await _refresh();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scale(12),
                        vertical: context.scale(10),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasUnread
                              ? const Color(0XFF76C05D).withValues(alpha: 0.35)
                              : Colors.grey.withValues(alpha: 0.15),
                        ),
                        gradient: hasUnread
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(
                                    0XFF76C05D,
                                  ).withValues(alpha: 0.14),
                                  const Color(
                                    0XFF76C05D,
                                  ).withValues(alpha: 0.03),
                                ],
                              )
                            : null,
                        color: hasUnread ? null : Theme.of(context).cardColor,
                        boxShadow: hasUnread
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0XFF76C05D,
                                  ).withValues(alpha: 0.14),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: hasUnread
                                        ? const Color(0XFF76C05D)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: context.scale(22),
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: profile != null
                                      ? NetworkImage(profile)
                                      : null,
                                  child: profile == null
                                      ? Text(
                                          (name.isNotEmpty ? name[0] : 'C')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (hasUnread)
                                Positioned(
                                  right: 1,
                                  top: 1,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0XFF76C05D),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: context.scale(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: hasUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: context.fs(15),
                                  ),
                                ),
                                SizedBox(height: context.scale(4)),
                                Text(
                                  subtitle.isEmpty ? 'Tap to chat' : subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.fs(13),
                                    color: hasUnread
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                    fontWeight: hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: context.scale(10)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _relativeTime(conversation.lastMessageAt),
                                style: TextStyle(
                                  fontSize: context.fs(11),
                                  color: hasUnread
                                      ? const Color(0XFF76C05D)
                                      : Colors.grey.shade600,
                                  fontWeight: hasUnread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (hasUnread)
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 22,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0XFF76C05D),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
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

  String _relativeTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _FriendPickerSheet extends ConsumerStatefulWidget {
  final String currentUserId;
  final Future<void> Function(AuthEntity friend) onPick;

  const _FriendPickerSheet({required this.currentUserId, required this.onPick});

  @override
  ConsumerState<_FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends ConsumerState<_FriendPickerSheet> {
  bool _loading = true;
  List<AuthEntity> _friends = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFriends);
  }

  Future<void> _loadFriends() async {
    setState(() => _loading = true);

    try {
      final usersResult = await ref.read(searchUsersUsecaseProvider)(
        const SearchUsersParams(search: '', page: 1, size: 100),
      );

      final users = usersResult.fold((_) => <AuthEntity>[], (data) => data);
      final current = widget.currentUserId.trim().toLowerCase();
      final candidates = users
          .where((user) => (user.authId ?? '').trim().toLowerCase() != current)
          .toList();

      final friendRepo = ref.read(friendRequestRepositoryProvider);
      final checked = await Future.wait(
        candidates.map((user) async {
          final userId = user.authId ?? '';
          if (userId.trim().isEmpty) return null;
          final statusResult = await friendRepo.getStatus(userId);
          return statusResult.fold(
            (_) => null,
            (status) => status.status == 'FRIEND' ? user : null,
          );
        }),
      );

      if (!mounted) return;
      setState(() {
        _friends = checked.whereType<AuthEntity>().toList();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Start chat with friends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _friends.isEmpty
                    ? const Center(
                        child: Text('No friends available to message'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _friends.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final user = _friends[index];
                          final name = [
                            user.fName,
                            user.lName,
                          ].where((part) => part.trim().isNotEmpty).join(' ');

                          final display = name.isNotEmpty
                              ? name
                              : user.username;
                          final image = _resolveProfile(user.profilePicture);

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: image != null
                                  ? NetworkImage(image)
                                  : null,
                              child: image == null
                                  ? Text(
                                      (display.isNotEmpty ? display[0] : 'U')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(display),
                            subtitle: Text('@${user.username}'),
                            onTap: () => widget.onPick(user),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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
