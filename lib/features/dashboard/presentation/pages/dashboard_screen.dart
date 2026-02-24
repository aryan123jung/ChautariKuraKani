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
import 'dart:async';
import 'dart:ui';

import 'package:chautari_kurakani/core/utils/responsive.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/addPost/presentation/pages/add_post_screen.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:chautari_kurakani/features/call/presentation/pages/call_session_screen.dart';
import 'package:chautari_kurakani/features/call/presentation/state/call_state.dart';
import 'package:chautari_kurakani/features/call/presentation/view_model/call_view_model.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/chatbot_screen.dart';
import 'package:chautari_kurakani/features/home/presentation/pages/home_screen/home_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/message_screen.dart';
import 'package:chautari_kurakani/features/message/domain/entities/message_entities.dart';
import 'package:chautari_kurakani/features/message/presentation/state/message_state.dart';
import 'package:chautari_kurakani/features/message/presentation/view_model/message_view_model.dart';
import 'package:chautari_kurakani/features/profile/presentation/pages/profile_screen.dart';
import 'package:chautari_kurakani/features/sensor/data/services/shake_detector_service.dart';
import 'package:chautari_kurakani/features/search/presentation/pages/search_screen.dart';
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
  int _profileRefreshTick = 0;

  late final PageController _pageController;
  late final MessageViewModel _messageNotifier;
  late final CallViewModel _callNotifier;
  final ShakeDetectorService _shakeDetector = ShakeDetectorService();
  String? _incomingDialogCallId;
  BuildContext? _incomingDialogContext;
  OverlayEntry? _topPopupEntry;
  Timer? _topPopupTimer;
  bool _realtimeBootstrapped = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _messageNotifier = ref.read(messageViewModelProvider.notifier);
    _callNotifier = ref.read(callViewModelProvider.notifier);
    _shakeDetector.start(onShake: _openAddPostByShake);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getCurrentUser(userId: '');
    });
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    _messageNotifier.disconnectRealtime();
    _callNotifier.disconnectRealtime();
    _topPopupTimer?.cancel();
    _removeTopPopup();
    _pageController.dispose();
    super.dispose();
  }

  void _openAddPostByShake() {
    if (!mounted) return;
    if (_selectedIndex == 2) return;
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _selectedIndex = 2;
      _currentIndex = 2;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 900),
        content: Text('Shake detected • Opened Add Post'),
      ),
    );
  }

  List<Widget> _buildBottomScreens(AuthEntity userEntity) {
    return [
      const HomeScreen(),
      const SearchScreen(),
      const AddPostScreen(),
      const MessageScreen(),
      ProfileScreen(userEntity: userEntity, refreshTick: _profileRefreshTick),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final messageState = ref.watch(messageViewModelProvider);
    _messageNotifier.setCurrentUserId(authState.authEntity?.authId);
    _callNotifier.setCurrentUserId(authState.authEntity?.authId);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'An error occurred',
        );
      }
      if (!_realtimeBootstrapped &&
          next.authEntity != null &&
          next.authEntity!.authId != null &&
          next.authEntity!.authId!.trim().isNotEmpty) {
        _realtimeBootstrapped = true;
        _messageNotifier.connectRealtime();
        _messageNotifier.loadConversations();
        _callNotifier.connectRealtime();
        _callNotifier.loadCallHistory();
      }
    });
    ref.listen<MessageState>(messageViewModelProvider, (previous, next) {
      final previousUnread = previous?.totalUnread ?? 0;
      if (next.totalUnread <= previousUnread) return;
      if (!mounted) return;

      final String? newestConversationId = next.unreadByConversation.keys
          .where((id) => next.unreadFor(id) > (previous?.unreadFor(id) ?? 0))
          .cast<String?>()
          .firstWhere((id) => id != null && id.isNotEmpty, orElse: () => null);

      String label = 'New message received';
      if (newestConversationId != null) {
        ConversationEntity? conversation;
        for (final item in next.conversations) {
          if (item.id == newestConversationId) {
            conversation = item;
            break;
          }
        }
        final name = conversation
            ?.otherParticipant(authState.authEntity?.authId ?? '')
            ?.fullName;
        if (name != null && name.trim().isNotEmpty) {
          label = 'New message from $name';
        }
      }

      _showTopPopup(context, label);
    });
    ref.listen<CallState>(callViewModelProvider, (previous, next) {
      final previousIncomingId = previous?.incomingCall?.callId;
      final incoming = next.incomingCall;
      if (incoming != null &&
          incoming.callId.isNotEmpty &&
          incoming.callId != previousIncomingId &&
          _incomingDialogCallId != incoming.callId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _incomingDialogCallId = incoming.callId;
          _showIncomingCallDialog(incoming);
        });
      }

      // If call was ended/rejected/missed by caller or server, close dialog.
      if (_incomingDialogCallId != null && next.incomingCall == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _dismissIncomingCallDialogIfOpen();
        });
      }

      final prevActiveId = previous?.activeCall?.callId;
      final nextActiveId = next.activeCall?.callId;
      if (prevActiveId != null && nextActiveId == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _dismissIncomingCallDialogIfOpen();
          _showTopPopup(context, 'Call ended');
        });
      }
    });

    if (authState.authEntity == null) {
      if (authState.status == AuthStatus.error) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    authState.errorMessage ?? 'Failed to connect to server',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(authViewModelProvider.notifier)
                          .getCurrentUser(userId: '');
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
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
                  if (index == 4) {
                    _profileRefreshTick++;
                  }
                });
              },
              children: screens,
            ),
          ),

          /// Liquid Glass Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: context.scale(20)),
              child: _buildLiquidGlassNavBar(
                navWidth,
                itemWidth,
                messageState.totalUnread,
              ),
            ),
          ),
        ],
      ),

      /// Floating AI Button
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: context.scale(60)),
        child: FloatingActionButton(
          heroTag: 'dashboard_chatbot_fab',
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
  Widget _buildLiquidGlassNavBar(
    double width,
    double itemWidth,
    int totalUnread,
  ) {
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
                  _liquidNavItem(
                    Icons.message_outlined,
                    3,
                    badgeCount: totalUnread,
                  ),
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
  Widget _liquidNavItem(IconData icon, int index, {int badgeCount = 0}) {
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
          if (index == 4) {
            _profileRefreshTick++;
          }
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        scale: isSelected ? 1.3 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1 : 0.6,
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTopPopup(BuildContext context, String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = Overlay.of(context, rootOverlay: true);
      _removeTopPopup();

      _topPopupEntry = OverlayEntry(
        builder: (_) => Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _removeTopPopup,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(_topPopupEntry!);

      _topPopupTimer?.cancel();
      _topPopupTimer = Timer(const Duration(seconds: 2), _removeTopPopup);
    });
  }

  void _removeTopPopup() {
    _topPopupTimer?.cancel();
    _topPopupTimer = null;
    _topPopupEntry?.remove();
    _topPopupEntry = null;
  }

  Future<void> _showIncomingCallDialog(ActiveCallEntity call) async {
    if (!mounted) return;
    final notifier = ref.read(callViewModelProvider.notifier);
    final callTypeLabel = call.callType == CallTypeEntity.video
        ? 'Video'
        : 'Audio';
    final callerLabel = _resolveCallerDisplayName(call);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _incomingDialogContext = dialogContext;
        return AlertDialog(
          title: Text('Incoming $callTypeLabel Call'),
          content: Text('$callerLabel is calling you'),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await notifier.rejectCall(call.callId);
                if (!dialogContext.mounted) return;
                _incomingDialogContext = null;
                _incomingDialogCallId = null;
                final navigator = Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                );
                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              icon: const Icon(Icons.call_end),
              label: const Text('Reject'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final ok = await notifier.acceptCall(call.callId);
                if (!dialogContext.mounted) return;
                _incomingDialogContext = null;
                _incomingDialogCallId = null;
                final navigator = Navigator.of(
                  dialogContext,
                  rootNavigator: true,
                );
                if (navigator.canPop()) {
                  navigator.pop();
                }
                if (!ok || !mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallSessionScreen(
                      callId: call.callId,
                      title: callerLabel,
                      subtitle: '$callTypeLabel call',
                      callType: call.callType,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.call),
              label: const Text('Accept'),
            ),
          ],
        );
      },
    );
    if (mounted && _incomingDialogCallId == call.callId) {
      _incomingDialogCallId = null;
      _incomingDialogContext = null;
    }
  }

  void _dismissIncomingCallDialogIfOpen() {
    final dialogContext = _incomingDialogContext;
    _incomingDialogContext = null;
    _incomingDialogCallId = null;
    if (dialogContext == null || !dialogContext.mounted) return;
    final navigator = Navigator.of(dialogContext, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  String _resolveCallerDisplayName(ActiveCallEntity call) {
    final callerId = call.callerId.trim().toLowerCase();
    if (callerId.isEmpty) return 'Someone';

    final callState = ref.read(callViewModelProvider);
    for (final log in callState.callHistory) {
      if (log.id == call.callId && log.caller != null) {
        return log.caller!.fullName;
      }
    }

    final authId = ref.read(authViewModelProvider).authEntity?.authId ?? '';
    final messageState = ref.read(messageViewModelProvider);
    for (final conversation in messageState.conversations) {
      final other = conversation.otherParticipant(authId);
      if (other == null) continue;
      if (other.id.trim().toLowerCase() == callerId) {
        return other.fullName;
      }
    }

    return 'User ${call.callerId.length > 6 ? call.callerId.substring(0, 6) : call.callerId}';
  }
}
