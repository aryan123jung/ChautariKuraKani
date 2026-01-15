// import 'package:chautari_kurakani/app/app.dart';
// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   // Initialize Hive
//   final container = ProviderContainer();
//   await container.read(hiveServiceProvider).init();

//   runApp(UncontrolledProviderScope(container: container, child: const App()));
// }

import 'package:chautari_kurakani/app/app.dart';
import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:lost_n_found/app/app.dart';
// import 'package:lost_n_found/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await HiveService().init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}

// import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
// import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chautari_kurakani/app/app.dart';
// // import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   // Initialize Hive
//   final container = ProviderContainer();
//   await container.read(hiveServiceProvider).init();

//   final hiveService = container.read(hiveServiceProvider);
//   final allAuths = hiveService.getAllAuths();
//   final initialScreen = allAuths.isNotEmpty
//       ? const DashboardScreen()
//       : const SplashScreen();

//   runApp(
//     UncontrolledProviderScope(
//       container: container,
//       child: App(home: initialScreen),
//     ),
//   );
// }

// import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chautari_kurakani/app/app.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   // Initialize Hive
//   final container = ProviderContainer();
//   await container.read(hiveServiceProvider).init();

//   final hiveService = container.read(hiveServiceProvider);
//   final allAuths = hiveService.getAllAuths();
//   final initialScreen = allAuths.isNotEmpty
//       ? const DashboardScreen()
//       : const LoginScreen();

//   runApp(
//     UncontrolledProviderScope(
//       container: container,
//       child: App(home: initialScreen),
//     ),
//   );
// }
