import 'package:chautari_kurakani/models/post_model.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    bool isTablet = screenWidth > 600;

    double cardWidth = isTablet
        ? (orientation == Orientation.landscape ? screenWidth * 0.5 : screenWidth * 0.6)
        : screenWidth * 1;

    double cardPadding = isTablet ? 16 : 10;

    double imageHeight = isTablet ? 400 : 300;

    double nameFont = isTablet ? 20 : 16.5;
    double captionFont = isTablet ? 18 : 15;
    double timeFont = isTablet ? 14 : 12;

    double avatarRadius = isTablet ? 36 : 28;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isTablet ? (orientation == Orientation.landscape ? 0 : 0) : 12,
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
            side: const BorderSide(
              color: Color(0xFFDBDBDB),
              width: 1.5,
            ),
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
                      backgroundImage: NetworkImage(post.profileUrl),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.name,
                          style: TextStyle(fontSize: nameFont, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          post.hoursAgo,
                          style: TextStyle(color: Colors.grey[600], fontSize: timeFont),
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

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: Text(
                    post.caption,
                    style: TextStyle(fontSize: captionFont, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 13),

                if (post.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                    child: Image.network(
                      post.imageUrl!,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                if (post.isPoll)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[200],
                    child: const Text("Poll Placeholder"),
                  ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text("Like"),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text("Dislike"),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment_outlined),
                      label: const Text("Comment"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
