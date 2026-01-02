import 'dart:async';
import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:chautari_kurakani/screens/login_screen.dart';

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
        MaterialPageRoute(builder: (_) => const OnboardingOne()),
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
                      height: isTablet ? 250 : 170,
                      width: isTablet ? 250 : 170,
                    ),
                  ),
                ),
            
                const SizedBox(height: 20),
            
                
                Text(
                  "ChautariKuraKani",
                  style: TextStyle(
                    fontSize: isTablet ? 50 : 40,
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
                    fontSize: isTablet ? 30 : 20,
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
            
                 SizedBox(height:isTablet? 0: 130),
            
                
                SizedBox(
                  height: isTablet ?500 : 370,
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
// import 'dart:async';
// import 'dart:io';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lottie/lottie.dart';
// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _logoController;
//   late final Animation<double> _logoAnimation;
//   late final AnimationController _loadingController;

//   @override
//   void initState() {
//     super.initState();

//     _logoController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//     _logoAnimation = Tween<double>(begin: 0.6, end: 1.0)
//         .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));
//     _logoController.forward();

//     _loadingController = AnimationController(vsync: this);

//     // Start navigation after 4 seconds
//     Timer(const Duration(seconds: 4), _navigateNext);
//   }

//   Future<void> _navigateNext() async {
//     final hiveService = ref.read(hiveServiceProvider);
//     final allAuths = hiveService.getAllAuths();

//     // TODO: Replace this with actual Hive bool to track if onboarding was seen
//     final bool seenOnboarding = false;

//     Widget nextScreen;
//     if (!seenOnboarding) {
//       nextScreen = const OnboardingOne();
//     } else if (allAuths.isNotEmpty) {
//       nextScreen = const DashboardScreen();
//     } else {
//       nextScreen = const LoginScreen();
//     }

//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => nextScreen),
//     );
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _loadingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isTablet = screenWidth > 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFF76C05D),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: isTablet ? 50 : 200),
//                 ScaleTransition(
//                   scale: _logoAnimation,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 26,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Image.asset(
//                       'assets/images/white_half_logo.png',
//                       height: isTablet ? 250 : 170,
//                       width: isTablet ? 250 : 170,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   "ChautariKuraKani",
//                   style: TextStyle(
//                     fontSize: isTablet ? 50 : 40,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 15,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   "Chautarimah Sabai Kura",
//                   style: TextStyle(
//                     fontSize: isTablet ? 30 : 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 15,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: isTablet ? 0 : 130),
//                 SizedBox(
//                   height: isTablet ? 500 : 370,
//                   child: Lottie.asset(
//                     'assets/lottie/loading_hand2.json',
//                     controller: _loadingController,
//                     onLoaded: (composition) {
//                       _loadingController
//                         ..duration = composition.duration
//                         ..repeat(min: 0, max: 1);
//                     },
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
