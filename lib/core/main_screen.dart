import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/home/screens/home_screen.dart';
import 'package:cockatiel_companion/features/community/screens/community_screen.dart';
import 'package:cockatiel_companion/features/notifications/screens/notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of the main pages
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    CommunityScreen(),
    NotificationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: ScreenTitles.homePage,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            label: ScreenTitles.community,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: ScreenTitles.notifications,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}