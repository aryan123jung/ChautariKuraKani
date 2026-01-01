import 'package:chautari_kurakani/features/dashboard/data/models/chautari_model.dart';
import 'package:flutter/material.dart';

class ChautariCardWidget extends StatelessWidget {
  final ChautariModel post;

  const ChautariCardWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    bool isTablet = screenWidth > 600;

    double cardWidth;
    if (isTablet) {
      cardWidth = orientation == Orientation.landscape
          ? screenWidth * 0.5
          : screenWidth * 0.6;
    } else {
      cardWidth = screenWidth * 1; 
    }

    double imageHeight = isTablet ? 400 : 300;
    double nameFont = isTablet ? 22 : 20;
    double captionFont = isTablet ? 20 : 18;
    double borderRadius = isTablet ? 25 : 20;
    double cardPadding = isTablet ? 16 : 10;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isTablet ? 0 : 12, 
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
                Stack(
                  children: [
                    Center(
                      child: Text(
                        post.name,
                        style: TextStyle(
                          fontSize: nameFont,
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
                  padding: const EdgeInsets.fromLTRB(13, 8, 8, 13),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Image.network(
                      post.imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
                      style: TextStyle(
                        fontSize: captionFont,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 115, 115, 115),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
