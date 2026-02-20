import 'package:flutter/material.dart';
import 'package:chautari_kurakani/features/dashboard/data/models/post_model.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/post_card_widget.dart';

class FriendsFeedScreen extends StatelessWidget {
  const FriendsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<PostModel> posts = [
      PostModel(
        id: "friend-1",
        authorId: "friend-author-1",
        profileUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        name: "Shyam Khadka",
        hoursAgo: "2h",
        caption: "My first dog.",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cute_dog.jpg/2560px-Cute_dog.jpg",
      ),
      PostModel(
        id: "friend-2",
        authorId: "friend-author-2",
        profileUrl: "https://randomuser.me/api/portraits/women/2.jpg",
        name: "Sita Kumari",
        hoursAgo: "5h",
        caption: "Check out this poll!",
        isPoll: true,
      ),
      PostModel(
        id: "friend-3",
        authorId: "friend-author-3",
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
      });
  }
}
