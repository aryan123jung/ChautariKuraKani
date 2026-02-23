import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return getLightApplicationTheme();
}

ThemeData getLightApplicationTheme() {
  const seed = Color(0XFF76C05D);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF6F8FB),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1D1F24),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0XFF76C05D),
      selectedItemColor: Colors.black,
      unselectedItemColor: Color.fromARGB(255, 224, 224, 224),
      selectedLabelStyle: TextStyle(fontFamily: "OpenSans Bold"),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      selectedIconTheme: IconThemeData(size: 30),
    ),
  );
}

ThemeData getDarkApplicationTheme() {
  const seed = Color(0XFF76C05D);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFF0F1218),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Color(0xFF11151D),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF161B24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF131923)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0XFF2F6A25),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFFB8C0CD),
      selectedLabelStyle: TextStyle(fontFamily: "OpenSans Bold"),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      selectedIconTheme: IconThemeData(size: 30),
    ),
  );
}
