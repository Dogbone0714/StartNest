import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_maintenance_screen.dart';
import 'admin_residents_screen.dart';
import 'admin_invitation_codes_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    AdminAnnouncementsScreen(),
    AdminMaintenanceScreen(),
    AdminResidentsScreen(),
    AdminInvitationCodesScreen(),
    AdminNotificationsScreen(),
    AdminProfileScreen(),
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
            icon: Icon(Icons.dashboard),
            label: '儀表板',
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
            icon: Icon(Icons.people),
            label: '住戶',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: '邀請碼',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '推播',
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