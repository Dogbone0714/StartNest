import 'package:flutter/material.dart';
import '../../services/community/serverpod_client_service.dart';
import '../../utils/constants/app_constants.dart';

class ResidentMaintenanceScreen extends StatefulWidget {
  const ResidentMaintenanceScreen({super.key});

  @override
  State<ResidentMaintenanceScreen> createState() => _ResidentMaintenanceScreenState();
}

class _ResidentMaintenanceScreenState extends State<ResidentMaintenanceScreen> {
  List<Map<String, dynamic>> _myMaintenanceRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyMaintenanceRequests();
  }

  Future<void> _loadMyMaintenanceRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ServerpodClientService.getAllMaintenanceRequests();
      if (result['success'] == true) {
        // 這裡應該根據當前用戶篩選，暫時顯示所有維修單
        setState(() {
          _myMaintenanceRequests = List<Map<String, dynamic>>.from(result['maintenanceRequests'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? '載入維修單失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入維修單時發生錯誤：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitMaintenanceRequest() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = '中';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('提交維修申請'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '問題標題',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '問題描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Row(
                  children: [
                    const Text('優先級：'),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedPriority,
                        isExpanded: true,
                        items: ['低', '中', '高']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPriority = value!;
                          });
                        },
                      ),
                    ),
                  ],
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
                    descriptionController.text.trim().isNotEmpty) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請填寫標題和描述')),
                  );
                }
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final addResult = await ServerpodClientService.addMaintenanceRequest(
        titleController.text.trim(),
        descriptionController.text.trim(),
        'current_user', // TODO: 使用實際的用戶名
        'current_unit', // TODO: 使用實際的單元
        priority: selectedPriority,
      );

      if (addResult['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(addResult['message'] ?? '維修申請提交成功')),
          );
          _loadMyMaintenanceRequests();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(addResult['message'] ?? '提交失敗')),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待處理':
        return Colors.orange;
      case '處理中':
        return Colors.blue;
      case '已完成':
        return Colors.green;
      case '已取消':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '高':
        return Colors.red;
      case '中':
        return Colors.orange;
      case '低':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的維修申請'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyMaintenanceRequests,
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
                        onPressed: _loadMyMaintenanceRequests,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMyMaintenanceRequests,
                  child: _myMaintenanceRequests.isEmpty
                      ? const Center(
                          child: Text('您還沒有提交過維修申請'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          itemCount: _myMaintenanceRequests.length,
                          itemBuilder: (context, index) {
                            final request = _myMaintenanceRequests[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                              child: ExpansionTile(
                                leading: Icon(
                                  Icons.build,
                                  color: _getStatusColor(request['status'] ?? ''),
                                ),
                                title: Text(
                                  request['title'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('單元：${request['unit'] ?? ''}'),
                                    Text(
                                      '申請時間：${_formatDateTime(request['createdAt'])}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '問題描述：',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(request['description'] ?? ''),
                                        const SizedBox(height: AppConstants.paddingMedium),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getPriorityColor(request['priority'] ?? '').withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '優先級：${request['priority'] ?? ''}',
                                                style: TextStyle(
                                                  color: _getPriorityColor(request['priority'] ?? ''),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppConstants.paddingMedium),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(request['status'] ?? '').withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '狀態：${request['status'] ?? ''}',
                                                style: TextStyle(
                                                  color: _getStatusColor(request['status'] ?? ''),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _submitMaintenanceRequest,
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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