import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userInfo = authService.getCurrentUserInfo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理員資料'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.admin_panel_settings),
                ),
                title: Text(
                  userInfo?['name'] ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${userInfo?['building'] ?? ''}${userInfo?['unit'] ?? ''}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('管理員功能開發中...'),
          ],
        ),
      ),
    );
  }
} 