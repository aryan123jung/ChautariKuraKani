import 'package:chautari_kurakani/features/friend_request/presentation/view_model/friend_request_view_model.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:chautari_kurakani/features/notification/presentation/state/notification_state.dart';
import 'package:chautari_kurakani/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final Map<String, String> _friendRequestActionResult = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(notificationViewModelProvider.notifier).fetchNotifications();
      await ref.read(notificationViewModelProvider.notifier).connectRealtime();
      await ref.read(friendRequestViewModelProvider.notifier).loadIncoming();
    });
  }

  @override
  void dispose() {
    ref.read(notificationViewModelProvider.notifier).disconnectRealtime();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationViewModelProvider.notifier).fetchNotifications();
    await ref.read(friendRequestViewModelProvider.notifier).loadIncoming();
  }

  Future<void> _acceptFromNotification(NotificationEntity item) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final requestId = item.entityId.trim();
    if (requestId.isEmpty) return;

    final ok = await ref
        .read(friendRequestViewModelProvider.notifier)
        .acceptRequest(requestId);

    if (!mounted) return;
    if (!ok) {
      final err = ref.read(friendRequestViewModelProvider).errorMessage;
      messenger?.showSnackBar(
        SnackBar(content: Text(err ?? 'Failed to accept request')),
      );
      return;
    }

    await ref.read(notificationViewModelProvider.notifier).markRead(item.id);
    if (mounted) {
      setState(() {
        _friendRequestActionResult[item.id] = 'Friend request accepted';
      });
    }
    messenger?.showSnackBar(
      const SnackBar(content: Text('Friend request accepted')),
    );
    await _onRefresh();
  }

  Future<void> _rejectFromNotification(NotificationEntity item) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final requestId = item.entityId.trim();
    if (requestId.isEmpty) return;

    final ok = await ref
        .read(friendRequestViewModelProvider.notifier)
        .rejectRequest(requestId);

    if (!mounted) return;
    if (!ok) {
      final err = ref.read(friendRequestViewModelProvider).errorMessage;
      messenger?.showSnackBar(
        SnackBar(content: Text(err ?? 'Failed to reject request')),
      );
      return;
    }

    await ref.read(notificationViewModelProvider.notifier).markRead(item.id);
    if (mounted) {
      setState(() {
        _friendRequestActionResult[item.id] = 'Friend request rejected';
      });
    }
    messenger?.showSnackBar(
      const SnackBar(content: Text('Friend request rejected')),
    );
    await _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: const Color(0XFF76C05D),
        actions: [
          TextButton(
            onPressed: state.notifications.isEmpty
                ? null
                : () => ref.read(notificationViewModelProvider.notifier).markAllRead(),
            child: const Text('Mark all', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(
          builder: (context) {
            if (state.status == NotificationStatusUi.loading &&
                state.notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (state.status == NotificationStatusUi.error &&
                state.notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 180),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(state.errorMessage ?? 'Failed to load notifications'),
                    ),
                  ),
                ],
              );
            }

            if (state.notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No notifications yet')),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = state.notifications[index];
                return _NotificationTile(
                  item: item,
                  actionResultText: _friendRequestActionResult[item.id],
                  onTap: () {
                    if (!item.isRead) {
                      ref.read(notificationViewModelProvider.notifier).markRead(item.id);
                    }
                  },
                  onAccept:
                      item.type == 'FRIEND_REQUEST_SENT' &&
                          !item.isRead &&
                          !_friendRequestActionResult.containsKey(item.id)
                      ? () => _acceptFromNotification(item)
                      : null,
                  onReject:
                      item.type == 'FRIEND_REQUEST_SENT' &&
                          !item.isRead &&
                          !_friendRequestActionResult.containsKey(item.id)
                      ? () => _rejectFromNotification(item)
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final String? actionResultText;

  const _NotificationTile({
    required this.item,
    required this.onTap,
    this.onAccept,
    this.onReject,
    this.actionResultText,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.title.trim().isEmpty ? 'Notification' : item.title;
    final actorName = item.actor.fullName.trim().isEmpty
        ? (item.actor.username.trim().isEmpty ? 'User' : item.actor.username)
        : item.actor.fullName;

    return Material(
      color: item.isRead ? Colors.white : const Color(0xFFEFF8EB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: item.actor.profileUrl != null
                    ? NetworkImage(item.actor.profileUrl!)
                    : null,
                child: item.actor.profileUrl == null
                    ? Text(
                        (actorName.isEmpty ? 'U' : actorName[0]).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(item.message),
                    const SizedBox(height: 6),
                    if (onAccept != null && onReject != null)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF76C05D),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Accept'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    if (actionResultText != null) ...[
                      Text(
                        actionResultText!,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      item.relativeTime,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0XFF76C05D),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
