import 'package:chautari_kurakani/screens/bottom_nav_screen/add_post_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen/chatbot_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen/home_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/message_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/profile_screen.dart';
import 'package:chautari_kurakani/screens/bottom_nav_screen/search_screen.dart';
import 'package:flutter/material.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: lstBottomScreen[_selectedIndex]),
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
          borderRadius: BorderRadiusGeometry.circular(20)
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatbotScreen()));
        },
        child: const Icon(Icons.smart_toy_sharp, size: 40,color: Color.fromARGB(255, 236, 205, 113)),),
      );

    
  }
}
