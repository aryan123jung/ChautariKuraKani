import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:flutter/material.dart';

class ChautariTileWidget extends StatelessWidget {
  final ChautariEntity item;
  final String? currentUserId;
  final VoidCallback onTap;
  final Future<void> Function()? onJoinLeave;

  const ChautariTileWidget({
    super.key,
    required this.item,
    required this.currentUserId,
    required this.onTap,
    this.onJoinLeave,
  });

  @override
  Widget build(BuildContext context) {
    final isJoined = item.isJoinedBy(currentUserId);
    final isCreator = item.isCreatedBy(currentUserId);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1A212B) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: item.profileUrl != null
                    ? NetworkImage(item.profileUrl!)
                    : null,
                child: item.profileUrl == null
                    ? Text(
                        item.name.isEmpty
                            ? 'C'
                            : item.name.trim()[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description.isEmpty
                          ? 'No description'
                          : item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.memberCount} members',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCreator)
                FilledButton.tonal(
                  onPressed: onJoinLeave == null
                      ? null
                      : () async {
                          await onJoinLeave!.call();
                        },
                  child: Text(isJoined ? 'Leave' : 'Join'),
                )
              else
                const Chip(label: Text('Creator')),
            ],
          ),
        ),
      ),
    );
  }
}
