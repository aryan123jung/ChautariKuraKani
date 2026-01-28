// import 'dart:async';
// import 'package:chautari_kurakani/core/routes/app_routes.dart';
// import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
// import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as ref;
// import 'package:lottie/lottie.dart';
// // import 'package:chautari_kurakani/screens/login_screen.dart';

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
//     _navigateToNext();

//     _logoController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//     _logoAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
//     );
//     _logoController.forward();

//     _loadingController = AnimationController(vsync: this);

//     Timer(const Duration(seconds: 4), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingOne()),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _loadingController.dispose();
//     super.dispose();
//   }
//   Future<void> _navigateToNext() async {
//     await Future.delayed(const Duration(seconds: 3));
//     if (!mounted) return;

//     // Check if user is already logged in
//     final userSessionService = ref.read(userSessionServiceProvider);
//     final isLoggedIn = userSessionService.isLoggedIn();

//     if (isLoggedIn) {
//       // Navigate to Dashboard if user is logged in
//       AppRoutes.pushReplacement(context, const DashboardScreen());
//     } else {
//       // Navigate to Onboarding if user is not logged in
//       AppRoutes.pushReplacement(context, const OnboardingOne());
//     }
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
//                           color: Colors.black.withValues(alpha: 0.2),
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
//                         color: Colors.black.withValues(alpha: 0.2),
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
//                         color: Colors.black.withValues(alpha: 0.2),
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


import 'dart:async';

import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
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

    _logoAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _loadingController = AnimationController(vsync: this);

    _logoController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const DashboardScreen());
    } else {
      AppRoutes.push(context, const OnboardingOne());
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isTablet ? 50 : 200),

                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
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
                        color: Colors.black.withValues(alpha: 0.2),
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
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 0 : 130),

                SizedBox(
                  height: isTablet ? 500 : 370,
                  child: Lottie.asset(
                    'assets/lottie/loading_hand2.json',
                    controller: _loadingController,
                    onLoaded: (composition) {
                      _loadingController
                        ..duration = composition.duration
                        ..repeat();
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
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';

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

//     Timer(const Duration(seconds: 4), _handleNavigation);
//   }

//   Future<void> _handleNavigation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final onboardingCompleted = prefs.getBool('onboarding_done') ?? false;

//     final authState = ref.read(authViewModelProvider);

//     if (!onboardingCompleted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingOne()),
//       );
//       return;
//     }

//     // 🔥 Auth navigation is handled globally in App()
//     // So we just leave the splash
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
//       body: Center(
//         child: Column(
//           children: [
//             SizedBox(height: isTablet ? 50 : 200),
//             ScaleTransition(
//               scale: _logoAnimation,
//               child: Image.asset(
//                 'assets/images/white_half_logo.png',
//                 height: isTablet ? 250 : 170,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "ChautariKuraKani",
//               style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
//             ),
//             Expanded(
//               child: Lottie.asset(
//                 'assets/lottie/loading_hand2.json',
//                 controller: _loadingController,
//                 onLoaded: (composition) {
//                   _loadingController
//                     ..duration = composition.duration
//                     ..repeat();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
