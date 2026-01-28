import 'package:flutter/material.dart';
import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
import 'package:chautari_kurakani/app/theme/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChautariKuraKani',
      color: const Color(0xFF76C05D),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: getApplicationTheme(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chautari_kurakani/app/theme/theme_data.dart';
// import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';

// class App extends ConsumerWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (previous?.status == next.status) return;

//       if (next.status == AuthStatus.unauthenticated) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const LoginScreen()),
//           (route) => false,
//         );
//       }

//       if (next.status == AuthStatus.authenticated) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const DashboardScreen()),
//           (route) => false,
//         );
//       }
//     });

//     return MaterialApp(
//       title: 'ChautariKuraKani',
//       debugShowCheckedModeBanner: false,
//       theme: getApplicationTheme(),
//       home: const SplashScreen(),
//     );
//   }
// }
