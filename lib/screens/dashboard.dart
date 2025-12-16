import 'package:chautari_kurakani/screens/bottom_nav_screen/add_post_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/message_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/profile_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/search_screen.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  List<Widget>lstBottomScreen = [
    const HomeScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const MessageScreen(),
    const ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard",),
        // title: Text("Dashboard",style: TextStyle(fontFamily: 'OpenSans Italic'),),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search),label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add),label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.message),label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),
        ],
        backgroundColor: Colors.orange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        ),
    );
  }
}