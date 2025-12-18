import 'package:chautari_kurakani/models/chautari_model.dart';
import 'package:flutter/material.dart';


class ChautariCardWidget extends StatelessWidget {
  final ChautariModel post;

  const ChautariCardWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(10),
        side: BorderSide(
          color: Color(0xFFDBDBDB),
          width: 1.5,
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: Text(
                      post.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: "OpenSans Bold",
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_right),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 13),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(13,8,8,13),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(post.imageUrl,height: 300,width: double.infinity,fit: BoxFit.cover,),
                ),
              ),
          
              const SizedBox(height: 5),
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    post.caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 115, 115, 115)
                    ),
                  ),
                ),
              ),

              
              
              
            ],
          ),
        ),
      ),
    );
  }
}

