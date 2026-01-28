import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/add_post_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/chatbot_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/home_screen/home_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/message_screen.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/profile_screen.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Any code you want to run after the first frame is rendered
      final userSessionService = ref.read(userSessionServiceProvider);
      ref
          .read(authViewModelProvider.notifier)
          .getCurrentUser(userId: userSessionService.getCurrentUserId() ?? "");
    });
  }

  // List<Widget> lstBottomScreen = [
  //   const HomeScreen(),
  //   const SearchScreen(),
  //   const AddPostScreen(),
  //   const MessageScreen(),
  //   const ProfileScreen(email: ""),
  // ];

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
      return const Scaffold(body: Center(child: Text("No user data found")));
    }

    final userEntity = authState.authEntity;

    final screens = _buildBottomScreens(userEntity!);

    return Scaffold(
      body: SafeArea(child: screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0XFF76C05D),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotScreen()),
          );
        },
        child: const Icon(
          Icons.smart_toy_sharp,
          size: 40,
          color: Color.fromARGB(255, 236, 205, 113),
        ),
      ),
    );
  }
}
