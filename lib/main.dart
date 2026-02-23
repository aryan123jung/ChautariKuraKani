// import 'package:chautari_kurakani/app/app.dart';
// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await dotenv.load(fileName: ".env");

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );

//   await HiveService().init();
//   final sharedPreferences = await SharedPreferences.getInstance();

//   runApp(
//     ProviderScope(
//       overrides: [
//         sharedPreferencesProvider.overrideWithValue(sharedPreferences),
//       ],
//       child: const App(),
//     ),
//   );
// }

import 'package:chautari_kurakani/app/theme/theme_data.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/core/services/uni_links.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_new_password.dart';
import 'package:chautari_kurakani/features/settings/presentation/state/theme_mode_provider.dart';
import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Set system UI colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive
  await HiveService().init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Deep Link Service
  final deepLinkService = DeepLinkService();
  ApiEndpoints.debugPrintResolvedEndpoints();

  // Run app with ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(deepLinkService: deepLinkService),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final DeepLinkService deepLinkService;

  const MyApp({super.key, required this.deepLinkService});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initialize deep link handling
    widget.deepLinkService.init((token) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ForgetPasswordNewPassword(token: token),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    widget.deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Chautari KuraKani',
      debugShowCheckedModeBanner: false,
      theme: getLightApplicationTheme(),
      darkTheme: getDarkApplicationTheme(),
      themeMode: themeMode,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final width = media.size.width;
        final widthScale = (width / 390).clamp(0.9, 1.1);
        final textScaleFactor = media.textScaler.scale(1) * widthScale;
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(textScaleFactor.clamp(0.9, 1.2)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/reset-password') {
          final token = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => ForgetPasswordNewPassword(token: token),
          );
        }
        return null;
      },
    );
  }
}
