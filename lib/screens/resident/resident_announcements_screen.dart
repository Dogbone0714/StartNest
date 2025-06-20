import 'package:flutter/material.dart';
import '../../utils/constants/app_constants.dart';

class ResidentAnnouncementsScreen extends StatelessWidget {
  const ResidentAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社區公告'),
      ),
      body: const Center(
        child: Text('公告功能開發中...'),
      ),
    );
  }
} 