import 'package:flutter/material.dart';

class AdminVisitorsScreen extends StatelessWidget {
  const AdminVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('訪客管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 新增訪客登記
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('訪客管理功能開發中...'),
      ),
    );
  }
} 