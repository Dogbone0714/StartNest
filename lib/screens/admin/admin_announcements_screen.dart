import 'package:flutter/material.dart';
import '../../services/community/serverpod_client_service.dart';
import '../../utils/constants/app_constants.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
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

  Future<void> _addAnnouncement() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isImportant = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新增公告'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '標題',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '內容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                CheckboxListTile(
                  title: const Text('重要公告'),
                  value: isImportant,
                  onChanged: (value) {
                    setState(() {
                      isImportant = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    contentController.text.trim().isNotEmpty) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請填寫標題和內容')),
                  );
                }
              },
              child: const Text('發布'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final addResult = await ServerpodClientService.addAnnouncement(
        titleController.text.trim(),
        contentController.text.trim(),
        'admin',
        isImportant: isImportant,
      );

      if (addResult['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(addResult['message'] ?? '公告發布成功')),
          );
          _loadAnnouncements();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(addResult['message'] ?? '發布失敗')),
          );
        }
      }
    }
  }

  Future<void> _deleteAnnouncement(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除這則公告嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ServerpodClientService.deleteAnnouncement(id);
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? '公告刪除成功')),
          );
          _loadAnnouncements();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? '刪除失敗')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公告管理'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAnnouncement,
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
                            child: ListTile(
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(announcement['content'] ?? ''),
                                  const SizedBox(height: AppConstants.paddingSmall),
                                  Text(
                                    '發布時間：${_formatDateTime(announcement['createdAt'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteAnnouncement(announcement['id']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('刪除'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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