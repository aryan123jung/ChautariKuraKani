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

  const FriendCard({super.key, required this.friend, required this.onView});

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

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: EdgeInsets.zero, // Remove internal margin
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
            side: const BorderSide(color: Color(0xFFDBDBDB), width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: nameFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${friend.username}',
                        style: TextStyle(
                          fontSize: mutualFont,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
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
