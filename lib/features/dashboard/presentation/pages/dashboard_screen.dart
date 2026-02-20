// import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
// import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/add_post_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/chatbot_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/home_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/message_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/profile_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/search_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends ConsumerState<DashboardScreen> {
//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Any code you want to run after the first frame is rendered
//       final userSessionService = ref.read(userSessionServiceProvider);
//       ref
//           .read(authViewModelProvider.notifier)
//           .getCurrentUser(userId: userSessionService.getCurrentUserId() ?? "");
//     });
//   }

//   // List<Widget> lstBottomScreen = [
//   //   const HomeScreen(),
//   //   const SearchScreen(),
//   //   const AddPostScreen(),
//   //   const MessageScreen(),
//   //   const ProfileScreen(email: ""),
//   // ];

//   List<Widget> _buildBottomScreens(AuthEntity userEntity) {
//     return [
//       const HomeScreen(),
//       const SearchScreen(),
//       const AddPostScreen(),
//       const MessageScreen(),
//       ProfileScreen(userEntity: userEntity),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.error && next.errorMessage != null) {
//         SnackbarUtils.showError(
//           context,
//           next.errorMessage ?? 'An error occurred',
//         );
//       }
//     });

//     if (authState.authEntity == null) {
//       // return const Scaffold(body: Center(child: Text("No user data found")));
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final userEntity = authState.authEntity;

//     final screens = _buildBottomScreens(userEntity!);

//     return Scaffold(
//       body: SafeArea(child: screens[_selectedIndex]),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
//           BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
//           BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],

//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0XFF76C05D),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadiusGeometry.circular(20),
//         ),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ChatbotScreen()),
//           );
//         },
//         child: const Icon(
//           Icons.smart_toy_sharp,
//           size: 40,
//           color: Color.fromARGB(255, 236, 205, 113),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:ui';

// import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
// import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/add_post_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/chatbot_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/home_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/message_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/profile_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/search_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _BottomNavScreenState();
// }

// class _BottomNavScreenState extends ConsumerState<DashboardScreen> {
//   int _selectedIndex = 0;
//   double _currentIndex = 0;

//   /// ✅ Safe late controller
//   late final PageController _pageController;

//   @override
//   void initState() {
//     super.initState();

//     /// Initialize controller
//     _pageController = PageController(initialPage: 0);

//     /// Fetch current user safely after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final userSessionService = ref.read(userSessionServiceProvider);

//       ref
//           .read(authViewModelProvider.notifier)
//           .getCurrentUser(userId: userSessionService.getCurrentUserId() ?? "");
//     });
//   }

//   /// Dispose controller
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   /// Bottom screens
//   List<Widget> _buildBottomScreens(AuthEntity userEntity) {
//     return [
//       const HomeScreen(),
//       const SearchScreen(),
//       const AddPostScreen(),
//       const MessageScreen(),
//       ProfileScreen(userEntity: userEntity),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     /// Listen for auth errors
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.error && next.errorMessage != null) {
//         SnackbarUtils.showError(
//           context,
//           next.errorMessage ?? 'An error occurred',
//         );
//       }
//     });

//     /// Loading state
//     if (authState.authEntity == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final screens = _buildBottomScreens(authState.authEntity!);

//     return Scaffold(
//       extendBody: true,
//       body: Stack(
//         children: [
//           /// =========================
//           /// PageView for smooth swipe
//           /// =========================
//           SafeArea(
//             child: PageView(
//               controller: _pageController,
//               physics: const BouncingScrollPhysics(),
//               onPageChanged: (index) {
//                 setState(() {
//                   _selectedIndex = index;
//                   _currentIndex = index.toDouble();
//                 });
//               },
//               children: screens,
//             ),
//           ),

//           /// =========================
//           /// Liquid Glass Navbar
//           /// =========================
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 20),
//               child: _buildLiquidGlassNavBar(),
//             ),
//           ),
//         ],
//       ),

//       /// =========================
//       /// Floating AI Button
//       /// =========================
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 60),
//         child: FloatingActionButton(
//           backgroundColor: const Color(0XFF76C05D),
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const ChatbotScreen()),
//             );
//           },
//           child: const Icon(
//             Icons.smart_toy_sharp,
//             size: 32,
//             color: Color.fromARGB(255, 236, 205, 113),
//           ),
//         ),
//       ),
//     );
//   }

//   /// ========================================
//   /// Liquid Glass Navbar (iOS 26 style)
//   /// ========================================
//   Widget _buildLiquidGlassNavBar() {
//     final width = MediaQuery.of(context).size.width * 0.92;
//     final itemWidth = width / 5;

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(40),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//         child: Container(
//           width: width,
//           height: 75,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(40),
//             gradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(0.18),
//                 Colors.white.withOpacity(0.05),
//               ],
//             ),
//             border: Border.all(color: Colors.white.withOpacity(0.25)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 30,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Stack(
//             alignment: Alignment.centerLeft,
//             children: [
//               /// Animated Liquid Bubble
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 500),
//                 curve: Curves.easeOutExpo,
//                 left: _currentIndex * itemWidth,
//                 child: Container(
//                   width: itemWidth,
//                   height: 65,
//                   margin: const EdgeInsets.symmetric(horizontal: 6),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.35),
//                         Colors.white.withOpacity(0.15),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               /// Nav Icons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _liquidNavItem(Icons.home, 0),
//                   _liquidNavItem(Icons.search, 1),
//                   _liquidNavItem(Icons.add_circle_outline, 2),
//                   _liquidNavItem(Icons.message_outlined, 3),
//                   _liquidNavItem(Icons.person_outline, 4),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// ========================================
//   /// Liquid Icon Animation
//   /// ========================================
//   Widget _liquidNavItem(IconData icon, int index) {
//     final isSelected = _selectedIndex == index;

//     return GestureDetector(
//       onTap: () {
//         _pageController.animateToPage(
//           index,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeOutExpo,
//         );

//         setState(() {
//           _selectedIndex = index;
//           _currentIndex = index.toDouble();
//         });
//       },
//       child: AnimatedScale(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.elasticOut,
//         scale: isSelected ? 1.3 : 1.0,
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 300),
//           opacity: isSelected ? 1 : 0.6,
//           child: Icon(icon, size: 28, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';

import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/addPost/presentation/pages/add_post_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/chatbot_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/home_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/message_screen.dart';
import 'package:chautari_kurakani/features/profile/presentation/pages/profile_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  double _currentIndex = 0;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userSessionService = ref.read(userSessionServiceProvider);
      ref
          .read(authViewModelProvider.notifier)
          .getCurrentUser(userId: userSessionService.getCurrentUserId() ?? "");
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildBottomScreens(AuthEntity userEntity) {
    return [
      const HomeScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const MessageScreen(),
      ProfileScreen(userEntity: userEntity),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'An error occurred',
        );
      }
    });

    if (authState.authEntity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = _buildBottomScreens(authState.authEntity!);
    final navWidth = MediaQuery.of(context).size.width * 0.92;
    final itemWidth = navWidth / 5;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          /// PageView for smooth swipe
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                  _currentIndex = index.toDouble();
                });
              },
              children: screens,
            ),
          ),

          /// Liquid Glass Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildLiquidGlassNavBar(navWidth, itemWidth),
            ),
          ),
        ],
      ),

      /// Floating AI Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          backgroundColor: const Color(0XFF76C05D),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          child: const Icon(
            Icons.smart_toy_sharp,
            size: 32,
            color: Color.fromARGB(255, 236, 205, 113),
          ),
        ),
      ),
    );
  }

  /// Liquid Glass Navbar
  Widget _buildLiquidGlassNavBar(double width, double itemWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: width,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              /// Animated Liquid Bubble
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutExpo,
                left: _currentIndex * itemWidth + 6, // compensate margin
                child: Container(
                  width: itemWidth - 12, // horizontal margin
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),

              /// Nav Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _liquidNavItem(Icons.home, 0),
                  _liquidNavItem(Icons.search, 1),
                  _liquidNavItem(Icons.add_circle_outline, 2),
                  _liquidNavItem(Icons.message_outlined, 3),
                  _liquidNavItem(Icons.person_outline, 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Liquid Nav Icon
  Widget _liquidNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutExpo,
        );

        setState(() {
          _selectedIndex = index;
          _currentIndex = index.toDouble();
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        scale: isSelected ? 1.3 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSelected ? 1 : 0.6,
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
