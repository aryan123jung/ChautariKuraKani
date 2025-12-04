// import 'package:chautari_kurakani/screens/onboarding/onboarding_one.dart';
import 'package:chautari_kurakani/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color(0xFF76C05D),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      // home: OnboardingOne(),
    );
  }
}