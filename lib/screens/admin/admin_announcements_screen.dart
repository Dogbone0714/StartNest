import 'package:flutter/material.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公告管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 新增公告
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('公告管理功能開發中...'),
      ),
    );
  }
} 