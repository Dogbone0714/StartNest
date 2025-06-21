import 'package:flutter/material.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';

class ResidentMaintenanceScreen extends StatefulWidget {
  const ResidentMaintenanceScreen({super.key});

  @override
  State<ResidentMaintenanceScreen> createState() => _ResidentMaintenanceScreenState();
}

class _ResidentMaintenanceScreenState extends State<ResidentMaintenanceScreen> {
  List<Map<String, dynamic>> _maintenanceRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRequests();
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '未知時間';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}年${dateTime.month.toString().padLeft(2, '0')}月${dateTime.day.toString().padLeft(2, '0')}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '時間格式錯誤';
    }
  }

  Future<void> _loadMaintenanceRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseService.getAllMaintenanceRequests();
      
      if (result != null && result['success'] == true) {
        setState(() {
          _maintenanceRequests = List<Map<String, dynamic>>.from(result['requests']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? '獲取維修請求列表失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '獲取維修請求列表失敗：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addMaintenanceRequest() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增維修請求'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '標題'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: '描述'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final addResult = await FirebaseService.addMaintenanceRequest(
                titleController.text,
                descriptionController.text,
              );
              Navigator.of(context).pop(addResult);
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadMaintenanceRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待處理';
      case 'in_progress':
        return '處理中';
      case 'completed':
        return '已完成';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('維修請求'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaintenanceRequests,
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMaintenanceRequests,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _maintenanceRequests.isEmpty
                  ? const Center(child: Text('暫無維修請求'))
                  : RefreshIndicator(
                      onRefresh: _loadMaintenanceRequests,
                      child: ListView.builder(
                        itemCount: _maintenanceRequests.length,
                        itemBuilder: (context, index) {
                          final request = _maintenanceRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                request['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${request['description']}\n狀態：${_getStatusText(request['status'])} | 提交時間：${_formatDateTime(request['created_at'])}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMaintenanceRequest,
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
} 