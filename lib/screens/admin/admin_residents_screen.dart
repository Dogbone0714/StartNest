import 'package:flutter/material.dart';

class AdminResidentsScreen extends StatelessWidget {
  const AdminResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('住戶管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 新增住戶
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('住戶管理功能開發中...'),
      ),
    );
  }
} 