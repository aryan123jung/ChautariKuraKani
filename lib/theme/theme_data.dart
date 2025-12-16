import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
    // fontFamily: 'OpenSans Regular',
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0XFF76C05D),
      selectedItemColor: Colors.black,
      unselectedItemColor: const Color.fromARGB(255, 224, 224, 224),
      selectedLabelStyle: TextStyle(fontFamily: "OpenSans Bold"),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      selectedIconTheme: IconThemeData(size: 30)
    ),

  );
}