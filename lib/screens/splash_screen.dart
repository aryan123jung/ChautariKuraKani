import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:chautari_kurakani/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));
    _logoController.forward();

    _loadingController = AnimationController(vsync: this);

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
            
                SizedBox(height: isTablet? 50:200,),
                
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 26,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/white_half_logo.png',
                      height: isTablet ? 120 : 170,
                      width: isTablet ? 120 : 170,
                    ),
                  ),
                ),
            
                const SizedBox(height: 20),
            
                
                Text(
                  "ChautariKuraKani",
                  style: TextStyle(
                    fontSize: isTablet ? 40 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                Text(
                  "Chautarimah Sabai Kura",
                  style: TextStyle(
                    fontSize: isTablet ? 40 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 30),
            
                
                SizedBox(
                  height: isTablet ? 80 : 400,
                  child: Lottie.asset(
                    'assets/lottie/loading_hand2.json',
                    controller: _loadingController,
                    onLoaded: (composition) {
                      _loadingController
                        ..duration = composition.duration
                        ..repeat(min: 0, max: 1); 
                    },
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
