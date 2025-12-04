import 'package:chautari_kurakani/widgets/my_floating_button.dart';
import 'package:chautari_kurakani/widgets/my_outline_button.dart';
import 'package:flutter/material.dart';

class OnboardingOne extends StatefulWidget {
  const OnboardingOne({super.key});

  @override
  State<OnboardingOne> createState() => _OnboardingOneState();
}

class _OnboardingOneState extends State<OnboardingOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100),
            Image.asset("assets/images/splash_one.png"),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "Gather with friends, family and new faces. ChautariKuraKani is the welcoming space for authentic conversations and shared stories.",
                style: TextStyle(
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 9,
                      offset: const Offset(2, 3),
                    ),
                  ],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MyFloatingButton(
                
                onPressed: () {}, 
                text: "Next",
                color: const Color.fromARGB(255, 229, 163, 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
