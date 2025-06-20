import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';
import '../../utils/constants/app_constants.dart';
import 'admin_announcements_screen.dart';
import 'admin_maintenance_screen.dart';
import 'admin_residents_screen.dart';
import 'admin_visitors_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_invitation_codes_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboard(),
    const AdminAnnouncementsScreen(),
    const AdminMaintenanceScreen(),
    const AdminResidentsScreen(),
    const AdminVisitorsScreen(),
    const AdminInvitationCodesScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('子敬園管理 - ${authService.userName}'),
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
            icon: Icon(Icons.people_outline),
            label: '訪客',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: '邀請碼',
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

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 統計卡片
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.paddingMedium,
            mainAxisSpacing: AppConstants.paddingMedium,
            children: [
              _buildStatCard(
                context,
                '總住戶數',
                '156',
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                '待處理維修',
                '8',
                Icons.build,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                '今日訪客',
                '12',
                Icons.people_outline,
                Colors.green,
              ),
              _buildStatCard(
                context,
                '有效邀請碼',
                '5',
                Icons.qr_code,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // 快速功能
          Text(
            '快速功能',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.paddingMedium,
            mainAxisSpacing: AppConstants.paddingMedium,
            children: [
              _buildQuickActionCard(
                context,
                '發布公告',
                Icons.announcement,
                Colors.blue,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminAnnouncementsScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                '處理維修',
                Icons.build,
                Colors.orange,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminMaintenanceScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                '住戶管理',
                Icons.people,
                Colors.green,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminResidentsScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                '生成邀請碼',
                Icons.qr_code,
                Colors.purple,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminInvitationCodesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // 最近活動
          Text(
            '最近活動',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.purple),
                  title: const Text('生成邀請碼'),
                  subtitle: const Text('ABC123 - A棟1001室'),
                  trailing: const Text('5分鐘前'),
                ),
                ListTile(
                  leading: const Icon(Icons.build, color: Colors.orange),
                  title: const Text('A棟1001室報修'),
                  subtitle: const Text('水龍頭漏水'),
                  trailing: const Chip(
                    label: Text('待處理'),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people_outline, color: Colors.green),
                  title: const Text('訪客登記'),
                  subtitle: const Text('B棟2002室 - 王小明'),
                  trailing: const Text('10分鐘前'),
                ),
                ListTile(
                  leading: const Icon(Icons.announcement, color: Colors.blue),
                  title: const Text('發布公告'),
                  subtitle: const Text('電梯維護通知'),
                  trailing: const Text('1小時前'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 