// import 'package:chautari_kurakani/screens/chatbot_screen.dart';
// import 'package:chautari_kurakani/screens/home_screen.dart';
// import 'package:chautari_kurakani/screens/chatbot_screen.dart';
import 'package:chautari_kurakani/screens/home_screen.dart';
// import 'package:chautari_kurakani/screens/login_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}