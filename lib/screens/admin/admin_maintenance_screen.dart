import 'package:flutter/material.dart';

class AdminMaintenanceScreen extends StatelessWidget {
  const AdminMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('維修單管理'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('維修單管理頁面'),
      ),
    );
  }
}
