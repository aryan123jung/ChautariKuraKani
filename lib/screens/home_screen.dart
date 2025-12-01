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
          ],
        ),
      ),
    );
  }
}