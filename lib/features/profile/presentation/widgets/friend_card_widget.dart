// // friends_card_widget.dart
// import 'package:flutter/material.dart';

// class FriendCard extends StatelessWidget {
//   final Map<String, String> friend;

//   const FriendCard({super.key, required this.friend});

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     Orientation orientation = MediaQuery.of(context).orientation;

//     bool isTablet = screenWidth > 600;

//     double cardWidth = isTablet
//         ? (orientation == Orientation.landscape
//               ? screenWidth * 0.5
//               : screenWidth * 0.6)
//         : screenWidth * 1;

//     double cardPadding = isTablet ? 16 : 10;
//     double nameFont = isTablet ? 20 : 16.5;
//     double mutualFont = isTablet ? 16 : 14;
//     double avatarRadius = isTablet ? 40 : 32;

//     return Center(
//       child: SizedBox(
//         width: cardWidth,
//         child: Card(
//           margin: EdgeInsets.symmetric(
//             vertical: 8,
//             horizontal: isTablet
//                 ? (orientation == Orientation.landscape ? 0 : 0)
//                 : 12,
//           ),
//           elevation: 8,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
//             side: const BorderSide(color: Color(0xFFDBDBDB), width: 1.5),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(cardPadding),
//             child: Row(
//               children: [
//                 // Profile Picture
//                 CircleAvatar(
//                   radius: avatarRadius,
//                   backgroundImage: NetworkImage(friend['profileUrl']!),
//                 ),
//                 const SizedBox(width: 16),

//                 // Friend Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         friend['name']!,
//                         style: TextStyle(
//                           fontSize: nameFont,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         friend['mutualFriends']!,
//                         style: TextStyle(
//                           fontSize: mutualFont,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // View Button
//                 ElevatedButton(
//                   onPressed: () {
//                     //  Navigate to friend's profile
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isTablet ? 24 : 16,
//                       vertical: isTablet ? 12 : 8,
//                     ),
//                   ),
//                   child: Text(
//                     'View',
//                     style: TextStyle(fontSize: isTablet ? 16 : 14),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// friend_card_widget.dart
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  final SearchUserEntity friend;
  final VoidCallback onView;
  final VoidCallback? onMessage;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onView,
    this.onMessage,
  });

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
    double mutualFont = isTablet ? 16 : 14;
    double avatarRadius = isTablet ? 40 : 32;
    final fullName = friend.fullName.trim().isEmpty ? 'User' : friend.fullName;
    final profileUrl = _resolveProfile(friend.profileUrl);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1A2330), const Color(0xFF131A24)]
                  : [const Color(0xFFF8FBFF), const Color(0xFFEFF8F0)],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFDCE7DF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding + 2),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: profileUrl != null
                          ? NetworkImage(profileUrl)
                          : null,
                      child: profileUrl == null
                          ? Text(
                              fullName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: isTablet ? 14 : 12,
                        height: isTablet ? 14 : 12,
                        decoration: BoxDecoration(
                          color: const Color(0XFF76C05D),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF131A24)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: nameFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE8EEF8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '@${friend.username}',
                          style: TextStyle(
                            fontSize: mutualFont - 1,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onMessage != null) ...[
                      IconButton(
                        tooltip: 'Message',
                        onPressed: onMessage,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0XFF76C05D),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.message_outlined, size: 19),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: onView,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isDark
                            ? const Color(0xFF2D7DF4)
                            : const Color(0xFF1E6DEB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                          vertical: isTablet ? 12 : 8,
                        ),
                      ),
                      child: Text(
                        'View',
                        style: TextStyle(
                          fontSize: isTablet ? 15.5 : 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
