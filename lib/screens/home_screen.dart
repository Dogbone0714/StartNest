import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/community/auth_service.dart';
import '../utils/constants/app_constants.dart';
import 'resident/resident_announcements_screen.dart';
import 'resident/resident_maintenance_screen.dart';
import 'resident/resident_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('子敬園一點通'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 歡迎訊息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '歡迎回來，${authService.userName}！',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '子敬園社區管理系統',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
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
                  '社區公告',
                  Icons.announcement,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidentAnnouncementsScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  '維修申請',
                  Icons.build,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidentMaintenanceScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  '個人資料',
                  Icons.person,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResidentProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // 系統資訊
            Text(
              '系統資訊',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text('系統版本'),
                    subtitle: const Text('子敬園一點通 v1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.green),
                    title: const Text('資料安全'),
                    subtitle: const Text('所有資料均加密傳輸'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.support_agent, color: Colors.orange),
                    title: const Text('技術支援'),
                    subtitle: const Text('如有問題請聯繫管理員'),
                  ),
                ],
              ),
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