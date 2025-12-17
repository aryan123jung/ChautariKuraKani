import 'package:chautari_kurakani/models/post_model.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Color(0xFFDBDBDB),
          width: 1.5,
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(post.profileUrl),
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name,
                      style: const TextStyle(fontSize: 16.5,fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post.hoursAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),

                const Spacer(),

                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {                  },
                )
              ],
            ),

            const SizedBox(height: 10),
    
    
            Padding(
              padding: const EdgeInsets.fromLTRB(14,0,14,0),
              child: Text(post.caption,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
            ),
    
    
            const SizedBox(height: 13),
    
            if (post.imageUrl != null) ...{
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(post.imageUrl!,height: 300,width: double.infinity,fit: BoxFit.cover,),
              ),
            },
            if (post.isPoll) ...{
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: const Text("Poll Placeholder"),
              ),
            },

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
    );
  }
}
