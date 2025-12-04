// import 'package:chautari_kurakani/screens/chatbot_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // SizedBox(
            //   width: double.infinity,
            //   child: FloatingActionButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotScreen(),),);},
            //   child: Text("Ai ChatBot", style: TextStyle(fontSize: 20),),)
            // ),
            Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // Top Row (Profile + Name)
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Aryan Chhetri",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("2 hrs ago",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),

        SizedBox(height: 12),

        // Post Text
        Text(
          "This is my first post on ChautariKuraKani! Excited to share more updates 🎉",
          style: TextStyle(fontSize: 15),
        ),

        SizedBox(height: 12),

        // Post Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset("assets/sample_post.jpg"),
        ),

        SizedBox(height: 12),

        // Like Comment Share Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.favorite_border),
            Icon(Icons.chat_bubble_outline),
            Icon(Icons.send),
          ],
        ),
      ],
    ),
  ),
)

          ],
        ),
      ),
    );
  }
}