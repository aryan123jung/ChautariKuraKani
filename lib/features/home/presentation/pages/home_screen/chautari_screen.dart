import 'package:chautari_kurakani/features/dashboard/data/models/chautari_model.dart';
import 'package:chautari_kurakani/features/home/presentation/widgets/chautari_card_widget.dart';
import 'package:flutter/material.dart';

class ChautariScreen extends StatelessWidget {
  const ChautariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChautariModel> posts = [
      ChautariModel(
        name: "c/Kurakani",
        caption: "Join and feel free to express yourself ;)",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cute_dog.jpg/2560px-Cute_dog.jpg",
      ),
      ChautariModel(
        name: "c/Kurakani",
        caption: "Join and feel free to express yourself ;)",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cute_dog.jpg/2560px-Cute_dog.jpg",
      ),
      ChautariModel(
        name: "c/Kurakani",
        caption: "Join and feel free to express yourself ;)",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cute_dog.jpg/2560px-Cute_dog.jpg",
      ),
      ChautariModel(
        name: "c/Kurakani",
        caption: "Join and feel free to express yourself ;)",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cute_dog.jpg/2560px-Cute_dog.jpg",
      ),
      ChautariModel(
        name: "c/Kurakani",
        caption: "Join and feel free to express yourself ;)",
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cute_dog.jpg/2560px-Cute_dog.jpg",
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), 
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ChautariCardWidget(post: posts[index]);
            },
          ),

          Positioned(
            bottom: 0,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.add, 
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
