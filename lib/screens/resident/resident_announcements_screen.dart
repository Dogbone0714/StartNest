import 'package:flutter/material.dart';
import '../../services/community/serverpod_client_service.dart';
import '../../utils/constants/app_constants.dart';

class ResidentAnnouncementsScreen extends StatefulWidget {
  const ResidentAnnouncementsScreen({super.key});

  @override
  State<ResidentAnnouncementsScreen> createState() => _ResidentAnnouncementsScreenState();
}

class _ResidentAnnouncementsScreenState extends State<ResidentAnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ServerpodClientService.getAllAnnouncements();
      if (result['success'] == true) {
        setState(() {
          _announcements = List<Map<String, dynamic>>.from(result['announcements'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? '載入公告失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入公告時發生錯誤：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社區公告'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ElevatedButton(
                        onPressed: _loadAnnouncements,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _announcements.isEmpty
                  ? const Center(
                      child: Text('目前沒有公告'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAnnouncements,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) {
                          final announcement = _announcements[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                            child: ExpansionTile(
                              leading: Icon(
                                announcement['isImportant'] == true
                                    ? Icons.priority_high
                                    : Icons.announcement,
                                color: announcement['isImportant'] == true
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              title: Text(
                                announcement['title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '發布時間：${_formatDateTime(announcement['createdAt'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        announcement['content'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: AppConstants.paddingSmall),
                                      if (announcement['isImportant'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '重要公告',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
} 