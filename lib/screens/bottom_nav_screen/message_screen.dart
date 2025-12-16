import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: Center(
      child: Text("Welcome to Profile Screen"),
    ),);
  }
}