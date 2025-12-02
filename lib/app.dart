import 'package:chautari_kurakani/screens/login_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color(0xFF76C05D),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}