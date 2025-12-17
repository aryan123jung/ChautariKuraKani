import 'package:chautari_kurakani/models/chautari-model.dart';
import 'package:chautari_kurakani/widgets/chautari_card_widget.dart';
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
    ];
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context,index){
        return ChautariCardWidget(post: posts[index]);
      });
  }
}
