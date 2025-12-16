// // import 'package:chautari_kurakani/screens/chatbot_screen.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home"),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
    
//             Card(
//   elevation: 4,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(16),
//   ),
//   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//   child: Padding(
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
        
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 22,
//               backgroundImage: AssetImage("assets/profile.jpg"),
//             ),
//             SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Aryan Chhetri",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 Text("2 hrs ago",
//                     style: TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//           ],
//         ),

//         SizedBox(height: 12),

//         // Post Text
//         Text(
//           "This is my first post on ChautariKuraKani! Excited to share more updates 🎉",
//           style: TextStyle(fontSize: 15),
//         ),

//         SizedBox(height: 12),

//         // Post Image
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.asset("assets/sample_post.jpg"),
//         ),

//         SizedBox(height: 12),

//         // Like Comment Share Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Icon(Icons.favorite_border),
//             Icon(Icons.chat_bubble_outline),
//             Icon(Icons.send),
//           ],
//         ),
//       ],
//     ),
//   ),
// )

//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: DefaultTabController(
        length: 3, // Feed, Friends, Chautari
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
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                        labelStyle: TextStyle(fontSize: 17.5,fontWeight: FontWeight.w600),
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
      
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text("Feed Screen")),
                  Center(child: Text("Friends Screen")),
                  Center(child: Text("Chautari Screen")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
