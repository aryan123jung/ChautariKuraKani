import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/chautari_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/feed_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/friend_feed_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/notification_screen.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;
    return Padding(
      padding:  EdgeInsets.fromLTRB(15,isTablet? 0: 15,15,15),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/green_half_logo.png",
                    height: isTablet ? 100 : 80,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "ChautariKuraKani",
                    style: TextStyle(
                      fontFamily: "OpenSans Bold",
                      fontSize: isTablet ? 45 : 30,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:  EdgeInsets.fromLTRB(0,isTablet? 0: 10, 0, 0),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal:isTablet ? 60: 5),
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
                      onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationScreen()));},
                      icon: const Icon(Icons.notifications_none),
                      iconSize: 33,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height:isTablet? 10: 10,),

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
