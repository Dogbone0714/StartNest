import 'package:flutter/material.dart';
import 'resident_home_screen.dart';
import 'resident_announcements_screen.dart';
import 'resident_maintenance_screen.dart';
import 'resident_voting_screen.dart';
import 'resident_profile_screen.dart';

class ResidentMainScreen extends StatefulWidget {
  const ResidentMainScreen({super.key});

  @override
  State<ResidentMainScreen> createState() => _ResidentMainScreenState();
}

class _ResidentMainScreenState extends State<ResidentMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    ResidentHomeScreen(),
    ResidentAnnouncementsScreen(),
    ResidentMaintenanceScreen(),
    ResidentVotingScreen(),
    ResidentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: '公告',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: '維修',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: '表決',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '個人',
          ),
        ],
      ),
    );
  }
} 