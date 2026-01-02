import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
import 'package:chautari_kurakani/app/theme/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        color: const Color(0xFF76C05D),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        theme: getApplicationTheme(),
      ),
    );
  }
}
