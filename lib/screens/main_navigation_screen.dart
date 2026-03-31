import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final double bmi;
  final String name;
  MainNavigationScreen({required this.bmi, required this.name});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to Home

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      SearchScreen(),

      HomeScreen(bmi: widget.bmi, name: widget.name),
      ChatScreen(bmi: widget.bmi, name: widget.name),
      SettingsScreen(),
      const Center(child: Text("AI Chat Assistant - Coming Soon")),
      const Center(child: Text("Settings")),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
        ],
      ),
    );
  }
}
