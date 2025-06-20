import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';
import '../../utils/constants/app_constants.dart';
import 'resident_announcements_screen.dart';
import 'resident_maintenance_screen.dart';
import 'resident_profile_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ResidentDashboard(),
    const ResidentAnnouncementsScreen(),
    const ResidentMaintenanceScreen(),
    const ResidentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('歡迎，${authService.userName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: 顯示通知
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
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
            icon: Icon(Icons.person),
            label: '個人',
          ),
        ],
      ),
    );
  }
}

class ResidentDashboard extends StatelessWidget {
  const ResidentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 歡迎卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '歡迎回到子敬園！',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    '${authService.userName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // 最新公告
          Text(
            '最新公告',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Card(
            child: ListTile(
              leading: const Icon(Icons.announcement, color: Colors.orange),
              title: const Text('電梯維護通知'),
              subtitle: const Text('子敬園電梯將於明日進行年度維護...'),
              trailing: const Text('2小時前'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ResidentAnnouncementsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // 待處理事項
          Text(
            '待處理事項',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Card(
            child: ListTile(
              leading: const Icon(Icons.build, color: Colors.blue),
              title: const Text('水龍頭漏水'),
              subtitle: const Text('狀態：處理中'),
              trailing: const Chip(
                label: Text('處理中'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ResidentMaintenanceScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 