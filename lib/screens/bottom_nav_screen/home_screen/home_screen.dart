import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen/chautari_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen/feed_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen/friend_feed_screen.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/green_half_logo.png",
                    height: 80,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "ChautariKuraKani",
                    style: TextStyle(
                      fontFamily: "OpenSans Bold",
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    const Expanded(
                      child: TabBar(
                        indicatorColor: Colors.black,
                        indicatorWeight: 2,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(
                            fontSize: 17.5, fontWeight: FontWeight.w600),
                        tabs: [
                          Tab(text: "Feed"),
                          Tab(text: "Friends"),
                          Tab(text: "Chautari"),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                      iconSize: 33,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10,),

            Expanded(
              child: TabBarView(
                children: [
                  FeedScreen(),
                  FriendsFeedScreen(),
                  ChautariScreen()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
