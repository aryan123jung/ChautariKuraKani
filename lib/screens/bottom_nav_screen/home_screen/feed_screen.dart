import 'package:chautari_kurakani/models/post_model.dart';
import 'package:chautari_kurakani/widgets/post_card_widget.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PostModel> posts = [
      PostModel(
        profileUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        name: "Hari Lama",
        hoursAgo: "2h",
        caption: "My first dog.",
        imageUrl:
            "https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L25zODIzMC1pbWFnZS5qcGc.jpg",
      ),
      PostModel(
        profileUrl: "https://randomuser.me/api/portraits/women/2.jpg",
        name: "Sita Kumari",
        hoursAgo: "5h",
        caption: "Check out this poll!",
        isPoll: true,
      ),
      PostModel(
        profileUrl: "https://randomuser.me/api/portraits/men/3.jpg",
        name: "Alex Khairey",
        hoursAgo: "1d",
        caption: "Wassupp everyone!!!!!!!",
      ),
    ];

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: posts[index]);
      },
    );
  }
}
